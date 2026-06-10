# PERF-01 — Cache des images réseau (cached_network_image)

> **Axe :** Fluidité · **Sévérité :** 🔴 Impact n°1 sur la fluidité perçue · **Effort :** ~2h

## Problème

Les images sont chargées avec `Image.network` brut, **sans aucun cache** :

- `lib/widget/img/domain_image.dart:45` — le widget central d'affichage d'images :
  ```dart
  : Image.network(url, fit: fit, width: width, height: height,
      errorBuilder: (_, __, ___) => placeholder);
  ```
- 8 occurrences de `Image.network` dans `lib/`
- `cached_network_image` absent du `pubspec.yaml`
- Aucun placeholder de chargement (zone vide pendant le téléchargement)

Chaque rebuild de liste (scroll, changement d'état, like — cf. PERF-03) peut relancer
les téléchargements. Un feed de 20 annonces à ~500 KB/photo = ~10 MB re-téléchargés.

## Impact

- Latence perçue énorme sur 3G/4G (plusieurs secondes par carte)
- Consommation data et batterie inutile
- Effet « images qui clignotent » au scroll

## Marche à suivre

1. **Ajouter les dépendances** :
   ```yaml
   cached_network_image: ^3.4.1
   shimmer: ^3.0.0   # placeholder animé (optionnel mais fort gain UX)
   ```
2. **Modifier UNIQUEMENT `DomainImage`** (`lib/widget/img/domain_image.dart`) — c'est le
   point de passage central, les écrans n'ont pas à changer :
   ```dart
   CachedNetworkImage(
     imageUrl: url,
     fit: fit, width: width, height: height,
     memCacheWidth: cacheWidth,            // voir étape 3
     placeholder: (_, __) => const ImageShimmerPlaceholder(),
     errorWidget: (_, __, ___) => placeholder,
   )
   ```
   Créer `ImageShimmerPlaceholder` dans son propre fichier (règle projet :
   un widget = un fichier).
3. **Limiter le décodage mémoire** : passer `memCacheWidth` proportionnel à la taille
   d'affichage (ex. `(width * devicePixelRatio).round()`) — une vignette de carte n'a
   pas besoin d'être décodée en pleine résolution.
4. **Traquer les `Image.network` restants** hors `DomainImage` :
   ```bash
   grep -rn "Image.network" lib/
   ```
   et les faire passer par `DomainImage` (ou `CachedNetworkImage` directement).
5. **(Phase 2, côté backend)** Servir des variantes redimensionnées
   (`?w=400`) pour ne plus transférer la pleine résolution vers les vignettes.

## Validation

- [ ] Scroll aller-retour sur le feed : les images réapparaissent instantanément (pas de re-téléchargement — vérifier dans les logs réseau / DevTools)
- [ ] Placeholder shimmer visible pendant le premier chargement
- [ ] `grep -rn "Image.network" lib/` → 0 occurrence hors placeholder/assets
