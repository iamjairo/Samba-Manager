# Synology Hybrid Deployment

This deployment keeps **Samba-Manager** as the UI while using `ghcr.io/servercontainers/samba` as the SMB backend.

## Files

- `docker-compose.test.yml` — non-disruptive test stack using a dedicated macvlan IP
- `docker-compose.cutover.yml` — production cutover stack using host networking
- `global-stanza.common.conf` — shared Samba globals for both modes
- `global-stanza.test.conf` — test-only interface binding
- `global-stanza.cutover.conf` — cutover-only overrides
- `smb.conf` / `shares.conf` — starter configuration managed by Samba-Manager
- `validate.sh` — quick validation plus manual client checklist
- `cutover.sh` — stop Synology SMB and start the production backend
- `rollback.sh` — stop the containers and re-enable Synology SMB

## Why this layout

- Samba-Manager keeps the advanced UI and writes `/etc/samba/smb.conf` and `/etc/samba/shares.conf`
- The backend container serves the same mounted config files
- Samba-Manager talks to the Docker socket so saving settings can trigger a backend reload
- The custom backend wrapper preserves existing config files on container recreation instead of letting the backend image overwrite them

## Quick start

1. Copy `.env.example` to `.env`
2. Update the Synology-specific values, especially `PUID`, `PGID`, share path, and macvlan settings
3. Create `${SAMBA_CONFIG_PATH}` and place `shares.conf` there before first start
4. `smb.conf` is auto-generated on first backend start; keep the sample `smb.conf` only as a reference for the settings you want the UI to maintain after bootstrap
5. Start the test stack:
   ```bash
   docker compose --env-file .env -f docker-compose.test.yml up -d
   ```
6. Run validation:
   ```bash
   ./validate.sh
   ```

## Synology-specific notes

### UID/GID mapping

Set `PUID` and `PGID` to the Synology user and group IDs that own your data. This keeps file ownership consistent between DSM, SMB clients, and the container.

### Avahi visibility

The test stack disables Avahi inside the backend container. The cutover stack mounts `/etc/avahi/services` into `/external/avahi` so the backend image refreshes `samba.service` for the host Avahi daemon.

### macOS / Finder tuning

The sample `smb.conf` enables:

- `vfs objects = catia fruit streams_xattr`
- `fruit:metadata = stream`
- `fruit:model = MacSamba`

These settings are the baseline for Finder compatibility and Time Machine style metadata handling.

## Cutover

After the test IP is validated from Windows and macOS clients:

```bash
./cutover.sh
```

## Rollback

```bash
./rollback.sh
```
