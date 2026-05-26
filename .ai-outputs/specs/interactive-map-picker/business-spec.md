# 📋 Spécification Métier — `interactive-map-picker`

**Date :** 2026-05-26
**Module cible V1 :** Locataire (`LocataireMapScreen`)
**Composant à créer :** widget générique partagé `lib/widget/map/`

---

## 1. Contexte

L'écran carte locataire (`LocataireMapScreen`) actuel laisse l'utilisateur explorer en faisant glisser la carte, puis tapote "Rechercher dans cette zone" pour relancer la requête backend. Pas de recherche textuelle, pas de point de référence visuel fixe — l'utilisateur doit pan/zoomer puis se rappeler de cliquer le bouton "search in area".

La carte est aussi un widget que d'autres modules (proprio, demarcheur) vont vouloir réutiliser plus tard avec la même UX d'interaction.

## 2. Objectif

Enrichir l'expérience carte avec **deux modes d'entrée combinables** pour définir un point de recherche :

1. **Marker fixe au centre visuel de la carte** — l'utilisateur fait glisser la carte sous le marker (pattern Yango/Uber/Bolt). Quand il relâche, on lit la position au centre et on relance la recherche.
2. **Search bar textuelle** — l'utilisateur tape un nom de lieu/quartier/adresse. Le backend renvoie la coordonnée, la carte recentre dessus, recherche relancée.

Le tout encapsulé dans un **nouveau composant générique partagé** (`InteractiveMapPicker`) qui sera consommé en V1 par `LocataireMapScreen`. Proprio et demarcheur l'utiliseront plus tard sans duplication.

## 3. Acteurs

**V1 livrée :** Locataire (sur `LocataireMapScreen`).

**Hors V1 (préparé techniquement) :** Proprio (étude de marché), Demarcheur (exploration zone).

## 4. Règles métier

### Composant `InteractiveMapPicker` (générique)

- **R1** — Marker fixe ancré au centre visuel de la carte (overlay au-dessus du `MapView`). Visuellement : pin avec ombre, accent or, indépendant des markers prix des résidences.
- **R2** — Le marker NE bouge PAS quand l'utilisateur drag la carte — c'est la carte qui défile sous le marker. Le marker reste collé au centre du viewport.
- **R3** — Quand l'utilisateur arrête de bouger la carte (`MapEventMoveEnd` / `FlingAnimationEnd` / `DoubleTapZoomEnd`), on lit la coordonnée du centre et on émet `onCenterChanged(LatLng)` au parent.
- **R4** — Search bar visible en haut de l'écran. Submit (icône loupe ou clavier Enter) → appel backend `/api/map/search?q=...` → émet `onSearchSubmitted(String)` puis `onCenterChanged(LatLng)` au parent.
- **R5** — Bandeau de feedback en bas (au-dessus du marker central, non bloquant) : `"23 résidences à Cocody Riviera"`. Mise à jour à chaque nouveau résultat.
- **R6** — Pendant la recherche en cours : indicateur de chargement subtil (sur le marker ou le bandeau, pas un overlay plein écran qui masque la carte).

### Wiring `LocataireMapScreen`

- **R7** — Remplace l'actuel pattern "drag puis tap 'Rechercher dans cette zone'" par le pattern marker central + auto-search au `onCenterChanged`.
- **R8** — Le bouton "Rechercher dans cette zone" (`SearchInAreaButton`) devient redondant et peut être retiré.
- **R9** — La géoloc utilisateur (FAB "Ma position") reste — recentre la carte sur la position user, ce qui déclenche `onCenterChanged`.

### Backend (à demander — équivalent R14)

- **R-BACK1** — Nouvel endpoint `GET /api/map/search?q={query}` qui renvoie `{ lat: double, lng: double, zoneName: string, formattedAddress: string }`. Auto-complete éventuelle non requise en V1 (submit explicite).
- **R-BACK2** — L'endpoint `/api/map/appartements/filtered` doit renvoyer le `zoneName` correspondant au centre de la recherche (reverse geocode côté backend). Sinon créer un endpoint séparé `GET /api/map/reverse-geocode?lat=...&lng=...`.
- **R-BACK3** — Le rayon de recherche est décidé côté backend (basé sur le zoom transmis ou un défaut). Pas de paramètre `radius` côté mobile en V1.

## 5. Cas d'usage principal

1. Utilisateur ouvre la carte locataire.
2. La carte est centrée sur sa position GPS (ou Abidjan en fallback).
3. Le marker fixe est visible au centre. Bandeau : "X résidences à [zone]".
4. Variante A — il fait glisser la carte vers Cocody. Quand il relâche, la requête se relance automatiquement. Bandeau mis à jour.
5. Variante B — il tape "Yopougon Maroc" dans la search bar. La carte se recentre, la requête se relance. Bandeau mis à jour.
6. Il tape un marker prix → bottom sheet preview de la résidence (comportement existant inchangé).

## 6. Cas alternatifs / limites

- **Search sans résultat** : la search bar affiche un message inline "Aucun lieu trouvé pour '...'". La carte ne bouge pas.
- **Backend indisponible (search)** : message d'erreur dans la search bar. Marker reste là où il était.
- **Backend indisponible (filtered)** : overlay erreur existant (`MapErrorOverlay`) avec retry.
- **0 résidence dans la zone** : bandeau "0 résidences à [zone]". Suggestion : "Élargissez votre recherche" ou recentrez ailleurs.
- **Zone inconnue (reverse geocode null)** : bandeau "X résidences dans cette zone" (sans nom).
- **Geoloc refusée** : fallback Abidjan, le user peut chercher / déplacer la carte.

## 7. Contraintes

- **Composant générique** : aucune dépendance feature-spécifique (pas d'import locataire dans le widget).
- **Performance** : debounce sur `onCenterChanged` (au moins 300ms) pour ne pas spammer le backend pendant un fling.
- **UX** : la carte ne doit jamais être masquée par un overlay plein écran — feedback discret uniquement.
- **Réutiliser** : `MapView` (générique), `MapPricePin`, `MapBloc`, `MapService`, `MapAppartement`, `MyLocationFab`, overlays existants.
- **Création** : `InteractiveMapPicker` (widget), `MapCenterMarker` (overlay marker fixe), `MapSearchBar` (search field), `MapZoneBanner` (bandeau résultats).

## 8. Critères d'acceptation

- [ ] `InteractiveMapPicker` créé dans `lib/widget/map/`, indépendant des features
- [ ] Marker fixe visible au centre visuel quel que soit le zoom/pan
- [ ] `onCenterChanged(LatLng)` émis avec debounce 300ms après `MapEventMoveEnd`
- [ ] Search bar fonctionnelle : submit → appel `/api/map/search` → recentrage + reload
- [ ] Bandeau "X résidences à [zone]" mis à jour à chaque nouveau résultat
- [ ] `LocataireMapScreen` migré vers `InteractiveMapPicker` (bouton "Rechercher dans cette zone" retiré)
- [ ] `MyLocationFab` continue de fonctionner (recentre → déclenche reload)
- [ ] Pattern Yango (marker fixe + carte qui glisse) UX-correct (pas de glitch visuel pendant fling)
- [ ] 0 régression sur le bottom sheet preview au tap d'un marker prix existant

## 9. Hors-périmètre V1

- Proprio / demarcheur wiring (préparé techniquement via le composant générique, mais non câblé)
- Autocomplete de la search bar (submit explicite uniquement)
- Slider de rayon manuel
- Filtres type/prix dans le composant (`FilterCriteria` existant non touché)
- Sauvegarde de zones favorites
- Historique de recherches

## 10. Demandes backend à formuler (équivalent R14 — bloquantes pour la livraison)

- **R-BACK1** : `GET /api/map/search?q={query}` → `{ lat, lng, zoneName, formattedAddress }`
- **R-BACK2** : ajouter `zoneName` dans le payload de `/api/map/appartements/filtered` (ou créer `GET /api/map/reverse-geocode`)
- **R-BACK3** : confirmer que le rayon est décidé par le backend (sinon revoir R3 — rayon par défaut côté mobile en attendant)
