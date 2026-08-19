# Contribuer à dphi-wordpress

- Toute implémentation démarre par un ticket GitHub ouvert — pas de changement sans ticket.
- Workflow : créer le ticket → implémenter → fermer avec un commentaire de livraison.
- Toute configuration WordPress se fait via WP-CLI, jamais via l'UI admin si c'est scriptable.
- Secrets uniquement dans `.env` (non commité) — jamais dans `docker-compose.yml` ou `wp-config.php` en clair.
- Les décisions d'architecture significatives sont documentées dans `docs/adr/` (format ADR).
- Respecter la charte graphique DPhi v2 (`CLAUDE.md`, `docs/charte-graphique.md`) — non négociable.

## CI/CD — secrets GitHub requis

`deploy-staging.yml` (push sur `main`) et `deploy-prod.yml` (tag `v*.*.*`) attendent ces secrets dans les réglages du repo (Settings → Secrets and variables → Actions) :

| Secret | Usage |
|---|---|
| `STAGING_SSH_HOST` | IP du Hetzner CPX12 (qual) |
| `STAGING_SSH_USER` | Utilisateur SSH staging |
| `STAGING_SSH_KEY` | Clé privée ED25519 staging |
| `PROD_SSH_HOST` | IP du VPS prod (à remplir quand provisionné) |
| `PROD_SSH_USER` | Utilisateur SSH prod |
| `PROD_SSH_KEY` | Clé privée ED25519 prod |

`deploy-prod.yml` reste inactif tant que la variable de repo `PROD_ENABLED` n'est pas mise à `true` (Settings → Secrets and variables → Actions → Variables) — évite un déploiement accidentel avant que le VPS prod existe.

## Premier déploiement staging

`deploy-staging.yml` suppose que `/opt/dphi-wordpress` existe déjà sur le Hetzner CPX12 (178.105.179.129) avec le repo cloné dedans — ce n'est pas automatisé. À faire une seule fois, manuellement, avant le premier déclenchement du workflow :

```bash
ssh dphi@178.105.179.129
mkdir -p /opt/dphi-wordpress
cd /opt/dphi-wordpress
git clone https://github.com/hondjack/dphi-wordpress .
cp infra/docker/.env.example infra/docker/.env
# remplir infra/docker/.env avec les vraies valeurs (mots de passe, WP_ADMIN_PASSWORD, etc.)
```

Après ça, `wp-config.php` et les tables sont générés au premier `docker compose up`. Le bootstrap Multisite (`scripts/bootstrap.sh`) doit être lancé une fois, à la main, après ce premier démarrage :

```bash
cd infra/docker
docker compose --profile cli run --rm wpcli bash scripts/bootstrap.sh
```

## Backup quotidien

`scripts/backup.sh` dump MariaDB + `wp-content/uploads/` (volume Docker) et pousse une archive vers Google Drive via `rclone`. Prérequis unique sur le serveur, avant le premier cron :

```bash
rclone config  # créer un remote nommé "gdrive" pointant sur le Google Drive DPhi
```

Cron (`crontab -e`, utilisateur `dphi`) :

```
0 3 * * * /opt/dphi-wordpress/scripts/backup.sh >> $HOME/dphi-wp-backup.log 2>&1
```

Rotation locale automatique : les archives de plus de 7 jours dans `/tmp` sont supprimées à chaque exécution.
