# VPN Structure & Security Hardening

Sanitized infrastructure blueprints, configurations, and security hardening scripts for resilient, multi-hop VPN deployments.

## Repository Contents
- `servers/netherlands/`: Hysteria 2 server configuration templates.
- `servers/spain/`: Sing-box multi-inbound (VLESS Reality + Hysteria 2) server configuration templates.
- `client/`: Client-side sing-box TUN configuration templates with smart split routing.
- `docs/ARCHITECTURE.md`: Technical topography and security design.
- `scripts/setup_server_security.sh`: Automated Ubuntu 24.04 server hardening script.

## Security Posture
- All servers strictly enforce **ed25519 SSH key authentication** with password logins disabled.
- **UFW** minimal port exposure (SSH 22/tcp, VPN 443/tcp/udp).
- **Fail2ban** active against brute-force intrusion.
- Production secrets, UUIDs, private keys, and subscription tokens are excluded from this repository and stored in local vaults (`~/.vpn_secrets`).
