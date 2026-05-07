# Spécification Métier : Géocodage Address

## 1. Contexte

Les résidences ont des coordonnées GPS exactes (`lat`/`longi`). Pour protéger la vie privée des propriétaires, ces coordonnées ne doivent pas être envoyées à tous les clients. Un système de coordonnées alternatives géocodées (basées sur le nom + commune) permet d'afficher une position approximative.

## 2. Objectif

- Stocker des coordonnées **géocodées** (approximatives) dans `Address` côté serveur
- Envoyer par défaut les coordonnées **géocodées** au client
- Envoyer les coordonnées **exactes** uniquement sous condition (réservation payée)
- Créer un **service de géocodage** pour calculer ces coordonnées à la volée

## 3. Acteurs

| Acteur | Reçoit |
|--------|--------|
| Visiteur / Locataire sans réservation payée | Coordonnées géocodées (approximatives) |
| Locataire avec réservation PAYÉE | Coordonnées exactes |
| Propriétaire (sa résidence) | Coordonnées exactes |

## 4. Règles Métier

| Règle | Description |
|-------|-------------|
| RM1 | Les coordonnées exactes (`lat`/`longi`) sont TOUJOURS présentes |
| RM2 | Les coordonnées géocodées (`geoLat`/`geoLongi`) sont calculées à partir de `Address.nom` + `Commune` |
| RM3 | Par défaut, le serveur envoie les coordonnées **géocodées** au client |
| RM4 | Si le locataire a une **réservation PAYÉE** → le serveur envoie les coordonnées **exactes** |
| RM5 | Si c'est le **propriétaire** qui consulte sa résidence → coordonnées **exactes** |
| RM6 | **La logique de décision est côté SERVEUR** (le client ne décide pas) |
| RM7 | Les coordonnées géocodées sont stockées côté serveur (un seul appel API) |
| RM8 | Si les coords géocodées sont vides → service de géocodage appelé à la volée et résultat stocké |

## 5. Flux de données

```
┌─────────────────────────────────────────────────────────────┐
│ SERVEUR (décide)                                            │
│                                                             │
│ Address                                                     │
│ ├── lat / longi          ← Coordonnées EXACTES (toujours)   │
│ └── geoLat / geoLongi    ← Coordonnées GÉOCODÉES (nouveau)  │
│                                                             │
│ LOGIQUE SERVEUR :                                           │
│ Si (réservation PAYÉE OU propriétaire) :                    │
│    → Envoyer lat/longi                                      │
│ Sinon :                                                     │
│    → Envoyer geoLat/geoLongi                                │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ CLIENT (reçoit)                                             │
│                                                             │
│ Reçoit : displayLat / displayLongi                          │
│ (le client affiche simplement, ne décide rien)              │
└─────────────────────────────────────────────────────────────┘
```

## 6. Service de Géocodage

- **API** : Nominatim (OpenStreetMap) - Gratuite
- **Entrée** : `Address.nom` + `Commune.nom`
- **Sortie** : Coordonnées du lieu
- **Stockage** : `geoLat` / `geoLongi` dans Address
- **Déclenchement** : À la volée si champs vides

## 7. Périmètre d'implémentation

| Côté | Actions |
|------|---------|
| **Serveur** | Ajouter champs `geoLat`/`geoLongi` + logique de décision + service géocodage |
| **Client Flutter** | Ajouter champs `geoLat`/`geoLongi` dans modèle Address + service géocodage pour remplir à la volée si vide |

## 8. Critères d'Acceptation

- [ ] Nouveaux champs `geoLat` et `geoLongi` ajoutés dans Address (serveur + client)
- [ ] Service de géocodage créé (appel API Nominatim)
- [ ] Logique serveur : envoi coords exactes si réservation payée ou propriétaire
- [ ] Logique serveur : envoi coords géocodées sinon
- [ ] Géocodage à la volée si `geoLat`/`geoLongi` vides + stockage résultat
- [ ] Le client reçoit des coords unifiées (`displayLat`/`displayLongi`)

---

**Validé par l'utilisateur** : Oui
**Date** : 2025-12-27
