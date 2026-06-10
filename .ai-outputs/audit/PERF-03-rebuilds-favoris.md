# PERF-03 — Rebuilds en cascade sur les listes (favoris)

> **Axe :** Fluidité · **Sévérité :** 🟡 Moyenne (🔴 tant que PERF-01 n'est pas fait) · **Effort :** ~½ journée

## Problème

Les `BlocBuilder` sont posés trop haut ou trop largement dans les listes :

- `lib/screen/.../recommended_listings_list.dart:38` — chaque
  `AppartementPreviewCard` est enveloppée d'un `BlocBuilder<FavoriteBloc, FavoriteState>`
  qui rebuild **toutes les cartes** dès qu'un seul favori change. Un like sur 1 item
  → 20 cartes reconstruites → 20 images relancées (tant que PERF-01 n'est pas en place).
- `favorite_screen.dart:59-62` — `BlocBuilder<FavoriteBloc>` imbriqué dans
  `BlocBuilder<AppartementBloc>` : tout changement de l'un reconstruit l'arbre entier.
- `home_screen.dart:~125` — `BlocBuilder` englobant toute la `ListView` : un changement
  d'état reconstruit la liste complète.
- Peu d'usage de `const` sur les widgets feuilles des cartes.

## Impact

- Jank au scroll et au like (frames > 16 ms)
- Téléchargements d'images répétés (couplé à PERF-01)

## Marche à suivre

1. **Cibler la reconstruction par item** avec `BlocSelector` : chaque carte n'écoute
   que SON statut de favori :
   ```dart
   BlocSelector<FavoriteBloc, FavoriteState, bool>(
     selector: (state) => state.isFavorite(appartement.id),
     builder: (context, isFav) => FavoriteButton(isFavorite: isFav, ...),
   )
   ```
   Et placer ce selector **autour du seul bouton cœur**, pas autour de la carte entière.
2. **Descendre les BlocBuilder au plus près du widget concerné** dans
   `favorite_screen.dart` et `home_screen.dart` : la `ListView` rebuild uniquement quand
   la **liste** change (`buildWhen: (prev, curr) => prev.items != curr.items`).
3. **Ajouter `buildWhen`** aux `BlocBuilder` larges restants pour filtrer les états
   non pertinents.
4. **Passer les widgets feuilles en `const`** quand possible (icônes, espaceurs, labels
   statiques) — gain gratuit à chaque rebuild.
5. **Mesurer avant/après** avec le Performance Overlay
   (`flutter run --profile`, touche `P`) sur le scénario « scroll feed + like ».

## Validation

- [ ] Un like ne reconstruit que la carte concernée (vérifier avec `debugPrintRebuildDirtyWidgets` ou DevTools « Track widget rebuilds »)
- [ ] Pas de frame > 16 ms pendant le scénario like en mode profile
- [ ] Aucune requête image relancée lors d'un like (avec PERF-01 en place)
