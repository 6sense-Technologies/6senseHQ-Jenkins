# 🛠️ Jenkins CI/CD Infrastructure – 6sense Technologies

This project sets up a fully Dockerized Jenkins CI/CD pipeline with master-agent architecture, NGINX reverse proxy, SSL, and persistent backups — ready to support all 6sense Technologies projects and client pipelines.

---

## ✅ Features

- Jenkins (LTS) Master in Docker
- Dedicated Jenkins Agent via inbound JNLP
- Docker Compose-based deployment
- Domain connected at `jenkins.6sensehq.com`
- NGINX reverse proxy with HTTPS (Let's Encrypt)
- Automatic SSL certificate renewal
- Swap memory setup on host (2 GB)
- Jenkins persistent volume and backup support
- Buildx-ready setup for Docker builds
- Auto-restart and update via `docker-compose`

---

## 🧰 Stack Used

| Component        | Description                              |
|------------------|------------------------------------------|
| Jenkins (LTS)    | Primary CI/CD server                     |
| Jenkins Agent    | Dockerized JNLP inbound agent            |
| NGINX            | Reverse proxy + SSL termination          |
| Certbot          | Free HTTPS certificates via Let's Encrypt|
| Docker Compose   | Multi-container management               |
| UptimeKuma/Grafana (optional) | Monitoring integration        |

---

## 📁 Project Structure

```
jenkins/
├── docker-compose.yml         # All services
├── nginx/
│   ├── conf.d/jenkins.conf    # NGINX virtual host
│   └── ssl/                   # SSL certs + ACME challenge path
├── backup.sh                  # Manual Jenkins volume backup
```

---

## 🚀 Steps Taken to Make Jenkins Live

### 1. Provisioned a VPS
- 8 GB RAM, 2 vCPU server from Hetzner
- Ubuntu 22.04 LTS
- Domain `jenkins.6sensehq.com` pointed via DNS (Cloudflare, proxy off)

### 2. Installed Docker & Docker Compose
```bash
sudo apt update
sudo apt install -y docker.io docker-compose
```

### 3. Configured Dockerized Jenkins Master + Agent
- `docker-compose.yml` sets up:
  - Jenkins master
  - Jenkins agent with JNLP connection
  - NGINX reverse proxy
  - Certbot renewal container

### 4. Setup SSL (Let's Encrypt)
```bash
docker run --rm \
  -v $(pwd)/nginx/ssl:/etc/letsencrypt \
  -v $(pwd)/nginx/ssl:/var/www/certbot \
  certbot/certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  -d jenkins.6sensehq.com \
  --email <your-email> --agree-tos --no-eff-email
```

### 5. Configured NGINX
- Forwarded all HTTP traffic to Jenkins
- Enabled HTTPS using Let's Encrypt certs

### 6. Created Swap Memory
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### 7. Registered Docker Agent
- Created a new permanent agent in Jenkins UI
- Added JNLP secret and agent name in `docker-compose.yml`
- Added wait logic for Jenkins readiness in `entrypoint`

### 8. Backups
- `backup.sh` script backs up `jenkins_home` volume:
```bash
./backup.sh
```

---

## 🔧 Useful Commands

| Task                      | Command |
|---------------------------|---------|
| Start Jenkins             | `docker-compose up -d` |
| Stop Jenkins              | `docker-compose down`  |
| View logs                 | `docker logs jenkins`  |
| Force cert renewal        | `docker exec certbot certbot renew --force-renewal` |
| Backup Jenkins            | `./backup.sh`           |

---

## 🟢 Update Guide
```
# Backup Jenkins before proceed (Must)
docker compose pull jenkins infisical nginx certbot
docker compose build --pull --no-cache agent
docker compose --env-file .env up -d --remove-orphans
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
```


## 🟢 Status: LIVE

Access Jenkins:  
🔗 [https://jenkins.6sensehq.com](https://jenkins.6sensehq.com)
