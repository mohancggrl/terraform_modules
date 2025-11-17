#!/bin/bash
#====================================================================
# JFrog Artifactory OSS + PostgreSQL Installation Script (RHEL9+)
#====================================================================
# Author: Mohan
# Version: 1.3
# Date: 2025-11-13
#====================================================================

set -e
set -o pipefail
LOG_FILE="/var/log/install_artifactory_with_postgres.log"
exec > >(tee -a "$LOG_FILE") 2>&1

#====================================================================
# VARIABLES — Update if needed or pass via Terraform template
#====================================================================
userName="${server_username}"
ssh_key="${ssh_public_key}"
hostname="${server_hostname}"

PG_VERSION="15"
ARTI_VERSION="7.71.9"

DB_NAME="${jfrog_db}"
DB_USER="${jfrog_db_user}"
DB_PASS="${jfrog_db_pass}"
PG_SUPER_PASS="${jfrog_pg_super_pass}"

PG_JDBC_URL="https://jdbc.postgresql.org/download/postgresql-42.6.0.jar"
ARTI_RPM_URL="https://releases.jfrog.io/artifactory/artifactory-pro-rpms/jfrog-artifactory-pro/jfrog-artifactory-pro-$ARTI_VERSION.rpm"


#====================================================================
# FUNCTIONS
#====================================================================
error_exit() {
  echo "❌ ERROR: $1"
  echo "Check logs in $LOG_FILE"
  exit 1
}

info() {
  echo -e "\n=== [INFO] $1 ==="
}

#====================================================================
# 1️⃣ SSH and User Setup
#====================================================================
info "Setting up SSH and system user..."

# Enable password authentication
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%F_%T)
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
grep -q "^UsePAM yes" /etc/ssh/sshd_config || echo "UsePAM yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
sudo systemctl restart sshd
sudo systemctl enable sshd
echo "[OK] SSH password authentication enabled."

# Set hostname
sudo hostnamectl set-hostname "$hostname"
grep -q "$hostname" /etc/hosts || echo "127.0.0.1   $hostname" | sudo tee -a /etc/hosts > /dev/null

# Create user
if ! id "$userName" &>/dev/null; then
  sudo useradd -m -s /bin/bash "$userName"
  echo "[OK] User '$userName' created."
else
  echo "[INFO] User '$userName' already exists."
fi

# Add SSH key if provided
if [ -n "$ssh_key" ]; then
  sudo mkdir -p /home/$userName/.ssh
  echo "$ssh_key" | sudo tee /home/$userName/.ssh/authorized_keys > /dev/null
  sudo chown -R $userName:$userName /home/$userName/.ssh
  sudo chmod 700 /home/$userName/.ssh
  sudo chmod 600 /home/$userName/.ssh/authorized_keys
  echo "[OK] SSH key added for user '$userName'."
else
  echo "[WARN] No SSH key provided — skipping key setup."
fi

# Grant sudo
echo "$userName ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$userName > /dev/null
sudo chmod 440 /etc/sudoers.d/$userName
echo "[OK] Passwordless sudo configured for '$userName'."

#====================================================================
# 2️⃣ System Preparation
#====================================================================
info "Updating system and installing dependencies..."
dnf update -y || error_exit "System update failed"
dnf install -y wget unzip vim git net-tools java-17-openjdk java-17-openjdk-devel postgresql-server postgresql-contrib policycoreutils-python-utils || error_exit "Dependency installation failed"

#====================================================================
# 3️⃣ PostgreSQL Initialization
#====================================================================
info "Initializing PostgreSQL database..."
if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
  postgresql-setup --initdb || error_exit "PostgreSQL initialization failed"
fi

systemctl enable --now postgresql || error_exit "Failed to start PostgreSQL service"
systemctl status postgresql --no-pager || true

info "Configuring PostgreSQL authentication..."
PG_HBA="/var/lib/pgsql/data/pg_hba.conf"
cp "$PG_HBA" "$PG_HBA.bak_$(date +%F_%T)"
cat <<EOF > "$PG_HBA"
local   all             postgres                                peer
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
EOF
systemctl restart postgresql || error_exit "PostgreSQL restart failed"

#====================================================================
# 4️⃣ Create Database & User (Corrected Logic)
#====================================================================
info "Creating PostgreSQL database and user..."

sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$PG_SUPER_PASS';" || error_exit "Failed to set postgres password"

if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB_NAME';" | grep -q 1; then
  echo "Database '$DB_NAME' already exists."
else
  sudo -u postgres psql -c "CREATE DATABASE $DB_NAME;" || error_exit "Database creation failed"
fi

if sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$DB_USER';" | grep -q 1; then
  sudo -u postgres psql -c "ALTER USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASS';"
else
  sudo -u postgres psql -c "CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASS';" || error_exit "User creation failed"
fi

sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" || error_exit "Privilege grant failed"
systemctl restart postgresql

info "Validating DB connection..."
PGPASSWORD="$DB_PASS" psql -h localhost -U "$DB_USER" -d "$DB_NAME" -c "SELECT 1;" || error_exit "Database connection test failed."

#====================================================================
# 5️⃣ Install JFrog Artifactory
#====================================================================
info "Installing JFrog Artifactory OSS $ARTI_VERSION..."
cd /opt
wget -q "$ARTI_RPM_URL" -O jfrog-artifactory-pro-$ARTI_VERSION.rpm || error_exit "Failed to download Artifactory"
dnf install -y ./jfrog-artifactory-pro-$ARTI_VERSION.rpm || error_exit "Installation failed"

#====================================================================
# 6️⃣ Configure Artifactory Database
#====================================================================
info "Configuring Artifactory database connection..."
cat <<EOF > /opt/jfrog/artifactory/var/etc/system.yaml
configVersion: 1

shared:
  logging:
    consoleLog:
      enabled: true

database:
  type: postgresql
  driver: org.postgresql.Driver
  url: jdbc:postgresql://localhost:5432/$DB_NAME
  username: $DB_USER
  password: $DB_PASS
EOF

#====================================================================
# 7️⃣ Install JDBC Driver
#====================================================================
info "Installing PostgreSQL JDBC driver..."
mkdir -p /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib
wget -q -O /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/postgresql.jar "$PG_JDBC_URL" || error_exit "JDBC driver download failed"
chown -R artifactory:artifactory /opt/jfrog/artifactory
chmod 755 /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/postgresql.jar

#====================================================================
# 8️⃣ Start Artifactory
#====================================================================
info "Starting Artifactory service..."
systemctl enable artifactory || error_exit "Failed to enable Artifactory"
systemctl start artifactory || error_exit "Failed to start Artifactory"

sleep 20
if systemctl status artifactory | grep -q "active (running)"; then
  echo "✅ Artifactory service started successfully!"
else
  error_exit "Artifactory failed to start. Check /opt/jfrog/artifactory/var/log/console.log"
fi

#====================================================================
# 9️⃣ Final Validation
#====================================================================
info "Validating Artifactory port..."
if ss -tuln | grep -q 8082; then
  echo "✅ Artifactory UI available on port 8082"
else
  echo "⚠️ Port 8082 not open — check firewall or logs."
fi

echo -e "\n🎉 Artifactory OSS $ARTI_VERSION installation completed successfully!"
echo "Access it at: http://$(hostname -I | awk '{print $1}'):8082/ui/"
echo "Logs: $LOG_FILE"