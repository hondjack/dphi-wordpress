# dphi-wordpress

WordPress Multisite — Réseau de portails DPhi Group

## Portails
- dphi.africa — Groupe
- tv.dphi.africa — DPhi TV
- agro.dphi.africa — DPhi Agropastorale
- edu.dphi.africa — DPhi Education (Phase 2)
- pay.dphi.africa — DPhi Pay
- media.dphi.africa — DPhi Media (Phase 3)

## Stack
- WordPress Multisite (sous-domaines)
- MariaDB + Redis
- Docker Compose + Traefik v3
- WP-CLI
- GitHub Actions (staging auto / prod sur tag)

## Environnements
- staging : Hetzner CPX12 qual (*.qual.dphi.africa)
- prod : VPS dédié (*.dphi.africa)

Voir CONTRIBUTING.md et docs/adr/ pour les décisions d'architecture.
