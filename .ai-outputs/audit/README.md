# Audit du projet Asfar — Juin 2026

Audit transversal de l'application Flutter (672 fichiers Dart, ~69k lignes) sur trois
axes : **sécurité**, **praticité/maintenabilité**, **fluidité** (API, cache, mémoire).
Chaque point a sa fiche : problème (fichiers:lignes), impact, marche à suivre, validation.

## 🔒 Sécurité

| Fiche | Problème | Sévérité | Effort |
|---|---|---|---|
| [SEC-01](SEC-01-migration-https-wss.md) | Tout le trafic en HTTP/WS non chiffré | 🔴 Critique | ~1 j (+ backend) |
| [SEC-02](SEC-02-stockage-securise-token-hive.md) | Token en clair (SharedPreferences) + Hive non chiffré | 🔴 Critique | ~1 j |
| [SEC-03](SEC-03-cle-stadia-maps-exposee.md) | Clé API Stadia Maps en dur dans le code | 🟠 Élevée | ~1-2 h |
| [SEC-04](SEC-04-logs-donnees-sensibles.md) | Logs exposant tokens, emails, téléphones | 🟠 Élevée | ~2-3 h |
| [SEC-05](SEC-05-validation-jwt-et-logout.md) | JWT jamais validé (expiration) + logout sans révocation | 🟡 Moyenne | ~½ j (+ backend) |

## 🛠 Praticité / maintenabilité

| Fiche | Problème | Sévérité | Effort |
|---|---|---|---|
| [PRA-01](PRA-01-fusion-dossiers-repository.md) | Doublon `lib/repository/` vs `lib/service/repository/` | 🟡 Moyenne | ~2 h |
| [PRA-02](PRA-02-centraliser-extraction-body.md) | Extraction `{body}` Spring Boot dupliquée ×18 | 🟠 Élevée | ~4 h |
| [PRA-03](PRA-03-doublons-formatage-montants.md) | Deux formatters de montants FCFA concurrents | 🟡 Moyenne | ~3 h |
| [PRA-04](PRA-04-injection-dependances-getit.md) | Injection de dépendances incohérente (GetIt) | 🟡 Moyenne | ~1 j |
| [PRA-05](PRA-05-couverture-tests-services.md) | Zéro test sur services API et repositories | 🟠 Élevée | ~2 j |

## ⚡ Fluidité (API, cache, mémoire)

| Fiche | Problème | Sévérité | Effort |
|---|---|---|---|
| [PERF-01](PERF-01-cache-images.md) | Images sans cache (`Image.network` brut) | 🔴 Impact n°1 | ~2 h |
| [PERF-02](PERF-02-pagination-listes.md) | Pas de pagination appartements/réservations | 🟠 Élevée | ~1 j (+ backend) |
| [PERF-03](PERF-03-rebuilds-favoris.md) | Rebuilds en cascade (BlocBuilder trop larges) | 🟡 Moyenne | ~½ j |
| [PERF-04](PERF-04-ttl-versioning-cache.md) | TTL cache passif, pas de versioning de schéma | 🟡 Moyenne | ~3 h |
| [PERF-05](PERF-05-memoire-blocs-bornee.md) | Mémoire des blocs non bornée (OOM sessions longues) | 🟡 Moyenne | ~½ j |

## Ordre d'attaque recommandé

1. **PERF-01** — cache images (2h, le plus gros gain perçu)
2. **SEC-01 + SEC-02** — HTTPS/WSS + stockage sécurisé (bloquants production)
3. **SEC-04** — nettoyage des logs sensibles (rapide)
4. **PRA-02** — centraliser `extractBody` (protège des évolutions backend)
5. **SEC-03** — révoquer/restreindre la clé Stadia
6. **PERF-02** — pagination (avant que le catalogue grossisse)
7. **PRA-01** — fusion des dossiers repository (rapide)
8. Le reste au fil des features (PRA-04/05 en continu, PERF-03/04/05, SEC-05)

> Implémentation : passer par le workflow `/feature` (ex. `/feature light PERF-01 cache images via cached_network_image dans DomainImage`).
