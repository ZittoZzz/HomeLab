# 🌐 Personal Homelab & Remote Access Infrastructure

A self-hosted homelab infrastructure built to turn a resource-limited thin client (old Intel Core i3 6th Gen laptop) into a full remote powerhouse by bridging it securely to a high-performance desktop server node at home.

---

## 📌 Project Overview & Motivation

Due to hardware constraints on a daily school/travel laptop (Core i3, 6th Gen), heavy workloads, virtualized environments, and self-hosted services are offloaded entirely to a centralized home server node. 

By leveraging a secure overlay VPN tunnel and segregated internal routing, the remote controller node retains seamless, low-latency, encrypted access to the home laboratory network from anywhere (campus, mobile hotspot, or external Wi-Fi).

---

## 🏗️ Network Architecture & Topology

```
+-------------------------------------------------------------+
|                        Local Network                        |
|                                                             |
|  +---------------+          +-----------------------+       |
|  |  Server Node  | <------> | Internal Router Node  |       |
|  |   (Proxmox)   |          |  (Pi-hole/Tailscale)  |       |
|  +---------------+          +-----------+-----------+       |
+-----------------------------------------|-------------------+
                                          |
                                 +--------v--------+
                                 |   ISP Router    |
                                 +--------+--------+
                                          |
                                     ( Internet )
                                          |
+-----------------------------------------|-------------------+
|                        Remote Network   |                   |
|                                 +-------v---------+         |
|                                 | Controller Node |         |
|                                 | (i3 6th Gen)    |         |
|  - - - - - - - - - - - - - - - -+-----------------+ - - - - |
|       ================ VPN Tunnel (Tailscale) ============= |
+-------------------------------------------------------------+
```

---

## 🗂️ Repository Structure

```tree
├── Architecture/
│   ├── AddressTable.md              # IP allocation, VLANs, and subnet mapping
│   └── Topology.md                  # Detailed network diagrams & flow logic
│
├── Controller Node/
│   ├── P100-controller.md           # Smart plug (Tapo P100) remote power management / WoL
│   └── management.md                # Remote desktop & client-side management setup
│
├── ISP Router/
│   ├── assets/                      # Router GUI screenshots & diagrams
│   └── DHCP-static-configuration.md # Static lease allocations
│
├── Internal Router Node/
│   ├── Tailscale/                   # Mesh VPN & subnet routing configurations
│   ├── pi-hole/                     # Network-wide DNS sinkhole & ad-blocking
│   └── vault-warden/                # Self-hosted password management deployment
│
└── Server Node/Proxmox/Ollama/
    ├── assets/                      # Node specs, container topologies & charts
    └── configs/                     # Proxmox VE configs, VM/LXC templates & Ollama setup
```

---

## ⚙️ Core Infrastructure & Services

| Node / Component | Role & Function | Key Services / Stack |
| :--- | :--- | :--- |
| **Controller Node** | Remote lightweight thin-client used for school & mobile work | SSH, RDP / Parsec, Tailscale Client |
| **Internal Router Node** | Network security, DNS-level filtering, and VPN gateway | Tailscale Subnet Router, Pi-hole, Vaultwarden |
| **Server Node** | Core hypervisor hosting compute workloads and local AI models | Proxmox VE, Docker/LXC, Ollama |
| **ISP Router** | Border gateway with dedicated static DHCP reservations | Static IP mapping, Firewall |
| **Power Automation** | Remote cold boot / power toggling for desktop server node | Tapo P100 Smart Plug |

---

## 🚀 Key Features

- **Anywhere-to-Home Mesh VPN**: Secure peer-to-peer connection via Tailscale subnet routing bypassing CGNAT/ISP firewall restrictions.
- **Offloaded Compute**: Runs demanding development workflows and local LLM inference (Ollama) on the desktop server node via remote sessions.
- **Centralized Privacy & DNS Filtering**: Pi-hole handles network-wide DNS inspection and ad blocking across all connected nodes.
- **Fail-safe Power Management**: Remote power cycle and boot recovery using Tapo smart hardware controllers (P100).
- **Self-Hosted Credentials**: Lightweight Vaultwarden instance running within the local network for unified credential syncing.

---

## 📋 Getting Started & Documentation Reference

1. **Subnet & IP Table**: Check [`Architecture/AddressTable.md`](Architecture/AddressTable.md) for local IP assignments.
2. **Network Flow**: Review [`Architecture/Topology.md`](Architecture/Topology.md) for data flow and routing logic.
3. **VPN Configuration**: See [`Internal Router Node/Tailscale/`](Internal%20Router%20Node/Tailscale/) for subnet routing and exit node setups.
4. **Hypervisor & VM Setup**: Explore [`Server Node/Proxmox/Ollama/`](Server%20Node/Proxmox/Ollama/) for container deployment templates.