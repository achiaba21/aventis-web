# 📋 Spécification Métier — V9.7b Refonte Map Appartement

> **Version :** 1.0
> **Date :** 2026-05-11
> **Status :** ✅ Validée

---

## 1. Contexte

La notion de "résidence" (groupe d'appartements partageant le même immeuble) n'existe plus dans le modèle métier d'Asfar. La carte interactive locataire (livrée en V9.7) expose un modèle `MapResidence` qui agrège artificiellement des appartements (priceRange, appartementCount, proprio unique). Cette agrégation crée une couche intermédiaire qui n'a plus de sens métier et complique le parcours utilisateur.

## 2. Objectif

Refondre l'écran carte pour qu'**un marker = un appartement**, avec un parcours direct du marker vers le détail de l'appartement. Préserver la confidentialité de la localisation exacte (obfuscation côté backend), et révéler la position réelle uniquement aux locataires ayant une réservation payée (statut `PAYER` ou `FINALISER`) sur l'appartement concerné.

## 3. Acteurs

- **Locataire en recherche** — browse la carte, voit des markers de prix individuels, tap pour preview, push pour détail complet.
- **Locataire ayant réservé** — sur l'écran détail de son appartement réservé, voit une mini-carte avec la position **réelle** + bouton itinéraire.
- **Backend Spring Boot** — applique l'obfuscation déterministe (±200m seedé par `appartId`) et n'expose les vraies coordonnées qu'après vérification d'une réservation au statut `PAYER` ou `FINALISER`.

## 4. Règles Métier

### R1 — Granularité du marker
- 1 marker sur la carte = 1 appartement (pas de groupement).
- Le marker affiche le prix journalier de cet appartement spécifique (ex: "40k").

### R2 — Confidentialité des coordonnées
- En browse normal, le locataire ne voit **jamais** la position exacte d'un appartement.
- Backend renvoie systématiquement `displayLat/displayLongi` (obfusqué ±200m) et `realLat/realLongi = null` sur l'endpoint `/filtered`.
- La position réelle n'est exposée que via un endpoint séparé `/real-location` protégé par check réservation au statut `PAYER` ou `FINALISER`.

### R3 — Parcours tap marker (validé Q1)
- Tap sur marker → BottomSheet remonte avec :
  - Photo de l'appart (chargée lazy via `getAppartementDetails(id)` au moment du tap)
  - Titre de l'appart
  - Ligne d'info : `XXk FCFA · communeName · typeAppart · X chambres`
  - Bouton CTA "Voir détails" → push `LocataireDetailScreen`
- L'utilisateur peut fermer le BottomSheet pour revenir à la carte et explorer d'autres markers sans quitter l'écran.

### R4 — Révélation position réelle (validé Q2)
- La position réelle (`realLat/realLongi`) n'apparaît QUE sur `LocataireDetailScreen` lorsque le locataire a une réservation au statut `PAYER` ou `FINALISER` pour cet appartement.
- Sur la carte principale (browse), tous les markers utilisent toujours `displayPosition` (obfusqué), même pour les apparts réservés.
- Sur `LocataireDetailScreen` d'un appart réservé : mini-carte affichant la position **réelle** + bouton "Itinéraire" (ouvre Google/Apple Maps externe).
- Sur `LocataireDetailScreen` d'un appart non réservé : pas de carte de localisation précise (ou la version obfusquée avec mention "Localisation approximative").

### R5 — Suppression liste résidence (validé Q3)
- L'écran "Liste des appartements de la résidence" est supprimé intégralement.
- Aucune route de fallback. Si un appel résiduel pointe vers cet écran, il faut le rediriger (vers liste filtrée ou détail direct).

### R6 — Filtres conservés
- Tous les filtres déjà appliqués dans `LocataireSearchScreen` sont aussi appliqués à la requête carte :
  - `maxPrice`
  - `typeAppart`
  - `nbChambres`
  - `communeName`
  - + autres filtres existants (date, équipements éventuels)
- Les filtres modifiés depuis le bouton "Filtrer" de la carte rechargent les markers.

### R7 — Image lazy
- Le DTO de la carte (`MapAppartementDto`) ne contient PAS d'`imgUrl`.
- L'image n'est chargée qu'au moment du tap marker, via l'endpoint détail appartement existant.
- Affichage du BottomSheet possible avant que l'image arrive : placeholder shimmer puis swap quand chargée.

## 5. Cas d'Usage Principal

1. Locataire ouvre l'écran carte (depuis Home → "Voir carte").
2. La carte se centre sur sa position GPS (ou Abidjan par défaut si refus permission).
3. Markers de prix s'affichent pour les appartements dans la zone visible (coordonnées obfusquées).
4. Locataire pan/zoom → bouton "Rechercher dans cette zone" apparaît.
5. Locataire tap un marker → BottomSheet remonte avec preview (photo lazy, titre, prix, commune, type, chambres).
6. Locataire tap "Voir détails" → push `LocataireDetailScreen`.
7. Si l'appart est réservé (statut confirmé), le détail affiche la mini-carte avec position réelle + bouton itinéraire. Sinon : pas de carte précise.

## 6. Cas Alternatifs / Limites

- **Aucun appart dans la zone** : overlay empty inline ("Aucun appartement dans cette zone, élargissez la recherche").
- **Erreur réseau lors du load markers** : overlay error avec CTA "Réessayer".
- **Erreur réseau lors du chargement preview (tap marker)** : BottomSheet affiche infos textuelles (déjà reçues via marker) + placeholder photo cassée + CTA voir détails toujours actif.
- **Position GPS refusée** : centrage par défaut (Abidjan), markers chargés normalement, FAB "Ma position" demande à nouveau la permission au tap.
- **Tap marker mais user pas connecté** : redirection login (cas peu probable car carte = écran auth).
- **Appel `/real-location` sans réservation au statut `PAYER`/`FINALISER`** : 403 → l'UI affiche la version obfusquée silencieusement.

## 7. Contraintes

- **Confidentialité** : `realLat/realLongi` ne doit JAMAIS transiter dans la réponse `/filtered`, même filtré côté client.
- **Performance** : la liste markers reste légère (pas d'`imgUrl`, ≤ ~200 markers par requête).
- **Cohérence filtres** : strict alignement avec `LocataireSearchScreen` (les mêmes filtres produisent les mêmes résultats sur liste classique et sur carte).
- **MVP** : pas de clustering, pas de marker highlight quand sélectionné. À envisager V10 si superposition gêne.
- **Backend non bloquant** : le travail Flutter peut avancer avec un mock JSON tant que l'endpoint `/api/map/appartements/filtered` n'est pas dispo.

## 8. Critères d'Acceptation

- [ ] `MapResidence` et tous ses usages supprimés du code Flutter
- [ ] `MapAppartement` créé avec les champs spécifiés (dual coords + price + typeAppart + nbChambres + communeName)
- [ ] Endpoint Flutter `/api/map/appartements/filtered` consommé, retour mappé en `List<MapAppartement>`
- [ ] Marker affiche le prix unitaire de chaque appart
- [ ] Tap marker → BottomSheet avec photo lazy, titre, ligne info, CTA push détail
- [ ] CTA "Voir détails" push direct `LocataireDetailScreen` (plus de liste résidence intermédiaire)
- [ ] `realLat/realLongi` jamais utilisés pour les markers (toujours `displayPosition`)
- [ ] Filtres `LocataireSearchScreen` appliqués à la requête carte
- [ ] Empty/Error states adaptés au nouveau modèle
- [ ] `flutter analyze` : 0 nouvelle erreur
- [ ] Documentation HTML feature mise à jour (V9.7 → V9.7b)
