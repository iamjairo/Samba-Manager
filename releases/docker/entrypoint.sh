#!/bin/bash
# Docker entrypoint for Samba Manager

set -e

echo "Starting Samba Manager..."
echo "=========================="
echo ""

# Environment variables
export SAMBA_MANAGER_SECRET_KEY="${SAMBA_MANAGER_SECRET_KEY:-$(python3 -c 'import secrets; print(secrets.token_hex(32))')}"
export FLASK_ENV="${FLASK_ENV:-production}"
export SAMBA_MANAGER_EMBEDDED_SMBD="${SAMBA_MANAGER_EMBEDDED_SMBD:-1}"

# Initialize Samba configuration if not present
if [ ! -f /etc/samba/smb.conf ]; then
    echo "Initializing Samba configuration..."
    if [ -f /opt/samba-manager/smb.conf.template ]; then
        cp /opt/samba-manager/smb.conf.template /etc/samba/smb.conf
        echo "✓ Samba configuration initialized from template"
    fi
fi

# Create shares.d directory if it doesn't exist
mkdir -p /etc/samba/shares.d
echo "✓ Samba shares directory ready"

# Set proper permissions
chmod 755 /etc/samba
chmod 644 /etc/samba/smb.conf 2>/dev/null || true
chmod 755 /etc/samba/shares.d

# Create log directories if they don't exist
mkdir -p /var/log/samba-manager
mkdir -p /var/log/samba
chmod 755 /var/log/samba-manager
chmod 755 /var/log/samba

echo "✓ Directories initialized"
echo "✓ Environment configured"
echo ""
echo "Starting services..."
echo "- Samba Manager on port 5000"
if [ "$SAMBA_MANAGER_EMBEDDED_SMBD" = "1" ]; then
    cp /etc/supervisor/conf.d/samba-manager.full.conf /etc/supervisor/conf.d/samba-manager.conf
    echo "- Embedded Samba daemon (smbd)"
else
    cp /etc/supervisor/conf.d/samba-manager.ui-only.conf /etc/supervisor/conf.d/samba-manager.conf
    echo "- External Samba backend mode"
fi
echo ""

# Start the supervisord daemon
exec "$@"
