Address table is hosted through a private google docs

# Home Lab Addressing Table

| Device / Service  | IP Address        | MAC Address         | Hostname    | Services / Ports  | Notes                 |
| :---              | :---              | :---                | :---        | :---              | :---                  |
| **Main Server**   | `192.168.100.201` | `10:ff:e0:XX:XX:XX` | `proxmox`   |(`:8006`)          | Main Hypervisor       |
| **Server Plug**   | `192.168.100.200` | `ec:b9:31:XX:XX:XX` | `p100`      | Smart Plug        |
| **Local Router**  | DHCP              | `28:b2:bd:XX:XX:XX` | `miguelHP`  | 
| **EVE-NG**        | `192.168.100.202` | `bc:24:11:XX:XX:XX` | `EVENG`     | 
| **Kali Linux**    | *Unassigned*      | *Unassigned*        | `Kali`      | Security Testing  | Attack / Lab Testing VM |
| **Windows Server**| *Unassigned*      | *Unassigned*        | `WinSer2025`| 
| **Ollama LXC**    | `192.168.100.183` | `bc:24:11:XX:XX:XX` | `Ollama1`   | API (`:11434`)    | Local AI Inference |