# 📋 Spécification Métier — V9.7 Carte Interactive

## 1. Contexte

L'app Asfar dispose d'un `MapBloc` complet côté infra (events + state +
service backend) mais aucun écran cartographique interactif n'a été
reconstruit dans le proto V5-V8. Seul un `MapTeaser` figé (4 pins fake)
existe sur le `LocataireHomeScreen`. Le locataire ne peut donc pas
explorer visuellement les logements disponibles autour d'une zone
géographique.

## 2. Objectif

Offrir au locataire un écran cartographique temps réel qui affiche les
logements disponibles en zone (center + radius), avec interactions de
découverte naturelles (pan/zoom, tap marker → preview, recentrer sur sa
position, filtrer rapidement).

## 3. Acteurs

- **Locataire** : utilisateur principal qui explore la carte
- Pas d'accès proprio/démarcheur à cette feature en V9.7

## 4. Règles Métier

1. **Source données** : `LoadFilteredMapResidences(center, radiusKm, filter)`
   du `MapBloc`. Pas de réutilisation `AppartementBloc`.
2. **Géolocalisation** : permission OS demandée explicitement. Si refusée :
   centre par défaut **Abidjan (5.345, -4.024)** + toast d'explication
   au tap FAB.
3. **Markers** : 1 marker par résidence avec **prix compact** (`45k`,
   `1.2M`) via `FcfaFormatter`. Pas de clustering en V9.7.
4. **Coordonnées** : `Address.displayLocation` (`exactLocation` ou
   `geocodedLocation`) ou `fallbackLocation` (centre commune/ville).
   Résidences sans coordonnées valides **exclues**.
5. **Rechercher dans cette zone** : bouton après pan/zoom significatif,
   redispatche `LoadFilteredMapResidences` avec nouveau centre.
6. **Filtres** : réutilise `LocataireSearchScreen` (V5).
7. **BottomSheet marker** : tap marker → preview (image, titre, prix,
   beds/baths) + "Voir détails" → `pushScreen(LocataireDetailScreen)`.

## 5. Cas d'Usage Principal

1. Locataire tape l'onglet "Map" du shell (ou "Voir carte" du Home)
2. Permission géoloc demandée → utilisateur accepte
3. Carte centrée sur position user (fallback Abidjan)
4. `LoadFilteredMapResidences(center, radius=10km)` → markers apparaissent
5. Pan/zoom → bouton "Rechercher dans cette zone" apparaît
6. Tap marker → bottom sheet preview + "Voir détails"
7. Tap "Voir détails" → push `LocataireDetailScreen`
8. Retour carte → FAB "Ma position" recentre
9. Bouton "Filtrer" top-right → `LocataireSearchScreen`

## 6. Cas Alternatifs / Limites

- **Permission géoloc refusée** : carte Abidjan + toast au tap FAB
- **Aucun listing en zone** : `EmptyState` overlay + CTA "Élargir la zone"
- **Erreur réseau** : `EmptyState.error` + bouton "Réessayer"
- **Loading initial** : carte vide + shimmer overlay (non-bloquant)
- **Résidence sans coordonnées** : exclue silencieusement
- **Tile loading lent** : 2-3s sur 3G/4G — pas de blocage UI

## 7. Contraintes

- **Stack** : Flutter 3.7+, `flutter_map` à ajouter (tuiles OSM),
  `flutter_bloc` 9.1.1, `latlong2` déjà présent, `flutter_geolocator`
  à ajouter
- **Permissions** : `AndroidManifest.xml` (`ACCESS_FINE_LOCATION`) +
  `Info.plist` (`NSLocationWhenInUseUsageDescription`)
- **Patterns** : 10 règles Flutter (surtout règle n°1),
  `BlocBuilder` + state pattern matching, `EmptyState` partout
- **Performance** : pan/zoom fluide même avec 50+ markers
- **Cap session** : ~2-3h max — pas de clustering, pas de
  search-as-you-type
- **SOLID** : nouveau code respecte la séparation

## 8. Critères d'Acceptation

- [ ] `flutter_map` + `flutter_geolocator` ajoutés au `pubspec.yaml`
- [ ] Permissions Android + iOS déclarées
- [ ] Écran `LocataireMapScreen` accessible via onglet "Map" du
  `LocataireShell`
- [ ] `MapTeaser.onSeeMap` du Home push le nouvel écran
- [ ] Carte tuiles OSM, pan/zoom fluide
- [ ] Markers prix compact sur `Address.displayLocation`
- [ ] Tap marker → BottomSheet preview + "Voir détails" →
  `LocataireDetailScreen`
- [ ] FAB "Ma position" permission + recentre
- [ ] Bouton "Filtrer" → `LocataireSearchScreen`
- [ ] Bouton "Rechercher dans cette zone" après pan/zoom
- [ ] `EmptyState` overlay si vide / erreur réseau
- [ ] Zéro fonction privée renvoyant `Widget`
- [ ] `flutter analyze` : 0 nouvelle erreur
