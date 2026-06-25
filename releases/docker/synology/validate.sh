#!/bin/sh
set -eu

if ping -c 1 -W 1 "${SAMBA_TEST_IP:-}" >/dev/null 2>&1; then
  echo "Note: ${SAMBA_TEST_IP} responds to ping. Confirm this is your intended test IP before continuing."
fi

docker compose --env-file .env -f docker-compose.test.yml ps
docker compose --env-file .env -f docker-compose.test.yml exec samba-backend testparm -s /etc/samba/smb.conf
docker compose --env-file .env -f docker-compose.test.yml exec samba-manager curl -fsS http://localhost:5000/health

cat <<EOF

Manual validation checklist:
- Windows: connect to \\\\${SAMBA_TEST_IP}\\data and verify read/write with the mapped user.
- macOS Finder: Connect to smb://${SAMBA_TEST_IP}/data and verify browse speed plus copy/rename/delete.
- Permissions: create a file from SMB and confirm ownership matches the Synology UID/GID on disk.
- Samba-Manager UI: edit a share/global setting, save, and confirm the backend reload succeeds.

EOF
