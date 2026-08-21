# Pi-hole DNS Infrastructure Documentation

**Document Version:** 1.0  
**Last Updated:** August 2026  
**Environment:** Home Lab / Local Network Infrastructure  
**Service Role:** Network-Wide DNS Sinkhole & Local Name Resolution  

---

## 1. System & Host Overview

| Attribute | Specification / Configuration |
| :--- | :--- |
| **Hostname** | `miguelhp`|
| **Deployment Type** | Bare Metal |
| **Operating System** | Linux Mint |
| **Hardware / Allocation** | 6 CPU, 16 MB RAM, 512 GB Storage |
| **Static IPv4 Address** | `192.168.100.168/24`|
| **Default Gateway** | `192.168.100.1` |
| **Network Interface** | `eth0` |
| **Web Interface URL** | `http://192.168.100.168/admin` |

---

## 2. Network Topology & Routing Architecture

```
[ Client Devices (LAN) ]
          │
          │ (1) DNS Query (UDP/TCP 53)
          ▼
┌───────────────────────────────────────┐
│           Pi-hole Instance            │
│  - Ad / Tracker Blocking (Gravity)    │
│  - Local DNS Records (custom.list)    │
│  - Conditional Forwarding             │
└──────────────────┬────────────────────┘
                   │
                   │ (2) Upstream Resolution (if not blocked / local)
                   ▼
┌───────────────────────────────────────┐
│     Upstream DNS / Recursive DNS      │
│  - Quad9 (9.9.9.9) / Cloudflare (1.1) │
│  - OR Local Unbound (127.0.0.1#5335)  │
└───────────────────────────────────────┘
```

### DHCP & DNS Handshake Configuration
* **DHCP Server:** Handled by main router.
* **DHCP DNS Option (Option 6):** Pointed directly to `192.168.100.168`.
* **Secondary DNS Field:** Left empty to prevent DNS bypass on client endpoints.

---

## 3. Core Service Configuration

### Main Configuration Files
* **FTL Engine Config:** `/etc/pihole/pihole-FTL.conf`
miguel@MiguelHp:~$ sudo cat /etc/pihole/pihole-FTL.conf
WEB_PORT=8088


### Upstream DNS Settings
* **Primary Upstream:** `1.1.1.1` (Cloudflare) / `9.9.9.9` (Quad9 Filtered + ECS)
* **Secondary Upstream:** `1.0.0.1` / `149.112.112.112`
* **DNSSEC Validation:** Enabled
* **Rate Limiting:** Default (1000 queries per 60 seconds per client)

---

## 4. Blocklists, Adlists & Gravity Policies

### Active Adlists
1. **StevenBlack Unified Hosts (Default):**
   * URL: `https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts`
   * Target: General advertising, malware, and adware domains.


### Local Static DNS Records (`custom.list`)
| Domain Name | IP Address | Description |
| :--- | :--- | :--- |
| `vault.home` | `192.168.100.168` | vault warden |
| `proxmox.homelab` | `192.168.100.168` | Proxmox VE Dashboard |
| `pihole.homelab` | `192.168.1.168` | Pi-hole Admin Interface |

---

## 5. Maintenance & Operational Runbook

### Service Administration Commands
```bash
# Check Pi-hole service status
sudo systemctl status pihole-FTL

# Restart the DNS engine
sudo systemctl restart pihole-FTL

# Force update blocklists (Gravity database)
pihole -g

# Update Pi-hole core and web interface components
pihole -up

# Reset admin web interface password
pihole -a -p
```

### Diagnostic Commands
```bash
# Monitor live DNS queries via CLI
pihole -t

# Test blocking resolution from client machine
nslookup doubleclick.net 192.168.1.53

# Check open listening ports
sudo ss -tulpn | grep -E ':(53|80)'
```

---

## 6. Backup & Disaster Recovery (DR)

* **Teleporter Backup Schedule:** Weekly automated export or before major updates.
* **Manual Export Process:**
  1. Navigate to **Settings** $\rightarrow$ **Teleporter**.
  2. Click **Backup** to download `pi-hole-teleporter_*.tar.gz`.
* **Disaster Recovery Steps:**
  1. Deploy fresh host OS / container with identical IP (`192.168.100.168`).
  2. Install Pi-hole via official curl script or Docker compose.
  3. Navigate to **Settings** $\rightarrow$ **Teleporter** $\rightarrow$ **Restore** and upload archive.
  4. Run `pihole -g` to compile gravity records.