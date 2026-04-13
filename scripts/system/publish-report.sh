#!/bin/bash
# Usage: publish-report.sh <html-file-path> <subdomain>
# Example: publish-report.sh /root/.openclaw/workspace/Cenovus_POV_Dashboard.html cenovus-pov

FILE="$1"
SUBDOMAIN="$2"

if [ -z "$FILE" ] || [ -z "$SUBDOMAIN" ]; then
  echo "ERROR: Usage: publish-report.sh <html-file-path> <subdomain>"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "ERROR: File not found: $FILE"
  exit 1
fi

DOMAIN="${SUBDOMAIN}.slokar.cloud"
WEBROOT="/var/www/${SUBDOMAIN}"

# Create web directory and copy file
mkdir -p "$WEBROOT"
cp "$FILE" "$WEBROOT/index.html"

# Create Nginx config if it doesn't exist
if [ ! -f "/etc/nginx/sites-available/${SUBDOMAIN}" ]; then
cat > /etc/nginx/sites-available/${SUBDOMAIN} << NGINXEOF
server {
    listen 80;
    server_name ${DOMAIN};
    root ${WEBROOT};
    index index.html;
    location / { try_files \$uri \$uri/ =404; }
}
NGINXEOF
  ln -s /etc/nginx/sites-available/${SUBDOMAIN} /etc/nginx/sites-enabled/
fi

# Get SSL cert if needed
if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
  certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email slokar@gmail.com
fi

# Reload Nginx
nginx -t && systemctl reload nginx

# Update reports index
TITLE=$(grep -o '<title>[^<]*</title>' "$FILE" | sed 's/<[^>]*>//g' | head -1)
if [ -z "$TITLE" ]; then
  TITLE="$SUBDOMAIN"
fi
DATE=$(date '+%Y-%m-%d')

# Add to index if not already there
if ! grep -q "$DOMAIN" /var/www/reports/index.html; then
  sed -i "s|<!-- NEW_ENTRY -->|<li><a href=\"https://${DOMAIN}\">${TITLE}</a> <span class=\"date\">${DATE}</span></li>\n    <!-- NEW_ENTRY -->|" /var/www/reports/index.html
fi

echo "SUCCESS: Published to https://${DOMAIN}"
echo "INDEX: https://reports.slokar.cloud"
