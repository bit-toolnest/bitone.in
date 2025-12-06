#!/bin/bash

# ==========================================
# BitOne.in Deployment Script
# Focus: Minimal Static Website (No Headers/Caching/API)
# ==========================================

DOMAIN="bitone.in"
WEB_ROOT="/var/www/$DOMAIN/html"
NGINX_CONF_FILE="/etc/nginx/sites-available/$DOMAIN"
EMAIL="bitresearch2006@gmail.com"

# Get the directory where this script is running
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Define the source directory
SOURCE_DIR="$SCRIPT_DIR/site"

# 1. Check Root Privileges
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Error: Please run as root (sudo ./deploy_bitone.sh)"
  exit 1
fi

echo "🚀 Starting deployment for $DOMAIN..."

# 2. Validate Source Directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: The folder '$SOURCE_DIR' was not found."
    echo "   Make sure you have a folder named 'site' next to this script."
    exit 1
fi

# 3. Install Nginx (If not installed)
if ! command -v nginx &> /dev/null; then
    echo "📦 Nginx not found. Installing..."
    apt update
    apt install nginx -y
    systemctl enable nginx
    systemctl start nginx
    echo "✅ Nginx installed."
else
    echo "✅ Nginx is already installed."
fi

# 4. Deploy Website Content
echo "📂 Copying content from $SOURCE_DIR to $WEB_ROOT..."

# Create web root if missing
mkdir -p "$WEB_ROOT"

# Copy all files/folders (Clean overwrite)
cp -rf "$SOURCE_DIR/"* "$WEB_ROOT/"

# Set Permissions
chown -R www-data:www-data "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"

echo "✅ Website content updated."

# 5. Nginx Configuration (Minimal)
echo "⚙️  Updating Nginx configuration for $DOMAIN..."

cat > "$NGINX_CONF_FILE" <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $WEB_ROOT;
    index index.html index.htm;

    # General Website Handling
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Enable the site
ln -sf "$NGINX_CONF_FILE" /etc/nginx/sites-enabled/

# Remove default configuration to avoid conflicts
rm -f /etc/nginx/sites-enabled/default

# Test and Reload
nginx -t
if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "✅ Nginx configuration updated."
else
    echo "❌ Nginx config syntax error. Check $NGINX_CONF_FILE"
    exit 1
fi

# 6. SSL Setup (Certbot)
echo "🔒 Checking SSL..."

if ! command -v certbot &> /dev/null; then
    apt install certbot python3-certbot-nginx -y
fi

if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "✅ SSL Certificate found. Renewing if necessary..."
    certbot renew
else
    echo "🚀 Requesting new SSL Certificate..."
    certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect
fi

echo "============================================="
echo "🎉 Deployment Complete!"
echo "   Website: https://$DOMAIN"
echo "============================================="