#!/bin/bash
set -e
set -o pipefail
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# VARIABLES (Terraform injected)
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
userName="${sonar_server_username}"
ssh_key="${sonar_ssh_public_key}"
hostname="${sonar_server_hostname}"

SONAR_VERSION="9.9.4.87374"
SONAR_DB="${sonar_db}"
SONAR_DB_USER="${sonar_db_user}"
SONAR_DB_PASS="${sonar_db_pass}"
PG_SUPER_PASS="${pg_super_pass}"
PG_HBA="/var/lib/pgsql/data/pg_hba.conf"
LOG_FILE="/var/log/sonarqube-bootstrap.log"

echo "=== [INFO] SonarQube Bootstrap Script Starting ==="
echo "User: $userName | Hostname: $hostname"
echo "---------------------------------------------------"

# -------------------------------------------------------------------
# 1️⃣ SSH and User Setup
# -------------------------------------------------------------------
echo "=== [STEP 1] Validating SSH Key ==="
if [ -z "$ssh_key" ]; then
    echo "[WARN] SSH public key not provided — skipping key setup."
else
    echo "[INFO] SSH key detected, proceeding..."
fi

echo "=== [STEP 2] Enabling SSH password authentication ==="
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%F_%T)
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
if ! grep -q "^UsePAM yes" /etc/ssh/sshd_config; then
    echo "UsePAM yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi
sudo systemctl restart sshd
sudo systemctl enable sshd
echo "[OK] SSH password authentication enabled."

echo "=== [STEP 3] Setting hostname to '$hostname' ==="
sudo hostnamectl set-hostname "$hostname"
echo "127.0.0.1   $hostname" | sudo tee -a /etc/hosts > /dev/null
echo "[OK] Hostname set to $hostname"

echo "=== [STEP 4] Creating user '$userName' and adding SSH key ==="
if id "$userName" &>/dev/null; then
    echo "[INFO] User '$userName' already exists."
else
    sudo useradd -m -s /bin/bash "$userName"
    echo "[OK] User '$userName' created."
fi

if [ -n "$ssh_key" ]; then
    sudo mkdir -p /home/$userName/.ssh
    echo "$ssh_key" | sudo tee /home/$userName/.ssh/authorized_keys > /dev/null
    sudo chown -R $userName:$userName /home/$userName/.ssh
    sudo chmod 700 /home/$userName/.ssh
    sudo chmod 600 /home/$userName/.ssh/authorized_keys
    echo "[OK] SSH key added for user '$userName'."
fi

echo "=== [STEP 5] Granting passwordless sudo to '$userName' ==="
sudo usermod -aG wheel $userName || true
echo "$userName ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$userName > /dev/null
sudo chmod 440 /etc/sudoers.d/$userName
echo "[OK] Passwordless sudo configured for '$userName'."

# -------------------------------------------------------------------
# 2️⃣ PostgreSQL Setup
# -------------------------------------------------------------------
echo "=== [STEP 4] Installing dependencies ==="
sudo dnf update -y
sudo dnf install -y wget unzip vim git net-tools java-17-openjdk java-17-openjdk-devel postgresql-server postgresql-contrib policycoreutils-python-utils

echo "=== [STEP 5] Initializing PostgreSQL ==="
if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
  sudo postgresql-setup --initdb
fi
sudo systemctl enable --now postgresql

# Phase 1: Peer for postgres
echo "=== [STEP 6] Temporarily modifying pg_hba.conf ==="
sudo cp "$PG_HBA" "$PG_HBA.bak"
sudo bash -c "cat > $PG_HBA" <<'EOF'
local   all             postgres                                peer
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
EOF
sudo systemctl restart postgresql

echo "=== [STEP 7] Creating SonarQube DB and user ==="
sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL
ALTER USER postgres WITH ENCRYPTED PASSWORD '$PG_SUPER_PASS';
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$SONAR_DB_USER') THEN
    CREATE USER $SONAR_DB_USER WITH ENCRYPTED PASSWORD '$SONAR_DB_PASS';
  ELSE
    ALTER USER $SONAR_DB_USER WITH ENCRYPTED PASSWORD '$SONAR_DB_PASS';
  END IF;
END
\$\$;
CREATE DATABASE $SONAR_DB OWNER $SONAR_DB_USER
  ENCODING 'UTF8' LC_COLLATE='en_US.utf8' LC_CTYPE='en_US.utf8' TEMPLATE template0;
GRANT ALL PRIVILEGES ON DATABASE $SONAR_DB TO $SONAR_DB_USER;
SQL

# Phase 2: Revert pg_hba.conf
echo "=== [STEP 8] Reverting pg_hba.conf to md5-only mode ==="
sudo bash -c "cat > $PG_HBA" <<'EOF'
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
EOF
sudo systemctl restart postgresql

# -------------------------------------------------------------------
# 3️⃣ SonarQube Setup
# -------------------------------------------------------------------
echo "=== [STEP 9] Installing SonarQube $SONAR_VERSION ==="
cd /opt
sudo wget -q https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip
sudo unzip -q sonarqube-$SONAR_VERSION.zip
sudo mv sonarqube-$SONAR_VERSION sonarqube
sudo useradd -m -d /opt/sonarqube -s /bin/bash sonar || true
sudo chown -R sonar:sonar /opt/sonarqube

echo "=== [STEP 10] Configuring SonarQube ==="
sudo bash -c "cat > /opt/sonarqube/conf/sonar.properties" <<EOF
sonar.jdbc.username=$SONAR_DB_USER
sonar.jdbc.password=$SONAR_DB_PASS
sonar.jdbc.url=jdbc:postgresql://127.0.0.1/$SONAR_DB
sonar.web.host=0.0.0.0
sonar.web.port=9000
EOF
sudo chown sonar:sonar /opt/sonarqube/conf/sonar.properties

# System tuning
echo "=== [STEP 11] System tuning ==="
sudo tee -a /etc/security/limits.conf >/dev/null <<'EOF'
sonar   -   nofile   65536
sonar   -   nproc    4096
EOF
sudo tee -a /etc/sysctl.conf >/dev/null <<'EOF'
vm.max_map_count=262144
fs.file-max=65536
EOF
sudo sysctl -p

# Optional swap
if [ "$(free -m | awk '/^Mem:/{print $2}')" -lt 3000 ]; then
  echo "=== [INFO] Creating swap (2GB)..."
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# -------------------------------------------------------------------
# 4️⃣ Service Setup
# -------------------------------------------------------------------
echo "=== [STEP 12] Creating SonarQube systemd service ==="
sudo bash -c "cat > /etc/systemd/system/sonarqube.service" <<'EOF'
[Unit]
Description=SonarQube service
After=syslog.target network.target postgresql.service

[Service]
Type=forking
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo firewall-cmd --permanent --add-port=9000/tcp || true
sudo firewall-cmd --reload || true

echo "=== [STEP 13] Starting SonarQube service ==="
sudo systemctl start sonarqube
sleep 10

if sudo ss -tulnp | grep -q ':9000'; then
  echo "✅ SonarQube is UP and running on port 9000!"
else
  echo "⚠️ SonarQube started but not yet responding. Check logs below:"
  sudo tail -n 50 /opt/sonarqube/logs/sonar.log
fi

echo "======================================================"
echo "✅ SonarQube Bootstrap Completed Successfully!"
echo "Access UI: http://$(hostname -I | awk '{print $1}'):9000"
echo "Login: admin / admin"
echo "Database: $SONAR_DB_USER / $SONAR_DB_PASS"
echo "Log file: $LOG_FILE"
echo "======================================================"