#!/bin/bash
# Update nginx configs on existing droplets without recreating them
# Usage: ./scripts/update-nginx-configs.sh <east-ip> <west-ip>
#
# Note: This copies configs as-is. If your configs use template variables
# (like ${east_server}), you'll need to recreate the droplets with terraform apply
# or manually substitute the variables.

set -e

EAST_IP="${1}"
WEST_IP="${2}"

if [ -z "$EAST_IP" ] || [ -z "$WEST_IP" ]; then
    echo "Usage: $0 <east-ip> <west-ip>"
    echo "Get IPs with: terraform output"
    exit 1
fi

echo "Updating nginx configs on existing droplets..."

# Update east coast
echo "Updating east coast proxy ($EAST_IP)..."
scp nginx-sites-east/*.conf rooday@${EAST_IP}:/tmp/
ssh rooday@${EAST_IP} << 'EOF'
    sudo cp /tmp/*.conf /etc/nginx/sites-available/
    sudo rm /tmp/*.conf
    for conf in /etc/nginx/sites-available/*.conf; do
        basename=$(basename "$conf")
        sudo ln -sf "/etc/nginx/sites-available/$basename" "/etc/nginx/sites-enabled/$basename"
    done
    sudo nginx -t && sudo systemctl reload nginx
    echo "East coast updated successfully"
EOF

# Update west coast
echo "Updating west coast proxy ($WEST_IP)..."
scp nginx-sites-west/*.conf rooday@${WEST_IP}:/tmp/
ssh rooday@${WEST_IP} << 'EOF'
    sudo cp /tmp/*.conf /etc/nginx/sites-available/
    sudo rm /tmp/*.conf
    for conf in /etc/nginx/sites-available/*.conf; do
        basename=$(basename "$conf")
        sudo ln -sf "/etc/nginx/sites-available/$basename" "/etc/nginx/sites-enabled/$basename"
    done
    sudo nginx -t && sudo systemctl reload nginx
    echo "West coast updated successfully"
EOF

echo "All configs updated!"
echo ""
echo "Note: If your configs use template variables (${east_server}, ${west_server}),"
echo "they won't be substituted. Either recreate with 'terraform apply' or manually edit on the server."
