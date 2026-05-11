# 📋 Spécification Métier — V9.7c Mini-carte position réelle

> **Version :** 1.0
> **Date :** 2026-05-11
> **Status :** ✅ Validée

---

## 1. Contexte

La V9.7b a livré le modèle `MapAppartement` avec le pattern dual-coordonnées (`displayLat/Longi` obfusqué + `realLat/Longi` privé), un endpoint `GET /api/map/appartements/{id}/real-location` côté backend qui révèle les coordonnées exactes uniquement si le locataire a une réservation `PAYER` ou `FINALISER` pour cet appartement, et l'event `MapBloc.RequestRealLocation` côté Flutter. Mais ce dernier n'est branché à aucune UI. La V9.7c finalise la chaîne : afficher concrètement la position réelle à l'utilisateur qui en a le droit, avec un parcours itinéraire externe (Apple Maps / Google Maps).

## 2. Objectif

Compléter le parcours locataire en intégrant une **mini-carte sur `LocataireDetailScreen`** qui :
- Affiche toujours une localisation (UX cohérente, jamais d'écran cassé)
- Bascule automatiquement de la position approximative à la position exacte une fois la réservation payée
- Permet de lancer un itinéraire externe vers le logement réservé

## 3. Acteurs

- **Locataire** — seul acteur qui voit la mini-carte sur `LocataireDetailScreen`.
- **Proprio / Démarcheur** — non concernés.

## 4. Règles Métier

### R1 — Présence systématique
La mini-carte est **toujours** affichée sur `LocataireDetailScreen`. Pas de masquage conditionnel.

### R2 — Source de vérité backend pour les coords exactes
Au montage de la mini-carte, Flutter appelle `GET /api/map/appartements/{id}/real-location`. Le backend décide :
- `200` + `{lat, lng}` → coordonnées **réelles** affichées + section déverrouillée (bouton Itinéraire actif)
- `403` (pas de résa valide) → fallback obfusqué silencieux
- Toute autre erreur (réseau, timeout, 500) → fallback obfusqué silencieux

### R3 — Fallback obfusqué + label
Quand les coords réelles ne sont pas dispo (toutes raisons confondues — R2), la mini-carte affiche les coords **obfusquées** déjà connues (`displayLat/Longi` du `MapAppartement` ou de l'`Address` de l'appartement) avec un label discret **"Localisation approximative"** sous la carte.

### R4 — Mode débloqué post-résa
Quand `200` est reçu :
- La mini-carte montre la position réelle
- Le label devient **"Localisation exacte"** (ou disparaît selon UI)
- Le bouton **"Itinéraire"** devient actif

### R5 — Bouton Itinéraire
- Visible en mode débloqué uniquement (réelle obtenue)
- Tap → ouvre Apple Maps (iOS) / Google Maps (Android) via `url_launcher`, avec les coords réelles
- URL pattern : `https://maps.apple.com/?ll={lat},{lng}` (iOS) / `https://www.google.com/maps/dir/?api=1&destination={lat},{lng}` (Android)

### R6 — Visibilité du status
Aucun message d'erreur explicite si `/real-location` échoue. L'UX reste fluide — le label "Localisation approximative" informe implicitement.

## 5. Cas d'Usage Principal

1. Locataire push `LocataireDetailScreen` (depuis carte, home, favoris, ou trips)
2. La section mini-carte se charge avec un skeleton léger
3. En parallèle, Flutter dispatche `MapBloc.RequestRealLocation(appartId)` qui appelle `/real-location`
4. **Cas A — Locataire avec résa payée** : `200` + coords → mini-carte recentre sur position réelle, label "Localisation exacte", bouton "Itinéraire" actif
5. **Cas B — Locataire sans résa** : `403` (ou autre) → mini-carte affiche coords obfusquées, label "Localisation approximative", pas de bouton Itinéraire
6. Si cas A : tap "Itinéraire" → app maps externe s'ouvre avec direction vers les coords réelles

## 6. Cas Alternatifs / Limites

- **Pas de coords du tout** : section mini-carte cachée intégralement (cas extrême)
- **`url_launcher` échoue** (pas d'app maps installée) : SnackBar "Aucune application carte disponible"
- **Hot reload pendant le call** : pas de re-fetch automatique
- **Locataire ouvre 2 fois le même appart en peu de temps** : pas de cache local, chaque ouverture redéclenche un `/real-location`

## 7. Contraintes

- **Sécurité** : aucune logique de validation côté Flutter. Backend = juge unique.
- **Performance** : le call `/real-location` doit être non-bloquant
- **UX** : aucun "écran erreur" visible — fallback toujours silencieux
- **MVP** : pas de tracking utilisateur, pas d'historique des itinéraires
- **Dépendance** : `url_launcher` à vérifier dans pubspec.yaml (sinon ajout requis)

## 8. Critères d'Acceptation

- [ ] `LocataireDetailScreen` affiche une nouvelle section "Localisation"
- [ ] Mini-carte `flutter_map` avec tuiles OSM dark filtered (réutilise pattern V9.7)
- [ ] Marker centré au point affiché (obfusqué ou réel)
- [ ] Au montage, dispatch `MapBloc.RequestRealLocation(appartId)`
- [ ] Si state `MapRealLocationLoaded` → coords réelles + label "Localisation exacte" + bouton Itinéraire visible
- [ ] Sinon → coords obfusquées + label "Localisation approximative" + pas de bouton
- [ ] Tap bouton Itinéraire → ouvre Apple/Google Maps externe via `url_launcher`
- [ ] `flutter analyze` : 0 nouvelle erreur
- [ ] Documentation HTML feature mise à jour
