#!/bin/bash
set -e

# ==============================================================================
# Security Hardening Script for Ubuntu 24.04 VPS Nodes
# Run as root: bash setup_server_security.sh
# ==============================================================================

echo "=== [1/4] Enforcing SSH Key Authentication ==="
mkdir -p /etc/ssh/sshd_config.d/
cat << 'SSHEOF' > /etc/ssh/sshd_config.d/00-hardened.conf
PermitRootLogin prohibit-password
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
SSHEOF

# Remove cloud default password configs if present
rm -f /etc/ssh/sshd_config.d/*root-password.conf

systemctl reload ssh || systemctl restart ssh
echo "SSH configured: Key-only access enforced."

echo "=== [2/4] Installing & Enabling Fail2ban ==="
if ! command -v fail2ban-client &> /dev/null; then
    apt-get update && apt-get install -y fail2ban
fi
systemctl enable --now fail2ban
echo "Fail2ban active."

echo "=== [3/4] Configuring UFW Firewall ==="
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 443/tcp comment 'VLESS Reality / HTTPS'
ufw allow 443/udp comment 'Hysteria 2 QUIC'
ufw --force enable
ufw status verbose

echo "=== [4/4] Hardening Complete ==="
