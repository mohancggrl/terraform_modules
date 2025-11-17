#!/bin/bash
set -e
set -o pipefail
exec > >(tee /var/log/vault-bootstrap.log | logger -t user-data -s 2>/dev/console) 2>&1

###############################################################################
# LOGGING → Writes to EC2 Console + /var/log/vault-bootstrap.log
###############################################################################

echo "===== Vault Bootstrap Script Started at $(date) ====="

###############################################################################
# VARIABLES FROM TERRAFORM
###############################################################################
userName="${vault_server_username}"
ssh_key="${vault_ssh_public_key}"
hostname="${vault_server_hostname}"

OUT_ROOT_TOKEN_FILE="/opt/hashicorp_root_roken.txt"
INIT_JSON="/root/vault_init.json"
VAULT_CONFIG="/etc/vault/vault.hcl"
SYSTEMD_UNIT="/etc/systemd/system/vault.service"

echo "[INFO] User: $userName | Hostname: $hostname"
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

###############################################################################
# 2️⃣ INSTALL VAULT
###############################################################################
echo "[INFO] Adding Vault Yum repo"
cat >/etc/yum.repos.d/vault.repo <<EOF
[vault]
name=Hashicorp Vault
baseurl=https://rpm.releases.hashicorp.com/RHEL/9/x86_64/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF

dnf -y makecache
dnf install -y vault curl python3

echo "[INFO] Creating Vault config"
mkdir -p /etc/vault
cat > "$VAULT_CONFIG" <<EOF
ui = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
EOF

mkdir -p /opt/vault/data
chown -R vault:vault /opt/vault
chmod 750 /opt/vault

###############################################################################
# 3️⃣ SYSTEMD SERVICE
###############################################################################
echo "[INFO] Installing Vault systemd service"
cat > "$SYSTEMD_UNIT" <<EOF
[Unit]
Description=Vault Server
After=network-online.target
Wants=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/bin/vault server -config=/etc/vault/vault.hcl
Restart=on-failure
LimitNOFILE=65536
CapabilityBoundingSet=CAP_IPC_LOCK
AmbientCapabilities=CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now vault

###############################################################################
# 4️⃣ INIT & UNSEAL VAULT
###############################################################################
echo "[INFO] Setting Vault address"
export VAULT_ADDR="http://127.0.0.1:8200"

echo "[INFO] Waiting for Vault to start..."
sleep 5

echo "[INFO] Checking if Vault initialized..."
if vault status >/dev/null 2>&1; then
    echo "[INFO] Vault already initialized"
    exit 0
fi

echo "[INFO] Running Vault init"
vault operator init -key-shares=5 -key-threshold=3 -format=json > "$INIT_JSON"

echo "[INFO] Extracting Unseal Keys"
UNSEAL_KEY1=$(python3 - <<'PY'
import json
d=json.load(open("/root/vault_init.json"))
print(d["unseal_keys_b64"][0])
PY
)

UNSEAL_KEY2=$(python3 - <<'PY'
import json
d=json.load(open("/root/vault_init.json"))
print(d["unseal_keys_b64"][1])
PY
)

UNSEAL_KEY3=$(python3 - <<'PY'
import json
d=json.load(open("/root/vault_init.json"))
print(d["unseal_keys_b64"][2])
PY
)

echo "[INFO] Extracting Root Token"
ROOT_TOKEN=$(python3 - <<'PY'
import json
d=json.load(open("/root/vault_init.json"))
print(d["root_token"])
PY
)

echo "[INFO] Unsealing Vault..."
vault operator unseal "$UNSEAL_KEY1"
vault operator unseal "$UNSEAL_KEY2"
vault operator unseal "$UNSEAL_KEY3"

###############################################################################
# 5️⃣ SAVE ROOT TOKEN
###############################################################################
echo "[INFO] Saving Root Token to $OUT_ROOT_TOKEN_FILE"
echo "$ROOT_TOKEN" > "$OUT_ROOT_TOKEN_FILE"
chmod 600 "$OUT_ROOT_TOKEN_FILE"

###############################################################################
# DONE
###############################################################################
echo "===== Vault Install Complete ====="
echo "UI: http://<server-ip>:8200/ui"
echo "Root Token saved at: $OUT_ROOT_TOKEN_FILE"
echo "Logs: /var/log/vault-bootstrap.log"