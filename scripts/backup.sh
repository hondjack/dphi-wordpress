#!/usr/bin/env bash
# Backup quotidien : dump MariaDB + wp-content/uploads/ -> Google Drive
# (ticket WP-0 #6). Invoqué par cron sur le serveur, voir CONTRIBUTING.md.
set -euo pipefail

cd "$(dirname "$0")/.."

ENV_FILE="infra/docker/.env"
if [ -f "${ENV_FILE}" ]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

: "${MARIADB_USER:?MARIADB_USER manquant (.env)}"
: "${MARIADB_PASSWORD:?MARIADB_PASSWORD manquant (.env)}"
: "${MARIADB_DATABASE:?MARIADB_DATABASE manquant (.env)}"

DATE="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="/tmp/dphi-wp-backup-${DATE}"
mkdir -p "${BACKUP_DIR}"

pushd infra/docker >/dev/null

# Dump DB (toutes les tables Multisite)
docker compose exec -T mariadb mysqldump \
  -u "${MARIADB_USER}" -p"${MARIADB_PASSWORD}" "${MARIADB_DATABASE}" \
  > "${BACKUP_DIR}/db.sql"

# wp-content/uploads/ vit dans le volume Docker nommé wordpress_uploads
# (pas sur l'hôte -- ticket #3), donc on le lit via le conteneur wordpress
# déjà démarré, qui le monte déjà, plutôt qu'un chemin hôte inexistant.
docker compose exec -T wordpress tar -czf - -C /var/www/html/wp-content uploads \
  > "${BACKUP_DIR}/uploads.tar.gz"

popd >/dev/null

# Archive finale
tar -czf "${BACKUP_DIR}.tar.gz" -C "$(dirname "${BACKUP_DIR}")" "$(basename "${BACKUP_DIR}")"

# Upload vers Google Drive (nécessite un remote rclone "gdrive" déjà configuré)
rclone copy "${BACKUP_DIR}.tar.gz" gdrive:DPhi/Backups/WordPress/

# Nettoyage
rm -rf "${BACKUP_DIR}"
find /tmp -maxdepth 1 -name 'dphi-wp-backup-*.tar.gz' -mtime +7 -delete

echo "Backup terminé : ${BACKUP_DIR}.tar.gz"
