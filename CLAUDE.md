# CLAUDE.md — dphi-wordpress

> Lis ce fichier EN PREMIER à chaque session. Il contient le contexte projet
> et la charte graphique condensée. Pour la version complète de la charte,
> lire `docs/charte-graphique.md`.

---

## Projet

WordPress Multisite — Réseau de portails DPhi Group.
Repo : `hondjack/dphi-wordpress`
Backlog : GitHub Project #3

### Portails (sous-domaines)
| Sous-domaine | Verticale | Statut |
|---|---|---|
| dphi.africa | DPhi Group (groupe) | Phase 1 |
| tv.dphi.africa | DPhi TV | Phase 1 |
| agro.dphi.africa | DPhi Agropastorale | Phase 1 |
| edu.dphi.africa | DPhi Education | Phase 2 |
| pay.dphi.africa | DPhi Pay | Phase 2 |
| media.dphi.africa | DPhi Media | Phase 3 |

### Stack
- WordPress Multisite (sous-domaines), version 6.x
- MariaDB 11 + Redis 7
- Docker Compose + Traefik v3 (réseau externe `dphi_network`)
- WP-CLI pour toute configuration programmatique
- GitHub Actions : push main → staging auto / tag versionné → prod

### Environnements
| Env | Hôte | Déclencheur |
|---|---|---|
| staging | Hetzner CPX12 qual (178.105.179.129) | Push main |
| prod | VPS dédié (à provisionner) | Tag versionné |

---

## Règle non négociable

> Pas d'implémentation sans ticket GitHub.
> Créer le ticket → implémenter → fermer avec commentaire de livraison.
> Backlog : https://github.com/users/hondjack/projects/3

---

## Stack technique détaillée

### Docker
- Réseau externe `dphi_network` — doit exister avant `docker compose up`
- Noms de services Compose comme DNS interne (pas `container_name`)
- Secrets via `.env` uniquement — jamais dans `docker-compose.yml`
- `.env` non commité — `.env.example` commité

### WordPress
- Préfixe tables : `dphi_`
- Permaliens : `/%postname%/` sur tous les sous-sites
- `WP_DEBUG=true` en staging, `false` en prod (piloté par `.env`)
- `DISALLOW_FILE_EDIT=true` en prod
- Toute configuration via WP-CLI — jamais via l'UI si scriptable

### Thème
- Thème parent : `dphi-base` (dans `wp-content/themes/dphi-base/`)
- 6 thèmes enfants : `dphi-group`, `dphi-tv`, `dphi-agro`, `dphi-edu`, `dphi-pay`, `dphi-media`
- Charte graphique v2 — voir section ci-dessous et `docs/charte-graphique.md`

### Plugins réseau (activés sur tous les sous-sites)
- Yoast SEO
- Wordfence
- WP Super Cache
- Contact Form 7
- WP Migrate
- CookieYes (RGPD)
- Redis Object Cache
- Redirection

### CI/CD
- `deploy-staging.yml` : push main → SSH CPX12 → git pull → docker compose up → wp cache flush
- `deploy-prod.yml` : tag `v*.*.*` → SSH VPS prod (secrets à remplir quand VPS provisionné)
- Thème et plugins versionnés dans git sous `wp-content/themes/` et `wp-content/plugins/`
- `wp-content/uploads/` exclu du repo — persisté via volume Docker

---

## Prochaine migration WP

_Aucune migration DB WordPress à ce stade — installation fraîche._
Mettre à jour cette ligne après chaque modification de schéma ou bootstrap WP-CLI.

---

## Charte graphique DPhi v2 — VERSION CONDENSÉE

> Version complète : `docs/charte-graphique.md`
> Non négociable — aucune exception.

### Palette

| Rôle | HEX | Règle |
|---|---|---|
| Accent principal | `#1E3F66` | Titres H1, bordures, boutons, en-têtes tableaux. Max 10-15% des surfaces. |
| Gold identitaire | `#CBB06B` | UNIQUEMENT la lettre **D** dans "DPhi". Max 2x par page. Jamais en fond. |
| Texte principal | `#222222` | Corps de texte, H2, H3, contenu tableaux. Préféré au noir pur. |
| Fond universel | `#FFFFFF` | 90% des surfaces. Fond de toutes les pages et sections. |
| Tableaux alternés | `#F4F4F4` | Lignes paires des tableaux uniquement. Jamais en fond de section. |
| Teal logo | `#12A29A` | **LOGO UNIQUEMENT.** Interdit partout ailleurs — pas de titres, pas de fonds, pas de bordures. |

### Variables CSS (à utiliser dans tout le code HTML/PHP/CSS)

```css
:root {
  --dphi-blue:       #1E3F66;
  --dphi-gold:       #CBB06B;
  --dphi-dark:       #222222;
  --dphi-grey:       #F4F4F4;
  --dphi-teal:       #12A29A; /* logo uniquement — ne jamais utiliser en CSS hors logo */
  --dphi-font:       'Calibri', 'Segoe UI', Arial, sans-serif;
  --dphi-font-code:  'Courier New', Consolas, monospace;
  --dphi-font-legal: 'Times New Roman', Georgia, serif;
}
```

### Typographie

| Support | Police |
|---|---|
| Tout le site (HTML/CSS) | `'Calibri', 'Segoe UI', Arial, sans-serif` |
| Pages légales (mentions, CGU, confidentialité) | Times New Roman |
| Blocs de code | Courier New |

### Hiérarchie typographique web

| Élément | Style |
|---|---|
| H1 | `#1E3F66`, bold, bordure gauche 3px solid `#1E3F66` |
| H2 | `#222222`, bold, bordure bas 1px solid `#1E3F66` |
| H3 | `#222222`, bold, pas de bordure |
| Corps | `#222222`, regular, line-height 1.6 |
| Chiffre clé | `#1E3F66`, bold, grand (28-48px), seul sur sa ligne |
| Note/légende | `#666666`, italic, 12px |

### Tableaux HTML/WordPress

```
En-tête : background #1E3F66, color #FFFFFF
Lignes impaires : background #FFFFFF
Lignes paires : background #F4F4F4
Valeurs clés : color #1E3F66, font-weight bold
Jamais d'autres couleurs.
```

### Logo

- Fond blanc uniquement — jamais sur fond coloré ni photo
- Zone de protection : espace libre = 1/5 de la hauteur du logo
- Taille minimale glyph : 20px. Logo complet : 80px
- Ne jamais déformer, étirer, recolorer

### INTERDIT — règles absolues

Ces règles évitent qu'un rendu DPhi soit perçu comme généré par une IA.

| Interdit | Raison |
|---|---|
| Fond coloré sur sections/pages | Fond blanc uniquement. Bleu/teal/gold en fond = signature IA |
| `#12A29A` teal hors du logo | Réservé logo. Interdit en titre, fond, bordure, bouton |
| Gold `#CBB06B` en fond de cellule ou bandeau | Gold = lettre D uniquement |
| Emojis comme éléments graphiques | Utiliser chiffres et formes géométriques |
| Fond sombre (`#1A2A3A` ou similaire) | Signature IA — supprimé définitivement |
| Cellules de tableau multicolores | Bleu/blanc/gris clair uniquement |
| Dégradés, ombres portées, effets | Flat design sobre uniquement |
| Plus de 2 couleurs par page hors texte | Bleu + anthracite. Gold max 2x. Rien d'autre |
| Fond coloré derrière du texte blanc (hors en-tête tableau) | Interdit |

---

## Liens utiles

- GitHub Project #3 : https://github.com/users/hondjack/projects/3
- Repo dphi-tv (backend Fastify) : https://github.com/hondjack/dphi-tv
- Repo dphi-pay (paiement) : https://github.com/hondjack/dphi-pay
- Charte graphique complète : `docs/charte-graphique.md`
- Hetzner CPX12 qual : 178.105.179.129
