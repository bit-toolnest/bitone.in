#!/bin/bash

# ==========================================
# BitOne.in Uninstallation Script
# Removes Website Files, Configs, SSL, and (Optional) Nginx
# ==========================================

DOMAIN="bitone.in"
WEB_ROOT="/var/www/$DOMAIN"
NGINX_CONF_AVAILABLE="/etc/nginx/sites-available/$DOMAIN"
NGINX_CONF_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"

# 1. Check Root Privileges
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Error: Please run as root (sudo ./uninstall_bitone.sh)"
  exit 1
fi

echo "⚠️  WARNING: You are about to remove components for $DOMAIN"
echo "--------------------------------------------------------"

# ==========================================
# 2. Remove Website Files
# ==========================================
if [ -d "$WEB_ROOT" ]; then
    echo "📂 Found website files at $WEB_ROOT"
    read -p "❓ Do you want to delete these files? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -rf "$WEB_ROOT"
        echo "✅ Website files deleted."
    else
        echo "⏭️  Skipping file deletion."
    fi
else
    echo "⏭️  No website files found."
fi

# ==========================================
# 3. Remove Nginx Configuration
# ==========================================
if [ -f "$NGINX_CONF_AVAILABLE" ] || [ -L "$NGINX_CONF_ENABLED" ]; then
    echo "⚙️  Found Nginx configuration for $DOMAIN"
    read -p "❓ Do you want to remove the Nginx config? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Remove symlink
        rm -f "$NGINX_CONF_ENABLED"
        # Remove actual file
        rm -f "$NGINX_CONF_AVAILABLE"
        
        # Reload Nginx to apply changes
        if systemctl is-active --quiet nginx; then
            systemctl reload nginx
        fi
        echo "✅ Configuration removed and Nginx reloaded."
    else
        echo "⏭️  Skipping config removal."
    fi
else
    echo "⏭️  No Nginx config found."
fi

# ==========================================
# 4. Remove SSL Certificates (Certbot)
# ==========================================
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "🔒 Found SSL Certificates for $DOMAIN"
    read -p "❓ Do you want to delete these certificates? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        certbot delete --cert-name "$DOMAIN" --non-interactive
        echo "✅ Certificates deleted."
    else
        echo "⏭️  Skipping SSL deletion."
    fi
else
    echo "⏭️  No SSL certificates found."
fi

# ==========================================
# 5. Remove Nginx & Certbot Software (Optional)
# ==========================================
echo "--------------------------------------------------------"
echo "📦 SOFTWARE REMOVAL (Nginx & Certbot)"
echo "⚠️  NOTE: Only say 'Yes' if this server is NOT hosting other websites."
read -p "❓ Do you want to uninstall Nginx and Certbot entirely from the OS? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🗑️  Uninstalling Nginx and Certbot..."
    apt remove --purge nginx nginx-common nginx-core certbot python3-certbot-nginx -y
    apt autoremove -y
    echo "✅ Nginx and Certbot uninstalled."
else
    echo "⏭️  Skipping software uninstallation."
fi

echo "--------------------------------------------------------"
echo "🎉 Cleanup Complete!"