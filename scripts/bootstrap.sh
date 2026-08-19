#!/usr/bin/env bash
# Bootstrap WordPress Multisite (ticket WP-0 #5). Idempotent -- safe to
# re-run. Invoke via:
#   docker compose --profile cli run --rm wpcli bash scripts/bootstrap.sh
set -euo pipefail

ADMIN_USER="hondjack"
ADMIN_EMAIL="hondjack@dphi.africa"
NETWORK_TITLE="DPhi Group"

if [ -z "${WP_ADMIN_PASSWORD:-}" ]; then
  echo "ERREUR: WP_ADMIN_PASSWORD n'est pas défini (.env). Abandon." >&2
  exit 1
fi
if [ -z "${WP_HOME:-}" ] || [ -z "${WP_DOMAIN_CURRENT_SITE:-}" ]; then
  echo "ERREUR: WP_HOME et WP_DOMAIN_CURRENT_SITE doivent être définis (.env). Abandon." >&2
  exit 1
fi

# --- 1+2. Installation multisite -------------------------------------------
# wp-config.php a déjà MULTISITE/SUBDOMAIN_INSTALL/etc. codés en dur (ticket
# #3, WORDPRESS_CONFIG_EXTRA), donc `wp core install` + `multisite-convert`
# (la séquence décrite dans le ticket) ne s'applique pas ici : ces defines
# sont normalement ajoutés PAR multisite-convert lui-même sur un wp-config.php
# qui ne les a pas encore. `multisite-install` est la commande WP-CLI dédiée
# à une installation fraîche quand les defines multisite sont déjà présents.
if wp core is-installed --network 2>/dev/null; then
  echo "WordPress Multisite déjà installé, on saute l'installation."
else
  wp core multisite-install \
    --url="${WP_HOME}" \
    --title="${NETWORK_TITLE}" \
    --admin_user="${ADMIN_USER}" \
    --admin_email="${ADMIN_EMAIL}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --subdomains \
    --skip-email
fi

# --- 3. Sous-sites -----------------------------------------------------------
EXISTING_URLS="$(wp site list --field=url || true)"

create_site_if_missing() {
  local slug="$1" title="$2"
  local site_url="https://${slug}.${WP_DOMAIN_CURRENT_SITE}"
  if echo "${EXISTING_URLS}" | grep -qE "^${site_url}/?$"; then
    echo "Site '${slug}' déjà créé, on saute."
  else
    wp site create --slug="${slug}" --title="${title}" --email="${ADMIN_EMAIL}"
  fi
}

create_site_if_missing "tv"    "DPhi TV"
create_site_if_missing "agro"  "DPhi Agropastorale"
create_site_if_missing "edu"   "DPhi Education"
create_site_if_missing "pay"   "DPhi Pay"
create_site_if_missing "media" "DPhi Media"

# --- 4. Super-admin ----------------------------------------------------------
if wp super-admin list | grep -qx "${ADMIN_USER}"; then
  echo "'${ADMIN_USER}' est déjà super-admin, on saute."
else
  wp super-admin add "${ADMIN_USER}"
fi

# --- 5. Thème dphi-base (WP-1, tickets #9-14) --------------------------------
if [ -d "wp-content/themes/dphi-base" ]; then
  wp theme enable dphi-base --network --activate
else
  echo "wp-content/themes/dphi-base introuvable (thème pas encore livré, WP-1) -- étape ignorée."
fi

# --- 6. Permaliens sur chaque sous-site --------------------------------------
for url in $(wp site list --field=url); do
  wp rewrite structure '/%postname%/' --url="${url}"
  wp rewrite flush --hard --url="${url}"
done

echo "Bootstrap terminé."
