# VPN & AI Routing Infrastructure Architecture

## 1. Overview & Multi-Hop Topography
The infrastructure is engineered for resilience against DPI (Deep Packet Inspection), ISP throttling, and geo-restrictions for AI platforms (Gemini, Claude, ChatGPT).

```
               [ User Devices: Mac (sing-box TUN) / iPhone (Streisand/V2Box) ]
                                              │
                    ┌─────────────────────────┴─────────────────────────┐
                    │                                                   │
          [Primary: UDP 443]                                  [Backup: TCP 443]
           Hysteria 2 Protocol                                VLESS + Reality Protocol
                    │                                                   │
                    ▼                                                   ▼
       ┌────────────────────────┐                          ┌────────────────────────┐
       │     Netherlands VPS    │                          │       Spain VPS        │
       │    (YOUR_NL_SERVER_IP)    │                          │    (YOUR_ES_SERVER_IP)     │
       └───────────┬────────────┘                          └───────────┬────────────┘
                   │                                                   │
       ┌───────────┴────────────┐                          ┌───────────┴────────────┐
       ▼                        ▼                          ▼                        ▼
[Direct Internet]        [AI Outbound]              [Direct Internet]        [AI Outbound Failover]
(EU / General)        (US SOCKS5 Exit)              (EU / General)           (H1 Cloud SE2 / FI3)
                                                                                       │
                                                                                       ▼
                                                                           [AI Services: Google, Anthropic]
```

---

## 2. Server Nodes

### 1. Netherlands Primary Node (`YOUR_NL_SERVER_IP`)
- **OS:** Ubuntu 24.04 LTS
- **Core Role:** High-speed QUIC/UDP entry point via standalone Hysteria 2.
- **Port:** 443/UDP.
- **Security:**
  - SSH ed25519 key-only authentication (`PasswordAuthentication no`, `PermitRootLogin prohibit-password`).
  - UFW active: `deny incoming`, `allow outgoing`, `22/tcp`, `443/udp`.
  - Fail2ban active.
- **AI Routing:** Internal SOCKS5 upstream tunnel on `127.0.0.1:40001` with domain sniffing for AI endpoints.

### 2. Spain Dual-Stack Node (`YOUR_ES_SERVER_IP`)
- **OS:** Ubuntu 24.04 LTS
- **Core Role:** Sing-box unified daemon running both VLESS Reality (TCP 443) and Hysteria 2 (UDP 443) simultaneously on port 443.
- **Security:**
  - SSH ed25519 key-only authentication.
  - UFW active: `deny incoming`, `allow outgoing`, `22/tcp`, `443/tcp`, `443/udp`.
  - Fail2ban active.
- **Stealth Camouflage:** VLESS Reality SNI masking using `gateway.icloud.com`.
- **AI Routing:** Sing-box `urltest` upstream failover pool over H1 Cloud nodes.

---

## 3. Client Architecture (macOS)
- Managed via sing-box TUN interface (`utun10`).
- Local Clash API running on `127.0.0.1:9090`.
- Intelligent split-routing:
  - `.ru`, `.рф`, and Russian domestic CDNs route direct without tunnel latency.
  - DNS resolved securely via Cloudflare DoH (`https://1.1.1.1/dns-query`) for foreign traffic and Yandex DoH (`https://77.88.8.8/dns-query`) for Russian domains.
