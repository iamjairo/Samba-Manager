#!/bin/sh
set -eu

docker compose --env-file .env -f docker-compose.cutover.yml down || true
docker compose --env-file .env -f docker-compose.test.yml down || true
sudo systemctl enable pkg-synosamba-smbd.service pkg-synosamba-nmbd.service
sudo systemctl start pkg-synosamba-smbd.service pkg-synosamba-nmbd.service

cat <<'EOF'

Rollback complete.
- Synology SMB services are enabled and running again.
- If needed, remove stale Avahi service files from /etc/avahi/services/.

EOF
