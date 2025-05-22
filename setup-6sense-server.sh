#!/bin/bash

echo "🔧 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "🔐 Installing essential packages..."
sudo apt install -y curl git unzip ufw fail2ban build-essential

echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

echo "📦 Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "🟩 Installing Node.js (LTS)..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

echo "📂 Installing PM2 globally..."
sudo npm install -g pm2

echo "🔧 Setting up UFW (Firewall)..."
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

echo "🛡️ Enabling Fail2Ban for SSH protection..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "💾 Setting up swap (2GB)..."
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

echo "✅ Server base setup completed!"
echo "👉 Now: clone your repo, deploy apps, or install GitHub Actions runner."

# chmod +x setup-6sense-server.sh
# ./setup-6sense-server.sh
