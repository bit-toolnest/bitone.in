#!/bin/bash

# ==========================================
# BitOne.in Uninstallation Script
# Removes Website Files, Configs, and SSL
# ==========================================

# Allow DOMAIN override via environment variable
DOMAIN="${DOMAIN:-bitone.in}"
WEB_ROOT="/var/www/$DOMAIN"
NGINX_CONF_AVAILABLE="/etc/nginx/sites-available/$DOMAIN"
NGINX_CONF_ENABLED="/etc/nginx/sites-enabled/$DOMAIN"

echo "⚠️  WARNING: You are about to remove components for $DOMAIN"
echo "--------------------------------------------------------"

# ==========================================
# 1. Remove Website Files
# ==========================================
if [ -d "$WEB_ROOT" ]; then
    echo "📂 Found website files at $WEB_ROOT"
    read -p "❓ Do you want to delete these files? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sudo rm -rf "$WEB_ROOT"
        echo "✅ Website files deleted."
    else
        echo "⏭️  Skipping file deletion."
    fi
else
    echo "⏭️  No website files found."
fi

# ==========================================
# 2. Remove Nginx Configuration
# ==========================================
if [ -f "$NGINX_CONF_AVAILABLE" ] || [ -L "$NGINX_CONF_ENABLED" ]; then
    echo "⚙️  Found Nginx configuration for $DOMAIN"
    read -p "❓ Do you want to remove the Nginx config? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Remove symlink
        sudo rm -f "$NGINX_CONF_ENABLED"
        # Remove actual file
        sudo rm -f "$NGINX_CONF_AVAILABLE"
        
        # Reload Nginx to apply changes
        if systemctl is-active --quiet nginx; then
            sudo systemctl reload nginx
        fi
        echo "✅ Configuration removed and Nginx reloaded."
    else
        echo "⏭️  Skipping config removal."
    fi
else
    echo "⏭️  No Nginx config found."
fi

# ==========================================
# 3. Remove SSL Certificates (Certbot)
# ==========================================
if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "🔒 Found SSL Certificates for $DOMAIN"
    read -p "❓ Do you want to delete these certificates? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sudo certbot delete --cert-name "$DOMAIN" --non-interactive
        echo "✅ Certificates deleted."
    else
        echo "⏭️  Skipping SSL deletion."
    fi
else
    echo "⏭️  No SSL certificates found."
fi

echo "--------------------------------------------------------"
echo "🎉 Cleanup Complete!"
