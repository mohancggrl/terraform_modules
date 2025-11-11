#!/bin/bash
set -e
set -o pipefail

# -------------------------------------------------------------------
# Dynamic variables (injected via Terraform)
# -------------------------------------------------------------------
userName="${server_username}"
ssh_key="${ssh_public_key}"
hostname="${server_hostname}"

LOG_FILE="/var/log/jenkins-bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== [INFO] Jenkins Bootstrap Script Starting ==="
echo "User: $userName | Hostname: $hostname"

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
# 2️⃣ System Update & Essentials
# -------------------------------------------------------------------
echo "=== [STEP 6] Updating system and installing essentials ==="
sudo dnf update -y
sudo dnf install -y wget git curl unzip tar gzip yum-utils device-mapper-persistent-data lvm2
echo "[OK] Essentials installed."

# -------------------------------------------------------------------
# 3️⃣ Java + Maven
# -------------------------------------------------------------------
echo "=== [STEP 7] Installing Java 17 and Maven ==="
sudo dnf install -y java-17-openjdk-devel maven
java --version || true
echo "[OK] Java & Maven installation complete."

# -------------------------------------------------------------------
# 4️⃣ Jenkins Setup
# -------------------------------------------------------------------
echo "=== [STEP 8] Installing Jenkins ==="
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install -y jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "[OK] Jenkins installed and running."

# -------------------------------------------------------------------
# 5️⃣ Docker Installation
# -------------------------------------------------------------------
echo "=== [STEP 9] Installing Docker CE ==="
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
echo "[OK] Docker installed and running."

# -------------------------------------------------------------------
# 6️⃣ Jenkins + Docker Integration
# -------------------------------------------------------------------
echo "=== [STEP 10] Allow Jenkins user to use Docker ==="
sudo usermod -s /bin/bash jenkins || true
sudo usermod -aG docker jenkins || true
sudo systemctl restart jenkins
echo "[OK] Jenkins user added to Docker group."