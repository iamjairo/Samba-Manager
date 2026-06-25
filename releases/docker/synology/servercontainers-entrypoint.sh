#!/bin/sh
set -eu

# Preserve a previously customized smb.conf when the backend container is recreated
# and the Samba account database already exists on the persistent state volume.
if [ -s /etc/samba/smb.conf ] && [ -s /var/lib/samba/private/smbpasswd ]; then
  touch /.initialized
fi

if [ -n "${SAMBA_GLOBAL_STANZA_FILES:-}" ]; then
  SAMBA_GLOBAL_STANZA=""
  OLD_IFS=${IFS}
  IFS=:
  for stanza_file in $SAMBA_GLOBAL_STANZA_FILES; do
    [ -f "$stanza_file" ] || continue
    stanza=$(
      while IFS= read -r line; do
        [ -n "$line" ] || continue
        eval "printf '%s;' \"$line\""
      done <<EOF
$(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' "$stanza_file")
EOF
    )
    if [ -n "$stanza" ]; then
      if [ -n "$SAMBA_GLOBAL_STANZA" ]; then
        SAMBA_GLOBAL_STANZA="${SAMBA_GLOBAL_STANZA}${stanza}"
      else
        SAMBA_GLOBAL_STANZA="$stanza"
      fi
    fi
  done
  IFS=${OLD_IFS}
  export SAMBA_GLOBAL_STANZA
fi

exec /container/scripts/entrypoint.sh "$@"
