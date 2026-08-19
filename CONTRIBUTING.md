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
