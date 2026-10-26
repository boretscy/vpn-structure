# VPN & AI Routing Infrastructure Architecture

## 1. Overview & Multi-Hop Topography
The infrastructure is engineered for resilience against DPI (Deep Packet Inspection), ISP throttling, and geo-restrictions for AI platforms (Gemini, Claude, ChatGPT), with strict user tier isolation.

```
                  ┌─────────────────────────────────────────────────────────┐
                  │                     Client Devices                      │
                  └────────────┬────────────────────────────┬───────────────┘
                               │                            │
             [Family Phones: Streisand/v2rayNG]    [Guests/Friends Phones]
                               │                            │
                               ▼                            ▼
                 ┌──────────────────────────┐  ┌──────────────────────────┐
                 │    H1Cloud SP (56598)    │  │    H1Cloud PL (56581)    │
                 │   Node: es6.h1cloud.net  │  │   Node: pl3.h1cloud.net  │
                 │  VLESS Reality + Vision  │  │  VLESS Reality + Vision  │
                 └──────────────────────────┘  └──────────────────────────┘

                               [Admin macOS / Workstations]
                                            │
                     ┌──────────────────────┴──────────────────────┐
                     │                                             │
           [Primary: UDP 443]                            [Backup: TCP/UDP 443]
            Hysteria 2                                    VLESS Reality / Hy2
                     │                                             │
                     ▼                                             ▼
        ┌─────────────────────────┐                   ┌─────────────────────────┐
        │     Netherlands VPS     │                   │        Spain VPS        │
        │   (YOUR_NL_SERVER_IP)   │                   │   (YOUR_ES_SERVER_IP)   │
        └────────────┬────────────┘                   └────────────┬────────────┘
                     │                                             │
        ┌────────────┴────────────┐                   ┌────────────┴────────────┐
        ▼                         ▼                   ▼                         ▼
 [Direct General]          [AI Upstream]       [Direct General]          [AI Failover Pool]
 (EU Traffic)              (Xray SOCKS5)       (EU Traffic)              (sing-box URLTest)
                                  │                                             │
                                  └──────────────────────┬──────────────────────┘
                                                         │
                                    ┌────────────────────┴────────────────────┐
                                    ▼                                         ▼
                       ┌─────────────────────────┐               ┌─────────────────────────┐
                       │   H1Cloud SWE (42362)   │               │   H1Cloud FL (42298)    │
                       │   Node: se2.h1cloud.net │  ◄─Failover─► │   Node: fi3.h1cloud.net │
                       │    (Primary AI Node)    │               │    (Backup AI Node)     │
                       └─────────────────────────┘               └─────────────────────────┘
                                    │                                         │
                                    └────────────────────┬────────────────────┘
                                                         │
                                                         ▼
                                            [AI Endpoints: Google, Anthropic]
```

---

## 2. Server Nodes & Fleet Segmentation

### 2.1. Dedicated Gateway VPS (Entry Points)
1. **Netherlands Primary Node (`YOUR_NL_SERVER_IP`):**
   - High-speed QUIC/UDP entry point via standalone Hysteria 2.
   - Internal routing to SWE (`42362`) via port `40001` with failover to FL (`42298`) via port `40002`.
   - Security: ed25519 SSH key only, UFW (`22/tcp`, `443/udp`), fail2ban.
   - Monitored by `vpn-watchdog.service` (lightweight HEAD probe, calibrated 26.10.2026).
2. **Spain Dual-Stack Node (`YOUR_ES_SERVER_IP`):**
   - Sing-box unified daemon running VLESS Reality (TCP 443) and Hysteria 2 (UDP 443).
   - Upstream AI pool `ai_failover` (`interval: 3m`, `tolerance: 300ms`).
   - Security: ed25519 SSH key only, UFW (`22/tcp`, `443/tcp`, `443/udp`), fail2ban.
   - Monitored by `vpn-watchdog.service` with flap-damping filter.

### 2.2. H1Cloud Server Fleet (Distribution Matrix)
* **`56598` - SP Family Only (Spain, `es6.h1cloud.net`):** Dedicated exclusively to family members. VLESS Reality + Vision + Self-steal.
* **`56581` - PL (Poland, `pl3.h1cloud.net`):** Dedicated to colleagues, friends, and neighbors with isolated traffic quota.
* **`42362` - SWE Antigravity only (Sweden, `se2.h1cloud.net`):** Isolated upstream tunnel exclusively for Google AI / Antigravity traffic.
* **`42298` - FL Antigravity only (Finland, `fi3.h1cloud.net`):** Hot standby upstream tunnel for Google AI / Antigravity traffic.
* **`26479` (DE) & `21031` (US):** Blocked by Russian TSPU / crash loop. **Scheduled for decommissioning on 27.10.2026.**

---

## 3. Client Distribution & Security Strategy
* **Telegram Delivery Bypass:** Due to protocol-level degradation and blocking of Telegram in Russia, keys are distributed via offline direct QR code scanning or Apple AirDrop.
* **Secret Isolation:** Production secrets, subscription tokens, and server credentials are never stored in public repositories and reside solely in the local `~/.vpn_secrets` vault (`chmod 600`).
