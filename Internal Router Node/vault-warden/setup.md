# Vaultwarden Complete Deployment & Operations Guide

> **Vaultwarden** (formerly *bitwarden_rs*) is an alternative, lightweight implementation of the Bitwarden server API written in Rust. It is fully compatible with upstream Bitwarden desktop, mobile, browser extensions, and CLI clients, while requiring minimal system resources.

---

## Table of Contents

1. [Overview & Architecture](#1-overview--architecture)
2. [Prerequisites](#2-prerequisites)
3. [Deployment Options](#3-deployment-options)
   - [Standard Docker Compose (SQLite)](#method-a-standard-docker-compose-sqlite)
4. [Environment Configuration (`.env`)](#4-environment-configuration-env)
   - [Security & Access Control](#security--access-control)
   - [Admin Token Generation (Argon2)](#admin-token-generation-argon2)
   - [WebSocket & Push Notifications](#websocket--push-notifications)
5. [Reverse Proxy & SSL Configurations](#5-reverse-proxy--ssl-configurations)
   - [Caddy (Recommended / Automated HTTPS)](#caddy)
6. [Admin Panel & User Management](#6-admin-panel--user-management)
7. [Connecting Bitwarden Clients](#7-connecting-bitwarden-clients)
8. [Official GitHub & Reference Links](#8-official-github--reference-links)

---

## 1. Overview & Architecture

Vaultwarden serves as a self-hosted backend that replaces the official .NET Bitwarden server stack.

### Key Features & Differences:
- **Resource Footprint:** Operates smoothly with under 50 MB of RAM (compared to ~2-3 GB for official Bitwarden instances).
- **Client Compatibility:** Seamlessly works with all official Bitwarden clients (iOS, Android, Chrome/Firefox extensions, Desktop, CLI).
- **Built-in Web Vault:** Pre-packaged with the Bitwarden Web Vault interface.
- **Premium Feature Emulation:** Unlocks organization sharing, vault health reports, U2F/FIDO2, Duo 2FA, and Bitwarden Send without external subscriptions.
- **Database Support:** SQLite (default/embedded), PostgreSQL, and MySQL/MariaDB.

---

## 2. Prerequisites

1. **Linux Server / VPS:** Ubuntu 22.04/24.04, Debian 12, Alpine, or any modern Docker-capable OS.
2. **Docker Engine & Docker Compose Plugin:**
   ```bash
   # Install Docker on Debian/Ubuntu
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```
3. **Public Fully Qualified Domain Name (FQDN):** E.g., `vault.yourdomain.com`.
4. **SSL/TLS Requirement:** The Bitwarden client apps rely on the modern browser `WebCrypto API`, which **strictly requires HTTPS**. HTTP is only allowed for `localhost`.

---

## 3. Deployment Options

### Standard Docker Compose (SQLite)

Create a dedicated directory and structure:
```bash
mkdir -p /opt/vaultwarden && cd /opt/vaultwarden
```

Create `docker-compose.yml`:
```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      - DOMAIN=https://vault.home
      - SIGNUPS_ALLOWED=false
      - INVITATIONS_ALLOWED=true
      - WEBSOCKET_ENABLED=true
      - SHOW_PASSWORD_HINT=false
      - LOG_FILE=/data/vaultwarden.log
      - LOG_LEVEL=warn
      - EXTENDED_LOGGING=true
    volumes:
      - ./vw-data:/data
    ports:
      - "127.0.0.1:8080:80"
```

Start the container:
```bash
docker compose up -d
```

---

### Method C: Docker CLI Quickstart

```bash
docker run -d \
  --name vaultwarden \
  --restart unless-stopped \
  -e DOMAIN="https://vault.home" \
  -e SIGNUPS_ALLOWED=true \
  -v /opt/vaultwarden/vw-data:/data \
  -p 127.0.0.1:8080:80 \
  vaultwarden/server:latest
```

---

## 4. Environment Configuration (`.env`)

Vaultwarden supports configuration via an `.env` file located in the working directory or injected as container environment variables.

### Security & Access Control

| Variable | Default | Description |
| :--- | :--- | :--- |
| `DOMAIN` | *None* | Full public URL including `https://` protocol and port if non-standard. |
| `SIGNUPS_ALLOWED` | `true` | Set to `false` after initial registration to prevent public sign-ups. |
| `INVITATIONS_ALLOWED` | `true` | Allows existing organization admins to invite new users even if signups are closed. |
| `SIGNUPS_DOMAINS_WHITELIST` | *None* | Comma-separated list of approved email domains (e.g. `example.com,corp.com`). |
| `ADMIN_TOKEN` | *None* | Enables access to `/admin` dashboard. Must be an Argon2 hash. |
| `EMERGENCY_ACCESS_ALLOWED` | `true` | Enables emergency access contact fallback. |

---

### Admin Token Generation (Argon2)

Never store plaintext tokens. Generate an Argon2 hashed secret using the Vaultwarden binary directly:

```bash
docker run --rm -it vaultwarden/server:latest /vaultwarden hash --preset owasp
```

You will be prompted for your password:
```text
Password: [Type your secure password]
Hash: $argon2id$v=19$m=65536,t=3,p=4$6q2e...
```

Paste the resulting hash into your `docker-compose.yml` or `.env`:
```yaml
environment:
  - ADMIN_TOKEN='$$argon2id$$v=19$$m=65536,t=3,p=4$$...' # Double $ in Compose files to avoid variable interpolation
```

---

### WebSocket & Push Notifications

WebSocket support provides real-time synchronization between browser extensions and mobile devices whenever a credential is created, updated, or deleted.

```ini
WEBSOCKET_ENABLED=true
```

> **Note on Mobile Push Notifications:**
> Official Bitwarden push notifications require a Relay Gateway or Bitwarden Push Registration keys. If push notifications are not configured, mobile clients sync periodically or on app launch.

---

## 5. Reverse Proxy & SSL Configurations

Vaultwarden listens on port `80` inside the container. Route traffic through a reverse proxy to terminate TLS/SSL.

### Caddy
Caddy automatically provisions and renews Let's Encrypt / ZeroSSL certificates with minimal configuration.

```caddyfile
vault.yourdomain.com {
    encode gzip zstd

    # Proxy to Vaultwarden container
    reverse_proxy 127.0.0.1:8080 {
        # WebSocket support is native and automatic in Caddy v2
        header_up X-Real-IP {remote_host}
    }
}
```

---


## 6. Admin Panel & User Management

Access the administration panel at:
```text
https://vault.home/admin
```

### Capabilities of the Admin Portal:
1. **User Management:** View registered users, delete deactivated accounts, disable accounts, invite users manually, and revoke user sessions.
2. **Organization Oversight:** Manage sharing policies and view active organization seats.
3. **Diagnostics:** Test SMTP outgoing mail, inspect configuration variables, and check database connection metrics.
4. **Broadcast Notices:** Broadcast informational banners to users across the Web Vault.

---


## 7. Connecting Bitwarden Clients

To connect desktop apps, mobile devices, or browser extensions to your self-hosted Vaultwarden server:

1. Open the Bitwarden extension or application.
2. On the initial login screen, click the **Settings / Gear Icon** (⚙️) in the top corner.
3. Under **Server URL / Self-hosted Environment**, enter your domain:
   ```text
   https://vault.home
   ```
4. Leave other specialized URL fields blank (they automatically derive from the root URL).
5. Click **Save**.
6. Log in with your registered email and Master Password.

---

## 8. Official GitHub & Reference Links

- **GitHub Repository:** [https://github.com/dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden)
- **Official Documentation & Wiki:** [https://github.com/dani-garcia/vaultwarden/wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- **Environment Template (`.env.template`):** [https://github.com/dani-garcia/vaultwarden/blob/main/.env.template](https://github.com/dani-garcia/vaultwarden/blob/main/.env.template)
- **Docker Hub Repository:** [https://hub.docker.com/r/vaultwarden/server](https://hub.docker.com/r/vaultwarden/server)
- **Official Discussion Forum:** [https://github.com/dani-garcia/vaultwarden/discussions](https://github.com/dani-garcia/vaultwarden/discussions)