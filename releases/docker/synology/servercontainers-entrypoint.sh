#!/bin/sh
set -eu

if [ -s /etc/samba/smb.conf ] && [ -s /var/lib/samba/private/smbpasswd ]; then
  touch /.initialized
fi

exec /container/scripts/entrypoint.sh "$@"
