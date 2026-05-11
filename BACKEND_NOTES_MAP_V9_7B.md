# 🛰️ Notes Backend — V9.7b Map Appartement

> **Date :** 2026-05-11
> **Contexte :** clarifications reçues du dev backend après livraison Flutter V9.7b. Les specs internes BA/Architecture mentionnaient des conventions inexactes — ce fichier consigne les bonnes valeurs pour ne pas refaire l'erreur.

---

## 1. Statuts de réservation autorisant `/real-location`

L'endpoint `GET /api/map/appartements/{id}/real-location` ne renvoie les coordonnées exactes que si le locataire a une réservation **payée** ou **finalisée** pour l'appartement.

**Statuts autorisés :**
- ✅ `PAYER`
- ✅ `FINALISER`

**Statuts NON autorisés** (à ne pas mettre dans le guard, contrairement à ce que disaient les specs BA/Architecture V9.7b) :
- ❌ `CONFIRMER` — chez Asfar, "confirmé" signifie juste que le proprio a accepté la demande, mais le paiement n'a pas encore eu lieu. Pas de raison de divulguer la position exacte tant que c'est pas payé.

### Enum `ReservationStatus` (source de vérité Flutter)

Source : `lib/model/reservation/reservation.dart:11-29`

```dart
enum ReservationStatus {
  enAttente('EN_ATTENTE'),     // demande envoyée, en attente proprio
  confirmee('CONFIRMER'),       // proprio a accepté, PAS encore payé
  payee('PAYER'),               // ✅ paiement effectué — accès real-location
  finalisee('FINALISER'),       // ✅ séjour finalisé — accès real-location
  refusee('REFUSEE'),           // proprio a refusé
  annulee('ANULLE'),            // typo backend intentionnelle ("ANULLE" pas "ANNULE")
  terminee('TERMINEE');         // séjour passé, archivé
}
```

> ⚠️ Note : `ANULLE` est l'orthographe backend (typo conservée côté Flutter pour cohérence — voir le commentaire dans `reservation.dart:17`).

---

## 2. Préfixe de route — `api/` vs `auth/`

**Convention Asfar Spring Boot :**

| Préfixe | Auth | Usage |
|---|---|---|
| `auth/...` | **Public** (pas de Bearer) | Endpoints d'authentification, login, refresh token, etc. |
| `api/...` | **Bearer obligatoire** | Toutes les routes métier nécessitant un utilisateur connecté |

### Routes V9.7b Flutter actuelles

| Route Flutter consomme | Convention | OK ? |
|---|---|---|
| `GET /api/map/appartements/filtered` | `api/` + Bearer | ✅ |
| `GET /api/map/appartements/{id}/real-location` | `api/` + Bearer | ✅ |

> ⚠️ L'ancien `MapService` utilisait `auth/map/residences/...` — c'était **incorrect** (la carte est privée, pas publique). Corrigé en V9.7b vers `api/map/appartements/...`.

> 🔧 **TODO audit existant** : vérifier les autres services Flutter (`AppartementService` utilise `auth/appartement/...` actuellement — à clarifier si ces routes sont vraiment publiques ou si le backend fait un check Bearer implicite côté serveur).

---

## 3. Obfuscation des coordonnées — Stratégie backend

Le backend gère **automatiquement** l'obfuscation des coordonnées des appartements :

### Cas 1 : Le proprio fournit explicitement `geoLat/geoLongi` lors de la création
À la création de l'appartement, l'`AddressReq` accepte déjà les champs `geoLat` et `geoLongi`. Si fournis, le backend les utilise tels quels comme coordonnées **réelles** (stockées en DB), et calcule l'obfuscation côté serveur pour le `displayLat/displayLongi`.

### Cas 2 : Le proprio ne fournit pas `geoLat/geoLongi`
Le backend calcule le décalage **une seule fois à la création** de l'appartement, et le stocke. Conséquence : **les markers sont stables** entre 2 appels (même position obfusquée à chaque requête `/filtered`).

> ✅ **Confidentialité garantie** : `realLat/realLongi` sont jamais sérialisés dans la réponse de `/filtered` — toujours `null` côté client.

> ✅ **Stabilité visuelle** : pas besoin de seed déterministe côté Flutter, le backend assure que le marker d'un appartement donné reste à la même position obfusquée.

### Conséquence pour le Flutter
**Aucune logique d'obfuscation côté Flutter.** Le modèle `MapAppartement` consomme directement `displayLat/displayLongi` retournés par l'API. Si on doit créer un appartement avec coordonnées exactes connues, il faut juste envoyer `geoLat/geoLongi` dans l'`AddressReq` du payload de création.

---

## 4. Action côté Flutter — Mise à jour des specs internes

Les documents suivants contiennent des informations **désormais obsolètes** sur les statuts `CONFIRMER/PAYER/FINALISER` :
- `.ai-outputs/specs/v9-7b-map-appartement-refactor/business-spec.md` (R4, section 7)
- `.ai-outputs/specs/v9-7b-map-appartement-refactor/architecture.md` (§6 endpoints, §7 risques)
- `.ai-outputs/docs/v9-7-carte-interactive.html` (description V9.7b)

À corriger en : **PAYER ou FINALISER** uniquement. À traiter lors du prochain passage sur ces docs (non bloquant — c'est de la doc, pas du code).

---

## 5. Récap mémo

| Question | Réponse |
|---|---|
| Statuts qui débloquent `/real-location` ? | `PAYER` **ou** `FINALISER` (pas `CONFIRMER`) |
| Préfixe route Bearer obligatoire ? | `api/...` |
| Préfixe route publique ? | `auth/...` |
| Obfuscation côté Flutter ? | **Non** — c'est le backend qui fait le calcul une fois à la création |
| Stabilité des markers entre appels ? | Garantie par le backend (décalage stocké en DB) |
| Comment envoyer coords exactes à la création ? | Champs `geoLat`/`geoLongi` dans `AddressReq` |

---

## 6. Référence enum complet

`lib/model/reservation/reservation.dart:11-29` — `ReservationStatus`. Toujours utiliser `.value` pour matcher la chaîne backend (ex: `ReservationStatus.payee.value` → `'PAYER'`).
