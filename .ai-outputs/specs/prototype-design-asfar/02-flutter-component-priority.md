# 🎨 Asfar Flutter — Priorité de composants à matcher le prototype

> **Cible :** porter le design system **Asfar Dark Premium** du prototype HTML React vers Flutter.
> **Contraintes projet :** 10 règles Flutter (1 widget = 1 fichier, helpers dédiés, pas de fonction privée retournant Widget, etc.). Voir `SOLID_GUIDELINES.md`.
> **Règle SOLID :** appliquée au **nouveau code uniquement** — l'existant ne se refactore pas opportunistiquement.

---

## 🪜 Stratégie en 4 vagues

| Vague | Objectif | Nb widgets | Effort |
|---|---|---|---|
| **🥇 V1 — Fondations** | Theme, tokens, primitives | ~10 | 1-2 jours |
| **🥈 V2 — Atomes UI** | Btn, chip, badge, card, input, listrow | ~12 | 2-3 jours |
| **🥉 V3 — Molécules** | Stat, ListingCard, ReferralRow, BottomBar, Sparkbar | ~10 | 3-4 jours |
| **🏁 V4 — Écrans** | Onboarding, Detail, Réserve, Dashboard, etc. | par feature | itératif |

Chaque widget respecte : **1 fichier, 1 classe, dossier `widgets/asfar/`** par défaut, ou **`features/<feature>/widgets/`** s'il est local à un écran.

---

## 🥇 VAGUE 1 — Fondations (PRIORITÉ ABSOLUE)

> À faire avant tout : sans ces tokens, tous les widgets seront incohérents.

### 1.1 `lib/theme/asfar_colors.dart`

Constantes de couleurs centralisées (équivalent des CSS vars).

```dart
class AsfarColors {
  // Backgrounds
  static const bg = Color(0xFF0A0A0B);
  static const bgElev1 = Color(0xFF131316);
  static const bgElev2 = Color(0xFF1C1C20);
  static const bgElev3 = Color(0xFF25252B);

  // Lines
  static const line = Color(0x14FFFFFF);        // rgba(255,255,255,0.08)
  static const lineStrong = Color(0x24FFFFFF);  // rgba(255,255,255,0.14)

  // Text
  static const text = Color(0xFFF5F5F7);
  static const text2 = Color(0xFFB8B8BE);
  static const text3 = Color(0xFF76767E);
  static const textDim = Color(0xFF4A4A52);

  // Accent (signature)
  static const accent = Color(0xFFE8B86B);       // gold chaud
  static const accent2 = Color(0xFFC99650);
  static const accentSoft = Color(0x24E8B86B);   // rgba 0.14
  static const onAccent = Color(0xFF1A1206);     // texte sur or

  // Semantic
  static const success = Color(0xFF4ADE80);
  static const warn = Color(0xFFF4B740);
  static const danger = Color(0xFFF87171);
  static const info = Color(0xFF60A5FA);

  // Mobile money operators
  static const orangeMoney = Color(0xFFFF6B00);
  static const wave = Color(0xFF1DC4D5);
  static const mtnMomo = Color(0xFFFFCC00);
  static const cardPay = Color(0xFF5E6CFF);
}
```

### 1.2 `lib/theme/asfar_radii.dart`

```dart
class AsfarRadii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const pill = 999.0;
}
```

### 1.3 `lib/theme/asfar_text_styles.dart`

7 niveaux typographiques + variants mono.

```dart
class AsfarTextStyles {
  static const _baseFamily = 'SF Pro Display'; // ou fallback system

  static const display = TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
      letterSpacing: -0.6, height: 1.05, color: AsfarColors.text);
  static const h1 = TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
      letterSpacing: -0.4, height: 1.15);
  static const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
      letterSpacing: -0.3, height: 1.2);
  static const h3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w600,
      letterSpacing: -0.2);
  static const body = TextStyle(fontSize: 15, height: 1.45,
      color: AsfarColors.text2);
  static const small = TextStyle(fontSize: 13, color: AsfarColors.text2);
  static const eyebrow = TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      letterSpacing: 1.2, color: AsfarColors.text3);
  // mono variants — appliquer fontFeatures: [FontFeature.tabularFigures()]
  static TextStyle mono(TextStyle base) => base.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()]);
}
```

### 1.4 `lib/theme/asfar_theme.dart`

`ThemeData.dark()` configuré avec `ColorScheme.fromSeed(Color(0xFFE8B86B))`, override `scaffoldBackgroundColor`, `cardTheme`, `inputDecorationTheme`.

### 1.5 `lib/utils/fcfa_formatter.dart`

```dart
class FcfaFormatter {
  static String full(num n);    // "1 900 000 FCFA"
  static String compact(num n); // "1.9 M FCFA" / "45 k FCFA"
}
```

### 1.6 `lib/widgets/asfar/asfar_image_placeholder.dart` (`AsfarImgPh`)

Reproduit `.img-ph` : `Container` avec `LinearGradient` 135deg + `BoxDecoration` qui empile un overlay en `RadialGradient`. **4 variantes par `tone` (1-4)**.

### 1.7 `lib/widgets/asfar/asfar_map_placeholder.dart` (`AsfarMapPh`)

`CustomPaint` qui dessine la grille 28px + halos radiaux. Accepte enfant pour superposer pins.

### 1.8 `lib/widgets/asfar/asfar_avatar.dart` (`AsfarAvatar`)

Cercle 36px par défaut, gradient `linear-gradient(135deg, #C99650, #5A3A1A)`, initiales centrées (param `name` → 2 premières lettres).

### 1.9 `lib/widgets/asfar/asfar_icon.dart`

Wrapper d'icônes : utiliser `lucide_icons` package (très proche du set custom du proto), ou redessiner les ~60 icônes en `CustomPainter` paths.

> **Recommandation :** commencer avec `lucide_icons_flutter` ou `material_symbols_icons` pour la V1, redessiner si nécessaire en V4.

### 1.10 `lib/widgets/asfar/asfar_blur_container.dart` (`AsfarBlurContainer`)

`BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))` avec `saturation` via `ColorFilter.matrix` — équivalent du `backdrop-filter: blur(20px) saturate(180%)`. **Critique** pour bottom bars et tab bar iOS-like.

---

## 🥈 VAGUE 2 — Atomes UI (12 widgets)

> Building blocks réutilisables. Tous dans `lib/widgets/asfar/`.

### 2.1 `asfar_button.dart` (`AsfarButton`)

Variantes : `primary`, `secondary`, `ghost`. Tailles : `sm` / `md` (default) / `lg`. Option `block: true` pour width 100%. `transform: scale(0.97)` à l'appui → `AnimatedScale` ou `GestureDetector` + `AnimatedContainer`.

### 2.2 `asfar_chip.dart` (`AsfarChip`)

Pill rounded 999 avec état actif (fond `accent-soft`, border `rgba(232,184,107,0.3)`, texte accent).

### 2.3 `asfar_badge.dart` (`AsfarBadge`)

Enum `AsfarBadgeTone { success, warn, info, danger, accent, neutral }`. Pattern : fond couleur × 0.14, texte couleur saturée. **Usage massif** (statuts annonces, certifié, NOUVEAU, etc.).

### 2.4 `asfar_card.dart` (`AsfarCard`)

`Container` avec `bgElev1` + border line + radius lg. Param `padding`, `dashed: bool` (pour la card "Nouvelle annonce"), `gradient: Gradient?` (pour les hero cards).

### 2.5 `asfar_input.dart` (`AsfarInput`)

`TextField` avec décoration `bgElev2`, border line, focus border accent, padding 14×16, radius 12. Variant `display` (non-éditable, juste affichage de valeur sur fond input — pour les champs Date qui ouvrent un picker).

### 2.6 `asfar_listrow.dart` (`AsfarListRow`)

Row avec gap 12, padding 14×16, divider bottom. Slots : `leading`, `title`, `subtitle`, `trailing`. **Très utilisé** dans les listes de réservations, conversations, transactions.

### 2.7 `asfar_top_nav.dart` (`AsfarTopNav`)

Reproduit le `<TopNav>` : padding-top 56 (safe area iOS), 3 colonnes (left 40, center flex, right 40), `title` h3, `subtitle` eyebrow optionnelle.

### 2.8 `asfar_icon_button.dart` (`AsfarIconButton`)

Bouton rond 36px par défaut, fond `bgElev2`, border line, contient un icon. Variant `floating` pour les boutons sur image (back/share/heart sur fiche detail).

### 2.9 `asfar_radio.dart` (`AsfarRadio`)

Cercle 20px, border 1.5px text-3 inactif → border 6px accent + fond bg actif. Custom radio cohérente avec le design.

### 2.10 `asfar_section_header.dart` (`AsfarSectionHeader`)

Row entre h3 (titre) et lien accent (« Voir tout »), padding 18×10. Très récurrent.

### 2.11 `asfar_divider.dart` (`AsfarDivider`)

`Container(height: 1, color: AsfarColors.line)` avec margin 16×18 par défaut.

### 2.12 `asfar_bottom_bar.dart` (`AsfarBottomBar`)

Container sticky en bas avec `AsfarBlurContainer` + border-top + padding 14×18×30. Slots `left` (info) + `action` (CTA primary). **Pattern récurrent** sur Detail, Reserve, Search.

---

## 🥉 VAGUE 3 — Molécules (10 composants)

### 3.1 `asfar_tab_bar.dart` (`AsfarTabBar`)

5 onglets configurables par rôle. Item = icon + label, état actif en accent or, blur background. Construction depuis une liste `List<AsfarTab>` avec id/label/iconName.

### 3.2 `asfar_stat_card.dart` (`AsfarStatCard`)

Card 14×16 : eyebrow + valeur 22px mono bold + ligne delta (arrow ↑/↓ + % + "vs. mois dern."). Couleur du delta selon signe.

### 3.3 `asfar_listing_card.dart` (`AsfarListingCard`)

Carte complète d'annonce (utilisée par locataire home + propriétaire listings) :
- ImgPh 16:10 + badges flottants (heart, certifié, photo dots).
- Body : titre h3 + note + lieu + ligne icons (bed/bath/wifi) + prix/nuit + total nuits.
- Param `compact: bool` pour la version dashboard propriétaire (img 64px à gauche).

### 3.4 `asfar_listing_grid_card.dart` (`AsfarListingGridCard`)

Card carrée pour grid 2 cols (Saved screen) — variante simplifiée.

### 3.5 `asfar_referral_row.dart` (`AsfarReferralRow`)

Ligne de demande démarcheur : img tone + client + badge statut + listing/nuits + date + commission accent à droite.

### 3.6 `asfar_payment_method_tile.dart` (`AsfarPaymentMethodTile`)

ListRow avec badge couleur opérateur (38×38, fond color×0.14, initiales) + nom + masque + radio. Pour OM/Wave/MTN/Card.

### 3.7 `asfar_sparkbar.dart` (`AsfarSparkbar`)

Mini bar chart 6 barres alignées en bas, hauteur normalisée. Param `highlightLast: bool` (dernière barre en accent or). Utilisé dans dashboard propriétaire.

### 3.8 `asfar_stacked_bar.dart` (`AsfarStackedBar`)

Barre horizontale 14px segmentée en N parties colorées (utilisée dans le flux financier propriétaire). Construction depuis `List<({Color color, double pct, String label, num value})>`.

### 3.9 `asfar_step_timeline.dart` (`AsfarStepTimeline`)

Liste verticale d'étapes (cercle + ligne entre étapes). Param `currentIndex: int`, `steps: List<TimelineStep>`. Étape courante en accent or, avant en success, après en gris. Pour `DemarcheurReferralDetail`.

### 3.10 `asfar_success_circle.dart` (`AsfarSuccessCircle`)

Cercle 88×88 accent or avec icon centré + double halo concentrique (`BoxShadow` avec spreadRadius 14 + 28). Utilisé sur les écrans de confirmation (réservation, demande envoyée). Param `iconName` (check pour locataire, send pour démarcheur).

---

## 🏁 VAGUE 4 — Composants d'écran (par feature)

> À créer **lazy** au moment d'implémenter chaque feature, dans `lib/features/<feature>/widgets/`.

### 4.1 Locataire

| Widget | Fichier | Écran |
|---|---|---|
| `LocataireHomeHeader` | `features/locataire_home/widgets/locataire_home_header.dart` | Greeting + search bar tappable |
| `LocataireSearchBar` | `features/locataire_home/widgets/locataire_search_bar.dart` | Card avec icon + texte + bouton sliders or |
| `LocataireFeaturedCarousel` | `features/locataire_home/widgets/locataire_featured_carousel.dart` | Cards 4:5 horizontales |
| `LocataireMapTeaser` | `features/locataire_home/widgets/locataire_map_teaser.dart` | MapPh + 4 pins prix |
| `LocataireFilterSheet` | `features/locataire_search/widgets/locataire_filter_sheet.dart` | BottomSheet filtres complets |
| `LocataireDetailHero` | `features/locataire_detail/widgets/locataire_detail_hero.dart` | Galerie 1:1 + indicateurs photo |
| `LocataireQuickSpecs` | `features/locataire_detail/widgets/locataire_quick_specs.dart` | 4 colonnes avec dividers |
| `LocataireHostCard` | `features/locataire_detail/widgets/locataire_host_card.dart` | Avatar + nom + certifié + contacter |
| `LocataireAmenitiesGrid` | `features/locataire_detail/widgets/locataire_amenities_grid.dart` | Grid 2 cols icons + label |
| `LocataireReviewsCarousel` | `features/locataire_detail/widgets/locataire_reviews_carousel.dart` | Carrousel 240px |
| `LocataireReserveSummary` | `features/locataire_reserve/widgets/locataire_reserve_summary.dart` | Card prix détail (sous-total + frais + total) |
| `LocataireReserveStepIndicator` | `features/locataire_reserve/widgets/locataire_reserve_step_indicator.dart` | Sub "Étape n/3" dans top nav |
| `LocataireTripCard` | `features/locataire_trips/widgets/locataire_trip_card.dart` | Card horizontale img + content + footer 3 btns |

### 4.2 Propriétaire

| Widget | Fichier | Écran |
|---|---|---|
| `ProprietaireRevenueHero` | `features/proprietaire_dashboard/widgets/proprietaire_revenue_hero.dart` | Hero card or avec sparkbar 6 mois |
| `ProprietaireKpiGrid` | `features/proprietaire_dashboard/widgets/proprietaire_kpi_grid.dart` | 2×2 stats (occupation/ADR/réservations/note) |
| `ProprietaireCashflowCard` | `features/proprietaire_dashboard/widgets/proprietaire_cashflow_card.dart` | Stacked bar + légende montants |
| `ProprietaireListingMiniCard` | `features/proprietaire_dashboard/widgets/proprietaire_listing_mini_card.dart` | 4 cards horizontales compactes |
| `ProprietairePendingRequestRow` | `features/proprietaire_dashboard/widgets/proprietaire_pending_request_row.dart` | Avatar + qui + badge NOUVEAU + arrow |
| `ProprietairePeriodSwitcher` | `features/proprietaire_finances/widgets/proprietaire_period_switcher.dart` | Segmented control 4 options |
| `ProprietairePnLCard` | `features/proprietaire_finances/widgets/proprietaire_pnl_card.dart` | Compte de résultat (revenus + charges + bénéfice) |
| `ProprietairePerformanceRow` | `features/proprietaire_finances/widgets/proprietaire_performance_row.dart` | Img + titre + barre occupation + revenus + delta |
| `ProprietaireForecastChart` | `features/proprietaire_finances/widgets/proprietaire_forecast_chart.dart` | Line chart SVG (passé solid + futur dashed + area gradient) |
| `ProprietaireListingFullCard` | `features/proprietaire_listings/widgets/proprietaire_listing_full_card.dart` | Card 16:9 + badges + 3 KPI + 3 btns ghost |
| `ProprietaireNewListingPlaceholder` | `features/proprietaire_listings/widgets/proprietaire_new_listing_placeholder.dart` | Card dashed + "+ Nouvelle annonce" |
| `ProprietaireFieldRow` | `features/proprietaire_listing_edit/widgets/proprietaire_field_row.dart` | Card eyebrow + valeur + edit icon |
| `ProprietaireUnderlineTabs` | `features/proprietaire_listing_edit/widgets/proprietaire_underline_tabs.dart` | Tabs Infos/Calendrier/Tarifs/Règles |
| `ProprietaireBookingCalendar` | `features/proprietaire_listing_edit/widgets/proprietaire_booking_calendar.dart` | Grid 7×N coloré (réservé/attente/today) + légende |

### 4.3 Démarcheur

| Widget | Fichier | Écran |
|---|---|---|
| `DemarcheurWalletHero` | `features/demarcheur_dashboard/widgets/demarcheur_wallet_hero.dart` | Hero card bleu-nuit + sub-stats inline |
| `DemarcheurReferralCta` | `features/demarcheur_dashboard/widgets/demarcheur_referral_cta.dart` | Card or « Envoyer un client » |
| `DemarcheurStatusPills` | `features/demarcheur_dashboard/widgets/demarcheur_status_pills.dart` | 3 cards centrées (en attente/acceptées/taux) |
| `DemarcheurPushListingCard` | `features/demarcheur_dashboard/widgets/demarcheur_push_listing_card.dart` | Card 200px avec commission estimée + btn Référer |
| `DemarcheurNewStepListing` | `features/demarcheur_new/widgets/demarcheur_new_step_listing.dart` | Liste cards radio sélectionnable |
| `DemarcheurNewStepClient` | `features/demarcheur_new/widgets/demarcheur_new_step_client.dart` | Form nom/tel/dates/note + banner commission |
| `DemarcheurReferralStatusTimeline` | `features/demarcheur_referral_detail/widgets/demarcheur_referral_status_timeline.dart` | 5 étapes verticales avec ronds reliés |
| `DemarcheurCommissionCard` | `features/demarcheur_referral_detail/widgets/demarcheur_commission_card.dart` | Card or sous-total → taux → à recevoir |
| `DemarcheurWithdrawableHero` | `features/demarcheur_wallet/widgets/demarcheur_withdrawable_hero.dart` | Solde dispo + btn Retirer + sub versement auto |
| `DemarcheurTransactionRow` | `features/demarcheur_wallet/widgets/demarcheur_transaction_row.dart` | Icon arrow + label + montant signé |

### 4.4 Transverses

| Widget | Fichier | Écran |
|---|---|---|
| `OnboardingRoleCard` | `features/onboarding/widgets/onboarding_role_card.dart` | Card avec icon badge + titre + sub + arrow |
| `OnboardingHero` | `features/onboarding/widgets/onboarding_hero.dart` | Logo + display title + body |
| `MessageBubble` | `features/messaging/widgets/message_bubble.dart` | Bubble me/them avec radius asymétrique |
| `MessageReservationCard` | `features/messaging/widgets/message_reservation_card.dart` | Card spéciale "RÉSERVATION" embeddée |
| `MessageAcceptCard` | `features/messaging/widgets/message_accept_card.dart` | Card "Demande acceptée" (démarcheur) |
| `MessagingThreadHeader` | `features/messaging/widgets/messaging_thread_header.dart` | Header custom avatar + nom + shield + phone |
| `MessagingComposer` | `features/messaging/widgets/messaging_composer.dart` | Input + btn plus + btn rond send accent |
| `ConversationListRow` | `features/messaging/widgets/conversation_list_row.dart` | Avatar + nom + badge rôle + preview + heure + unread |
| `ProfileHeroCard` | `features/profile/widgets/profile_hero_card.dart` | Avatar 78 + nom + shield + badge top |
| `ProfileRoleSwitcher` | `features/profile/widgets/profile_role_switcher.dart` | Card avec 3 listrows rôles |
| `ProfileSettingsList` | `features/profile/widgets/profile_settings_list.dart` | Listrows compte/paiement/notif/préf |

---

## 📋 Checklist par vague

### Vague 1 (gate de démarrage)
- [ ] Tokens couleurs centralisés dans `AsfarColors`
- [ ] Échelle typographique dans `AsfarTextStyles`
- [ ] `ThemeData` dark configuré et appliqué globalement dans `MaterialApp`
- [ ] `FcfaFormatter` testé (cas 0, 999, 1k, 999k, 1M)
- [ ] `AsfarImgPh` × 4 tones rendu cohérent
- [ ] `AsfarMapPh` avec grille + halos visible
- [ ] `AsfarAvatar` avec initiales auto-extraites
- [ ] `AsfarBlurContainer` testé sur iOS + Android (fallback opaque sur Android < 12)
- [ ] Pack d'icônes choisi et installé (lucide_icons recommandé)

### Vague 2 (composants atomiques)
- [ ] `AsfarButton` × 3 variants × 3 tailles, scale-on-press testée
- [ ] `AsfarChip` état actif visible
- [ ] `AsfarBadge` × 6 tons
- [ ] `AsfarCard` avec gradient et dashed support
- [ ] `AsfarInput` focus border accent
- [ ] `AsfarListRow` avec divider auto sauf dernière ligne
- [ ] `AsfarTopNav` avec safe area iOS
- [ ] `AsfarBottomBar` avec blur

### Vague 3 (molécules)
- [ ] `AsfarTabBar` × 3 configs (locataire / propriétaire / démarcheur)
- [ ] `AsfarStatCard` avec delta coloré
- [ ] `AsfarListingCard` × 2 modes (full + compact)
- [ ] `AsfarSparkbar` 6 barres
- [ ] `AsfarStackedBar` avec légende
- [ ] `AsfarStepTimeline` avec étape courante highlight
- [ ] `AsfarSuccessCircle` halo concentrique

### Vague 4 (lazy par feature)
> À cocher au fur et à mesure des features livrées.

---

## ⚠️ Points d'attention Flutter spécifiques

### 1. `backdrop-filter` / Liquid Glass

`BackdropFilter` Flutter n'a pas le `saturate(180%)` natif. Pour reproduire :

```dart
ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      color: AsfarColors.bg.withOpacity(0.85),
      // saturation via ColorFilter.matrix si besoin
    ),
  ),
)
```

> Sur Android < 12, le blur peut être coûteux ou non supporté. Prévoir un fallback opaque (`bgElev1` solid) via `Theme.of(context).platform`.

### 2. Letter-spacing négatif

iOS rend le letter-spacing négatif fidèlement, Android moins. **Tester sur les 2 OS** les titres `display` et `h1` (jusqu'à `-1.0`).

### 3. SF Pro Display

Pas de licence redistribuable. Sur Android, prévoir un fallback proche : **Inter** (`google_fonts: ^6.2`) avec `letterSpacing` retouché, ou la police système `system-ui`.

### 4. Tabular numerals

Critique pour les colonnes de prix alignées (`fmtFCFA` sur les listrows transactions).

```dart
TextStyle(fontFeatures: [FontFeature.tabularFigures()])
```

### 5. Charts

Les charts sont **simples** (sparkbar = bars + heights, P&L bar = stack horizontal, forecast = path SVG). Pas besoin de `fl_chart` lourd — du `CustomPainter` natif suffit et reste cohérent avec l'esthétique.

### 6. Gradients radiaux pour `ImgPh`

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Color(0xFF2A2118), Color(0xFF181410), Color(0xFF0F0C08)],
      stops: [0.0, 0.6, 1.0],
    ),
  ),
  child: Stack(children: [
    Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.6), // 30%, 20%
          radius: 0.6,
          colors: [Color(0x2EE8B86B), Colors.transparent],
        ),
      ),
    ),
  ]),
)
```

### 7. Naming convention

- Tous les widgets du design system : préfixe **`Asfar`** (`AsfarButton`, `AsfarCard`, …) → repérage immédiat dans le code et dans le `widgets/asfar/` dir.
- Widgets locaux à un écran : préfixe **par rôle/feature** (`LocataireHostCard`, `ProprietaireRevenueHero`).
- Pas de nom générique réutilisé partout (pas de `Header.dart` × 3) → respect règle 9 (widgets locaux).

---

## 🎯 Definition of Done

Un widget est « done » quand :
- ✅ 1 fichier, 1 classe (règle 4).
- ✅ Pas de fonction privée retournant `Widget` (règle 1).
- ✅ Story `golden_test` ou screenshot manuel comparé au prototype.
- ✅ Variantes testées (tones 1-4 pour ImgPh, 6 tons pour Badge, 3 variants pour Button).
- ✅ Compatibilité iOS + Android (blur, fonts, letter-spacing).
- ✅ Documentation 1 ligne sur le widget si comportement non-évident.

---

## 🔗 Liens

- **Inventaire des écrans :** [`01-prototype-screens-analysis.md`](./01-prototype-screens-analysis.md)
- **Sources extraites :** `.ai-outputs/prototype-extract/`
  - `shared.jsx` — primitives + `LISTINGS` mock
  - `locataire.jsx`, `proprietaire.jsx`, `demarcheur.jsx`, `extras.jsx` — écrans
  - `app.jsx` — shell de routage
- **Règles projet :** `SOLID_GUIDELINES.md`, `~/.claude/CLAUDE.md` (10 règles Flutter)
