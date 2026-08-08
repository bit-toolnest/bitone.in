#!/bin/bash

# ==========================================
# BitOne.in Deployment Script
# Focus: Minimal Static Website (No Headers/Caching/API)
# ==========================================

# Allow DOMAIN override via environment variable
DOMAIN="${DOMAIN:-bitone.in}"
WEB_ROOT="/var/www/$DOMAIN/html"
NGINX_CONF_FILE="/etc/nginx/sites-available/$DOMAIN"
EMAIL="bitresearch2006@gmail.com"

# Get the directory where this script is running
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/site"

echo "🚀 Starting deployment for $DOMAIN..."

# 1. Validate Source Directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: The folder '$SOURCE_DIR' was not found."
    echo "   Make sure you have a folder named 'site' next to this script."
    exit 1
fi

# 2. Deploy Website Content
echo "📂 Copying content from $SOURCE_DIR to $WEB_ROOT..."

# Create web root if missing
sudo mkdir -p "$WEB_ROOT"

# Copy all files/folders (Clean overwrite)
sudo cp -rf "$SOURCE_DIR/"* "$WEB_ROOT/"

# Set Permissions
sudo chown -R www-data:www-data "$WEB_ROOT"
sudo chmod -R 755 "$WEB_ROOT"

echo "✅ Website content updated."

# 3. Nginx Configuration (Minimal)
echo "⚙️  Updating Nginx configuration for $DOMAIN..."

sudo tee "$NGINX_CONF_FILE" > /dev/null <<EOF
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
sudo ln -sf "$NGINX_CONF_FILE" /etc/nginx/sites-enabled/

# Remove default configuration to avoid conflicts
sudo rm -f /etc/nginx/sites-enabled/default

# Test and Reload
sudo nginx -t
if [ $? -eq 0 ]; then
    sudo systemctl reload nginx
    echo "✅ Nginx configuration updated."
else
    echo "❌ Nginx config syntax error. Check $NGINX_CONF_FILE"
    exit 1
fi

# 4. SSL Setup (Certbot)
echo "🔒 Checking SSL..."

if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "✅ SSL Certificate found. Renewing if necessary..."
    sudo certbot renew
else
    echo "🚀 Requesting new SSL Certificate..."
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL --redirect
fi

echo "============================================="
echo "🎉 Deployment Complete!"
echo "   Website: https://$DOMAIN"
echo "============================================="
