#!/bin/bash
set -e

userName="${var.server_userName}"
ssh_key="${var.ssh_public_key}"
hostName="${var.server_hostName}"

if [ -z "$ssh_key" ]; then
    echo "❌ ERROR: SSH public key not provided."
    exit 1
fi

echo "=== Step 1: Enabling SSH password authentication ==="
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak_$(date +%F_%T)
sudo sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
if ! grep -q "^UsePAM yes" /etc/ssh/sshd_config; then
    echo "UsePAM yes" | sudo tee -a /etc/ssh/sshd_config > /dev/null
fi
sudo systemctl restart sshd
sudo systemctl enable sshd

echo "✅ SSH password authentication enabled."

echo "=== Step 2: Changing hostName to '$hostName' ==="
sudo hostNamectl set-hostName "$hostName"
echo "127.0.0.1   $hostName" | sudo tee -a /etc/hosts > /dev/null
echo "✅ hostName changed to '$hostName'."

echo "=== Step 3: Creating user '$userName' and adding SSH key ==="
if id "$userName" &>/dev/null; then
    echo "User '$userName' already exists."
else
    sudo useradd -m -s /bin/bash "$userName"
    echo "✅ User '$userName' created."
fi

sudo mkdir -p /home/$userName/.ssh
echo "$ssh_key" | sudo tee /home/$userName/.ssh/authorized_keys > /dev/null
sudo chown -R $userName:$userName /home/$userName/.ssh
sudo chmod 700 /home/$userName/.ssh
sudo chmod 600 /home/$userName/.ssh/authorized_keys
echo "✅ SSH key added for user '$userName'."

echo "=== Step 4: Granting passwordless sudo to '$userName' ==="
sudo usermod -aG wheel $userName
echo "$userName ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$userName > /dev/null
sudo chmod 440 /etc/sudoers.d/$userName

echo "=== Step 5: Installing tools ==="
sudo dnf update -y
sudo dnf install -y curl unzip tar gzip git dnf-plugins-core java-21-openjdk maven

echo "✅ Java + Maven installed"

echo "=== Step 6: Installing AWS CLI v2 ==="
cd /tmp
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q -o awscliv2.zip
sudo ./aws/install --update
rm -rf /tmp/aws /tmp/awscliv2.zip

echo "=== Step 7: Installing kubectl + Helm ==="
curl -LO "https://dl.k8s.io/release/v1.31.1/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf install -y helm
rm -f /tmp/kubectl

echo "=== Step 8: Installing Podman (Docker replacement) ==="
sudo dnf remove -y docker-ce docker-ce-cli containerd.io docker-compose-plugin || true
sudo dnf install -y podman podman-docker
sudo systemctl enable --now podman.socket

echo "✅ Setup complete for $userName on $hostName"