#!/bin/sh
set -eu

docker compose --env-file .env -f docker-compose.test.yml down
sudo systemctl stop pkg-synosamba-smbd.service pkg-synosamba-nmbd.service
sudo systemctl disable pkg-synosamba-smbd.service pkg-synosamba-nmbd.service
docker compose --env-file .env -f docker-compose.cutover.yml up -d

cat <<'EOF'

Cutover complete.
- Verify SMB access on the NAS primary IP.
- If discovery is required, confirm /etc/avahi/services/samba.service was refreshed.
- To roll back, run ./rollback.sh

EOF
