# 📋 Spécification Métier — V9.1 Wizard création appartement (F2)

> **Version :** 1.0
> **Date :** 2026-05-11
> **Status :** ✅ Validée

---

## 1. Contexte

Aujourd'hui un propriétaire qui souhaite ajouter un nouveau logement sur Asfar tombe sur un stub (`'Création d'annonce disponible prochainement (F2)'`). La fonctionnalité d'édition existe déjà (`ListingEditScreen` 4 tabs) mais elle ne couvre pas le parcours de **création initiale**. Le proto `proprietaire-extras.jsx::ProprietaireAddListing` définit un tunnel guidé en 5 étapes qui aide le proprio à structurer la création d'une annonce de A à Z.

## 2. Objectif

Implémenter un tunnel de création d'appartement en **5 étapes** strictement aligné sur le proto, avec brouillon local Hive et publication finale via `AppartementService.saveAppartementWithImages`. Le tunnel est distinct de l'écran d'édition existant (`ListingEditScreen` reste réservé à la modification post-création).

## 3. Acteurs

- **Propriétaire** : seul acteur qui crée des annonces via ce tunnel. Démarcheur non concerné.
- **Backend Spring Boot** : reçoit le payload final via endpoint multipart `/api/proprietaire/appartement/new-with-images`.

## 4. Règles Métier

### R1 — Tunnel 5 étapes (proto fidèle)

| Étape | Contenu | Validation |
|---|---|---|
| 1 — Pièces | 5 cards en grille 2 colonnes : `Studio` (pièce unique séjour + coin nuit) · `2 pièces` (séjour + 1 chambre) · `3 pièces` (séjour + 2 chambres) · `4 pièces` (séjour + 3 chambres) · `5+ pièces` (grande résidence) | `rooms` sélectionné |
| 2 — Localisation + Capacité | Titre annonce · Ville (SearchableSelect 10 villes CI) · Commune (SearchableSelect adaptatif selon ville) · Quartier (input libre) · **GpsCapture** (bouton "Activer GPS" → `LocationUtil.getCurrentLatLng`) · Stepper Chambres + SdB · Description (textarea optionnelle) | `title` + `commune` + `area` renseignés |
| 3 — Photos | Card dashed "Téléverser depuis l'appareil" · `image_picker` multi-sélection · grille 3 colonnes 1:1 · badge "Couverture" sur la première photo · compteur "X photos / min. 3" | `photos.length >= 3` |
| 4 — Équipements | 2 sections : **Essentiels** (WiFi · WiFi fibre · Clim · Eau chaude · Cuisine équipée · Lave-linge · Frigo · TV) + **Confort** (Parking · Sécurité 24/7 · Piscine · Salle de sport · Ascenseur · Vue mer · Vue lagune · Balcon) — chips multi-sélection | `amenities.length >= 1` |
| 5 — Prix & Conditions | Prix/nuit input mono · calcul auto commission Asfar 8% (preview "Vous recevez X FCFA sur 5 nuits") · Frais ménage optionnel · 3 toggles règles (Accepter démarcheurs / Caution remboursable / Animaux acceptés) | `price > 0` |

> ⚠️ « Studio » et « 1 pièce » sont fusionnés en un seul choix `Studio` (équivalents métier chez Asfar).

### R2 — Step indicator visuel

- `TopNav` avec back (étape précédente ou retour liste si step 1) + titre "Nouvelle annonce" + sub "Étape X / 5"
- Progress bar 4px sous le header : `bgElev2` rail + `accent` fill animé (`width: (step/5)*100%`, transition 300ms)
- CTA bottom block : "Continuer" (steps 1-4) ou "Publier mon annonce" (step 5)
- CTA grisé (opacity 0.4) si `!canNext`

### R3 — Géolocalisation (Q4 validée)

- L'utilisateur tape **"Activer GPS"** dans le `GpsCapture` widget (étape 2)
- Flutter appelle `LocationUtil.getCurrentLatLng()` (déjà utilisé V9.7 carte)
- Si permission accordée → coords capturées, preview mini-carte (cohérent style V9.7c `MiniMapPreview`)
- L'utilisateur peut **"Recapturer"** à tout moment pour refresh
- Si refusé OS → SnackBar "Activez la géolocalisation dans les paramètres" (réutilise pattern V9.7)
- Coords envoyées au backend dans `geoLat`/`geoLongi` du payload `AddressReq` (cf. `BACKEND_NOTES_MAP_V9_7B.md`)
- **Pas de picker drag pin** dans MVP (le proto n'en propose pas)

### R4 — Sauvegarde Hive draft + serveur en fin (Q2 validée)

- À chaque changement de champ : sauvegarde silencieuse en Hive box `appartement_draft` (clé `currentDraft`)
- Si l'utilisateur quitte le tunnel à mi-parcours : pas de prompt, juste laisse partir
- À la réouverture du tunnel : si un draft existe, dialog "Vous avez une création en cours. Reprendre ?" / "Recommencer" (efface le draft)
- Le draft contient : tous les champs des 5 étapes + l'étape courante (`currentStep`) + paths locaux des photos picked (pas les bytes — référence file path)
- **Save serveur uniquement au tap "Publier mon annonce"** : `AppartementBackendMapper.toCreatePayload` + `AppartementService.saveAppartementWithImages` (multipart car photos)
- Sur succès → purge du draft Hive + push back vers `ProprioListingsScreen` + SnackBar succès + `AppartementBloc.add(RefreshAppartements())`
- Sur erreur réseau → SnackBar erreur + reste sur l'étape 5 (draft Hive intact pour retry)

### R5 — Édition vs Création (Q3 validée)

- Création = nouveau tunnel `ProprioNewListingScreen` (wizard guidé)
- Édition = `ListingEditScreen` existant (4 tabs Infos/Réductions/Règles/Calendar inchangé)
- Pas de mode unifié — un proprio qui veut juste changer le prix d'un appart existant ne doit pas repasser un wizard 5 étapes
- Pattern Airbnb/Booking : créer = parcours guidé / éditer = champs directs

### R6 — Validation par étape (proto fidèle)

- Le bouton "Continuer" est désactivé si l'étape courante n'a pas tous ses champs requis (cf. R1 colonne Validation)
- Aucune validation cross-étape avant le save final
- Erreurs serveur (ex: titre déjà existant) affichées en SnackBar à l'étape 5 sans bloquer

## 5. Cas d'Usage Principal

1. Proprio ouvre `ProprioListingsScreen` (onglet Annonces de son shell)
2. Tap sur la `NewListingCard` (carte en bas de la liste)
3. Push `ProprioNewListingScreen` étape 1
4. Sélectionne nombre de pièces → "Continuer"
5. Étape 2 : remplit titre + ville + commune + quartier + tape "Activer GPS" (capture position) + ajuste chambres/SdB → "Continuer"
6. Étape 3 : tape la card dashed → ouvre `image_picker` multi-sélection → choisit 3+ photos depuis galerie → preview grille → "Continuer"
7. Étape 4 : sélectionne équipements (WiFi, Clim, Parking...) → "Continuer"
8. Étape 5 : saisit prix (ex: 45000) → preview commission auto → ajuste règles toggles → tape "Publier mon annonce"
9. Loading state spinner + serveur upload → succès → push back vers `ProprioListingsScreen` + SnackBar "Annonce publiée"
10. La nouvelle annonce apparaît dans la liste

## 6. Cas Alternatifs / Limites

- **Reprise de brouillon** : à la réouverture après sortie en cours, dialog "Reprendre" / "Recommencer"
- **Permission GPS refusée** : SnackBar discret, coords non requis pour avancer (backend fera fallback geocoding depuis adresse texte)
- **Pas de connexion au moment du Publier** : draft Hive intact, SnackBar erreur retry possible
- **Erreur upload photo (taille > 10MB, format invalide)** : message dédié par photo, retire la photo invalide, continuer avec les valides
- **App killée pendant le tunnel** : draft Hive persiste, reprise au prochain launch
- **App killée pendant upload final** : draft Hive intact (purgé uniquement après succès serveur 200), retry possible
- **Backend renvoie 400 (validation)** : afficher message serveur en SnackBar à l'étape 5
- **Backend renvoie 401 (token expiré)** : redirect login (pattern existant `DioRequest`)

## 7. Contraintes

- **Cohérence proto** : étapes, validations, copy française, ordre exact selon `proprietaire-extras.jsx::ProprietaireAddListing`
- **Réutilisation** : pattern tunnel V5 `LocataireReserveScreen` (`int _step` + setState), `LocationUtil.getCurrentLatLng`, `image_picker ^1.1.2`, `AppartementService` + `AppartementBackendMapper`, palette Asfar Premium, `CustomButton lg block`, `AsfarChip`, `MiniMapPreview` V9.7c pour preview GPS
- **Performance** : draft Hive sync (pas async box), pas de spinner pendant la frappe, upload final avec progress
- **Photos** : min 3, max 8 (proto), format `JPG/PNG/HEIC ≤ 10MB chacune`
- **Pas de réductions complexes** dans le wizard (paliers) — réservé à `ListingEditScreen` tab Réductions
- **Pas de gestion calendrier** dans le wizard — déjà dans `ListingEditScreen` tab Calendar
- **MVP scope** : pas de preview prévisualisation finale avant publication

## 8. Critères d'Acceptation

- [ ] `NewListingCard.onTap` push `ProprioNewListingScreen` (plus de stub)
- [ ] 5 étapes alignées proto avec validation par étape
- [ ] Step indicator (TopNav + progress bar) + CTA bottom adaptatif
- [ ] `GpsCapture` widget avec bouton "Activer GPS" + preview mini-carte
- [ ] `image_picker` multi-sélection minimum 3 max 8 photos
- [ ] Draft Hive sauvegardé à chaque modif + reprise dialog
- [ ] Publier → `saveAppartementWithImages` multipart → succès = push back + RefreshAppartements
- [ ] Erreurs réseau / 400 / 401 gérées via SnackBar discrets
- [ ] `flutter analyze` : 0 nouvelle erreur
- [ ] Documentation HTML créée (nouvelle feature, pas update)
