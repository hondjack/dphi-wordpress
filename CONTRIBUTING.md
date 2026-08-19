# Contribuer à dphi-wordpress

- Toute implémentation démarre par un ticket GitHub ouvert — pas de changement sans ticket.
- Workflow : créer le ticket → implémenter → fermer avec un commentaire de livraison.
- Toute configuration WordPress se fait via WP-CLI, jamais via l'UI admin si c'est scriptable.
- Secrets uniquement dans `.env` (non commité) — jamais dans `docker-compose.yml` ou `wp-config.php` en clair.
- Les décisions d'architecture significatives sont documentées dans `docs/adr/` (format ADR).
- Respecter la charte graphique DPhi v2 (`CLAUDE.md`, `docs/charte-graphique.md`) — non négociable.
