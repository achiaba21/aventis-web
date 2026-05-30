# 🎨 Design UI Validé — Bandeau hors-ligne

> Feature : `resilience-reseau-rejeu-auto`
> Validé par l'utilisateur le 2026-05-30

## Option choisie : **A — Pill flottante en bas**

### Placement
- Wrapper global injecté via `MaterialApp.builder` → `AppConnectivityOverlay(child: ...)`.
- `Stack` : `child` (l'app) + `Positioned` en bas-centre pour la pill.
- Pill flottante centrée horizontalement, ancrée en bas, **au-dessus** de la bottom-nav (offset bas + `SafeArea` bottom).
- Ne pousse aucun layout, ne masque pas le contenu (cache reste visible/scrollable).
- Apparition/disparition : **slide vertical (depuis le bas) + fade**, via `AnimatedSlide` + `AnimatedOpacity` (ou `AnimatedSwitcher`). Durée ~250 ms, courbe `easeOut`.

### Composants à Créer
- `lib/widget/feedback/offline_banner.dart` → `OfflineBanner` (StatelessWidget). La pill elle-même.
- `lib/widget/feedback/app_connectivity_overlay.dart` → `AppConnectivityOverlay` (StatelessWidget). Stack global + Positioned, lit `ConnectivityCubit` via `BlocBuilder` pour décider visible/masqué.

### Composants à Réutiliser
- Langage visuel de `lib/widget/feedback/stale_badge.dart` (pill `bgElev2` + border `line`, radius `pill`, icon 12, texte 11-12).
- `lib/widget/loader/` (spinner) — petit indicateur circulaire or à la place de l'icône, OU `Icons.cloud_off` 12px.
- `AppColors`, `AppRadii.pill`, `AppTextStyles`.

### Contraintes Visuelles
- **Fond** : `AppColors.bgElev2` (#1C1C20), border `AppColors.line` (blanc 8%), radius `AppRadii.pill`.
- **Texte** : « Hors ligne — reconnexion… », taille 12, couleur `AppColors.text2`.
- **Indicateur** : petit `CircularProgressIndicator` (strokeWidth ~1.5, taille ~12, couleur `AppColors.accent`) OU icône `Icons.cloud_off` 12 `text3`. Recommandé : spinner or pour signaler la tentative active.
- **Padding** pill : `EdgeInsets.symmetric(horizontal: 14, vertical: 8)`.
- **Ombre** : `AppColors.shadow` légère (la pill flotte au-dessus du contenu).
- **AUCUN bouton** « Réessayer » (rejeu 100 % auto).
- Offset bas : ~16 px + `MediaQuery.padding.bottom` (SafeArea), de façon à flotter au-dessus de la bottom-nav.

### Règles Flutter respectées
- 1 widget = 1 fichier (OfflineBanner / AppConnectivityOverlay séparés).
- Pas de fonction privée retournant un Widget.
- StatelessWidget, cohérence de style avec les atomes feedback existants.
