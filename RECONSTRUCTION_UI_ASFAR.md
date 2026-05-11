# 🏗️ Reconstruction UI Asfar Premium — Fichier de suivi

> **Démarré le :** 2026-05-09
> **Contexte :** après cleanup total de `lib/screen/` et `lib/widget/`, reconstruction intégrale en suivant le prototype HTML + design system Asfar Dark Premium.
> **Sources :**
> - Prototype HTML : `~/Downloads/Asfar Prototype.html`
> - Extraction JSX : `.ai-outputs/prototype-extract/` (8 fichiers)
> - Specs : `.ai-outputs/specs/prototype-design-asfar/` (3 docs) + `.ai-outputs/specs/refonte-design-asfar/` (4 docs)

---

## 🎯 Règles de reconstruction (NON NÉGOCIABLES)

| # | Règle | Application |
|---|---|---|
| R1 | **Tokens uniquement** | `AppColors.*` / `AppRadii.*` / `AppTextStyles.*` — jamais de `Color(0x...)` ad-hoc, jamais de paddings/sizes magiques |
| R2 | **1 widget = 1 fichier** | Strict (10 règles Flutter du projet) |
| R3 | **Pas de fonction privée → Widget** | Helpers dans fichiers dédiés |
| R4 | **Une classe par fichier** | |
| R5 | **Layout 100% prototype** | Chaque écran reproduit l'écran proto correspondant ; les écrans hors-proto suivent le langage Asfar (cf. ui-proposal F1-F10) |
| R6 | **Branchement BLoC** | Les 22 BLoCs de `lib/bloc/` sont intacts → `BlocBuilder<XxxBloc, XxxState>` standard |
| R7 | **SOLID nouveau code** | Séparation rôles si applicable |
| R8 | **Réutilisation max** | Avant de créer, vérifier si un widget Asfar existe déjà |

---

## 📦 Vague 1 — Atomes UI

> Building blocks réutilisables. Tous dans `lib/widget/<thématique>/`.

| # | Widget | Fichier | Statut |
|---|---|---|---|
| 1.1 | `TextSeed` | `lib/widget/text/text_seed.dart` | ✅ |
| 1.2 | `ImgPh` (× 4 tones) | `lib/widget/img/img_placeholder.dart` | ✅ |
| 1.3 | `UserAvatar` | `lib/widget/user/user_avatar.dart` | ✅ |
| 1.4 | `CustomButton` (primary) | `lib/widget/button/custom_button.dart` | ✅ |
| 1.5 | `OutlinedCustomButton` (secondary) | `lib/widget/button/outlined_custom_button.dart` | ✅ |
| 1.6 | `PlainButton` (ghost) | `lib/widget/button/plain_button.dart` | ✅ |
| 1.7 | `IconBoutton` (rond 36px) | `lib/widget/button/icon_boutton.dart` | ✅ |
| 1.8 | `InputField` | `lib/widget/input/input_field.dart` | ✅ |
| 1.9 | `BadgeStatus` (6 tons) | `lib/widget/badge/badge_status.dart` | ✅ |
| 1.10 | `AsfarChip` (state actif accent-soft) | `lib/widget/badge/asfar_chip.dart` | ✅ |
| 1.11 | `BlurContainer` (Liquid Glass) | `lib/widget/container/blur_container.dart` | ✅ |
| 1.12 | `ShimmerCard` (skeleton bgElev3) | `lib/widget/loader/shimmer_card.dart` | ✅ |
| 1.13 | `LoaderCircular` | `lib/widget/loader/loader_circular.dart` | ✅ |
| 1.14 | `AsfarDivider` | `lib/widget/container/asfar_divider.dart` | ✅ |
| 1.15 | `ListRow` | `lib/widget/item/list_row.dart` | ✅ |
| 1.16 | `AsfarRadio` (custom) | `lib/widget/input/asfar_radio.dart` | ✅ |

**Gate vague 1 :** ✅ 16/16 widgets · `flutter analyze` 0 erreur.

---

## 📦 Vague 2 — Layouts

| # | Widget | Fichier | Statut |
|---|---|---|---|
| 2.1 | `DynamicAppBar` (= TopNav proto) | `lib/widget/appbar/dynamic_appbar.dart` | ✅ |
| 2.2 | `BottomNav` + `BottomNavItem` + `BottomNavCell` + `BottomNavTabs` | `lib/widget/bottom_nav/` | ✅ |
| 2.3 | `BottomBar` (sticky blur + CTA) | `lib/widget/bottom_nav/bottom_bar.dart` | ✅ |
| 2.4 | `SectionHeader` (titre + lien "Voir tout") | `lib/widget/text/section_header.dart` | ✅ |
| 2.5 | `ScreenScaffold` (helper de page Asfar) | `lib/widget/container/screen_scaffold.dart` | ✅ |

**Gate vague 2 :** ✅ 5/5 widgets · `flutter analyze` 0 erreur.

---

## 📦 Vague 3 — Onboarding (extras.jsx::Onboarding)

| # | Widget/Écran | Fichier | Statut |
|---|---|---|---|
| 3.1 | `OnboardingScreen` | `lib/screen/onboarding/onboarding_screen.dart` | ✅ |
| 3.2 | `OnboardingHero` (logo + display title) | `lib/screen/onboarding/widget/onboarding_hero.dart` | ✅ |
| 3.3 | `OnboardingRoleCard` (key/home/handshake) | `lib/screen/onboarding/widget/onboarding_role_card.dart` | ✅ |
| 3.4 | `SplashScreen` branché sur Onboarding | `lib/screen/splash_screen.dart` | ✅ |

**Gate vague 3 :** ✅ 4/4 écrans · `flutter analyze` 0 erreur. SplashScreen → OnboardingScreen après 1.5s. Tap rôle / Se connecter = SnackBar (à brancher Vague 4).

---

## 📦 Vague 4 — Auth (F1, option A "continuité prototype")

| # | Écran/Widget | Fichier | Statut |
|---|---|---|---|
| 4.1 | `LoginScreen` | `lib/screen/login/login_screen.dart` | ✅ |
| 4.2 | `LoginForm` (BLoC dispatch + validation) | `lib/screen/login/widget/login_form.dart` | ✅ |
| 4.3 | `SignupScreen` + `SignupForm` | `lib/screen/signup/signup_screen.dart` + `widget/signup_form.dart` | ✅ |
| 4.4 | `OtpVerificationScreen` + `OtpCodeInput` | `lib/screen/signup/otp_verification_screen.dart` + `widget/otp_code_input.dart` | ✅ |
| 4.5 | `RoleSelectionScreen` | ❌ remplacé par Onboarding | ❌ |

**Gate vague 4 :** ✅ 4/4 écrans · `flutter analyze` 0 erreur. Branchement complet :
- Onboarding tap rôle → SignupScreen(role)
- Onboarding "Se connecter" → LoginScreen
- SignupForm → SendOtp → OtpSent → OtpVerificationScreen → VerifyAndSignup → UserLoaded
- LoginForm → LoginUser → UserLoaded
- (post-Login/Signup) home par rôle = SnackBar pour l'instant, redirection à brancher en Vague 5

---

## 📦 Vague 5 — Locataire (5 onglets + écrans secondaires)

### Phase 5A — Molécules ListingCard + Featured ✅

| Widget | Fichier | Statut |
|---|---|---|
| `ListingPreview` (VO) | `lib/widget/card/listing_preview.dart` | ✅ |
| `AppartementPreviewCard` | `lib/widget/card/appartement_preview_card.dart` | ✅ |
| `FeaturedListingCard` | `lib/widget/card/featured_listing_card.dart` | ✅ |
| `SpecChip` | `lib/widget/card/spec_chip.dart` | ✅ |
| `RatingChip` | `lib/widget/badge/rating_chip.dart` | ✅ |
| `CertifiedBadge` (variants translucent/solid) | `lib/widget/badge/certified_badge.dart` | ✅ |
| `FloatingHeartButton` | `lib/widget/img/floating_heart_button.dart` | ✅ |
| `PhotoDots` | `lib/widget/img/photo_dots.dart` | ✅ |

### Phase 5B — Map widgets ✅

| Widget | Fichier | Statut |
|---|---|---|
| `MapGridPainter` | `lib/widget/map/map_grid_painter.dart` | ✅ |
| `MapPlaceholder` | `lib/widget/map/map_placeholder.dart` | ✅ |
| `MapPriceMarker` | `lib/widget/map/map_price_marker.dart` | ✅ |
| `MapPinMarker` (Detail Emplacement) | `lib/widget/map/map_pin_marker.dart` | ✅ |
| `MapTeaser` (4 pins + bouton) | `lib/widget/map/map_teaser.dart` | ✅ |

### Phase 5C — Home Locataire (Explorer) ✅

| Widget/Écran | Fichier | Statut |
|---|---|---|
| `LocataireHomeHeader` | `lib/screen/client/locataire/home/widget/locataire_home_header.dart` | ✅ |
| `LocataireSearchBar` | `lib/screen/client/locataire/home/widget/locataire_search_bar.dart` | ✅ |
| `ListingFilterChips` | `lib/screen/client/locataire/home/widget/listing_filter_chips.dart` | ✅ |
| `SampleListings` (mock) | `lib/screen/client/locataire/home/sample_listings.dart` | ✅ |
| `LocataireHomeScreen` | `lib/screen/client/locataire/home/home_screen.dart` | ✅ |

### Phase 5D — Detail logement ✅

| Widget/Écran | Fichier | Statut |
|---|---|---|
| `DetailHeroGallery` | `lib/screen/client/locataire/booking/widget/detail_hero_gallery.dart` | ✅ |
| `DetailTitleBlock` | `lib/screen/client/locataire/booking/widget/detail_title_block.dart` | ✅ |
| `QuickSpecsCard` | `lib/screen/client/locataire/booking/widget/quick_specs_card.dart` | ✅ |
| `HostCard` | `lib/screen/client/locataire/booking/widget/host_card.dart` | ✅ |
| `AmenityItem` (VO) | `lib/screen/client/locataire/booking/widget/amenity_item.dart` | ✅ |
| `AmenitiesGrid` | `lib/screen/client/locataire/booking/widget/amenities_grid.dart` | ✅ |
| `DetailMapSection` | `lib/screen/client/locataire/booking/widget/detail_map_section.dart` | ✅ |
| `ReviewCard` | `lib/screen/client/locataire/booking/widget/review_card.dart` | ✅ |
| `DetailBottomBar` | `lib/screen/client/locataire/booking/widget/detail_bottom_bar.dart` | ✅ |
| `LocataireDetailScreen` | `lib/screen/client/locataire/booking/detail_screen.dart` | ✅ |
### Phase 5E — Reserve 3 étapes ✅

| Widget/Écran | Fichier | Statut |
|---|---|---|
| `ListingSummaryCard` | `lib/screen/client/locataire/booking/widget/listing_summary_card.dart` | ✅ |
| `FieldRow` (générique) | `lib/widget/item/field_row.dart` | ✅ |
| `PriceDetailCard` | `lib/screen/client/locataire/booking/widget/price_detail_card.dart` | ✅ |
| `InfoBanner` (générique) | `lib/widget/feedback/info_banner.dart` | ✅ |
| `PaymentMethodTile` | `lib/widget/list/payment_method_tile.dart` | ✅ |
| `SuccessCircle` | `lib/widget/feedback/success_circle.dart` | ✅ |
| `BookingCodeCard` | `lib/screen/client/locataire/booking/widget/booking_code_card.dart` | ✅ |
| `BookingRecapCard` | `lib/screen/client/locataire/booking/widget/booking_recap_card.dart` | ✅ |
| `LocataireReserveScreen` (3 steps state) | `lib/screen/client/locataire/booking/reserve_screen.dart` | ✅ |
### Phase 5F — Trips + Saved + Search ✅

| Widget/Écran | Fichier | Statut |
|---|---|---|
| `TripCard` | `lib/screen/client/locataire/trips/widget/trip_card.dart` | ✅ |
| `LocataireTripsScreen` | `lib/screen/client/locataire/trips/trips_screen.dart` | ✅ |
| `SavedListingCard` | `lib/widget/card/saved_listing_card.dart` | ✅ |
| `LocataireFavoriteScreen` | `lib/screen/client/locataire/favorite/favorite_screen.dart` | ✅ |
| `BudgetSlider` | `lib/widget/input/budget_slider.dart` | ✅ |
| `LocataireSearchScreen` | `lib/screen/client/locataire/home/search_screen.dart` | ✅ |

### Phase 5G — Profile + Shell + BLoC binding ✅

| Widget/Écran | Fichier | Statut |
|---|---|---|
| `ProfileHeroCard` | `lib/screen/client/shared/profile/widget/profile_hero_card.dart` ⚠️ déplacé V6 | ✅ |
| `ProfileRoleSwitcher` | `lib/screen/client/shared/profile/widget/profile_role_switcher.dart` ⚠️ déplacé V6 | ✅ |
| `ProfileSettingsCard` | `lib/screen/client/shared/profile/widget/profile_settings_card.dart` ⚠️ déplacé V6 | ✅ |
| ~~`LocataireProfileScreen`~~ → `ClientProfileScreen` (transverse) | `lib/screen/client/shared/profile/client_profile_screen.dart` ⚠️ promu V6 | ✅ |
| `LocataireShell` (BottomNav + IndexedStack 5 onglets) | `lib/screen/client/locataire/locataire_shell.dart` | ✅ |
| `RoleHomeRouter` (route shell selon rôle) | `lib/screen/role_home_router.dart` | ✅ |
| LoginForm → push Shell sur UserLoaded | `lib/screen/login/widget/login_form.dart` | ✅ |
| OtpVerificationScreen → push Shell sur UserLoaded | `lib/screen/signup/otp_verification_screen.dart` | ✅ |
| SplashScreen → CheckStoredUser → Shell ou Onboarding | `lib/screen/splash_screen.dart` | ✅ |

**Gate vague 5 :** ✅ 7/7 phases · `flutter analyze` 0 erreur. Parcours Locataire complet : Splash → Auth → Shell 5 onglets → Detail → Reserve 3 étapes → Logout → Onboarding.

---

## 📦 Vague 6 — Démarcheur (5 onglets)

### Phase 6A — Refactor Profile transverse ✅

| Action | Fichier | Statut |
|---|---|---|
| Promouvoir `LocataireProfileScreen` → `ClientProfileScreen` transverse | `lib/screen/client/shared/profile/client_profile_screen.dart` | ✅ |
| Helper `ProfileDisplayInfo` (mapping rôle → subtitle/badge/settings) | `lib/screen/client/shared/profile/profile_display_info.dart` | ✅ |
| Déplacer `ProfileHeroCard` | `lib/screen/client/shared/profile/widget/profile_hero_card.dart` | ✅ |
| Déplacer `ProfileRoleSwitcher` | `lib/screen/client/shared/profile/widget/profile_role_switcher.dart` | ✅ |
| Déplacer `ProfileSettingsCard` | `lib/screen/client/shared/profile/widget/profile_settings_card.dart` | ✅ |
| Brancher `onSwitchRole` → `RoleHomeRouter.shellFor` + `pushAndRemoveAll` | `client_profile_screen.dart` | ✅ |
| `LocataireShell` utilise `ClientProfileScreen` | `locataire_shell.dart` | ✅ |
| Tokens Wallet bleu-nuit (`walletBlueAccent`, `walletBlueBorder`, `walletBlueHalo`, `heroGradientBlueShort`) | `lib/theme/app_colors.dart` | ✅ |
| Suppression `lib/screen/client/locataire/profile/` (legacy) | — | ✅ |

### Phase 6B — Modèles + mocks ✅

| Action | Fichier | Statut |
|---|---|---|
| `ReferralPreview` + enum `ReferralStatus` | `lib/model/ui_only/referral_preview.dart` | ✅ |
| `CommissionTransaction` + enum `TransactionType` | `lib/model/ui_only/commission_transaction.dart` | ✅ |
| `SampleReferrals` (6 entrées, 4 statuts) | `lib/screen/client/demarcheur/sample/sample_referrals.dart` | ✅ |
| `SampleCommissions` (6 transactions) | `lib/screen/client/demarcheur/sample/sample_commissions.dart` | ✅ |
| `SampleListingsToReferral` (réutilise `SampleListings.all` + commission 10%) | `lib/screen/client/demarcheur/sample/sample_listings_to_referral.dart` | ✅ |

### Phase 6C — 13 widgets feature ✅

| Widget | Fichier | Statut |
|---|---|---|
| `WalletHeroCard` (gradient 3 stops + halo bleu) | `lib/screen/client/demarcheur/home/widget/wallet_hero_card.dart` | ✅ |
| `MiniStatsInline` (3 stats avec séparateurs) | `lib/screen/client/demarcheur/home/widget/mini_stats_inline.dart` | ✅ |
| `SendReferralCtaCard` (gradient or) | `lib/screen/client/demarcheur/home/widget/send_referral_cta_card.dart` | ✅ |
| `StatusPillsRow` (3 cols) | `lib/screen/client/demarcheur/home/widget/status_pills_row.dart` | ✅ |
| `ListingPushCard` (200px) | `lib/screen/client/demarcheur/home/widget/listing_push_card.dart` | ✅ |
| `ReferralStatusDisplay` (helper mapping status→label/tone) | `lib/screen/client/demarcheur/referrals/widget/referral_status_display.dart` | ✅ |
| `ReferralRow` | `lib/screen/client/demarcheur/referrals/widget/referral_row.dart` | ✅ |
| `ReferralFilterChips` (5 chips) | `lib/screen/client/demarcheur/referrals/widget/referral_filter_chips.dart` | ✅ |
| `ReferralListingRadio` (card radio step 1) | `lib/screen/client/demarcheur/referrals/widget/referral_listing_radio.dart` | ✅ |
| `TimelineStep` (rond + connector + état) | `lib/screen/client/demarcheur/referrals/widget/timeline_step.dart` | ✅ |
| `ReferralTimeline` (5 étapes) | `lib/screen/client/demarcheur/referrals/widget/referral_timeline.dart` | ✅ |
| `CommissionCard` (sous-total → 10% → à recevoir) | `lib/screen/client/demarcheur/referrals/widget/commission_card.dart` | ✅ |
| `WalletSoldeCard` (gradient 2 stops + bouton retirer) | `lib/screen/client/demarcheur/wallet/widget/wallet_solde_card.dart` | ✅ |
| `WalletTransactionRow` | `lib/screen/client/demarcheur/wallet/widget/wallet_transaction_row.dart` | ✅ |

### Phase 6D — 5 écrans + Shell + intégration ✅

| # | Écran | Source proto | Fichier | Statut |
|---|---|---|---|---|
| 6.1 | Dashboard | `DemarcheurDashboard` | `lib/screen/client/demarcheur/home/dashboard_screen.dart` | ✅ |
| 6.2 | Referrals (liste filtrée) | `DemarcheurReferrals` | `lib/screen/client/demarcheur/referrals/referrals_screen.dart` | ✅ |
| 6.3 | **New 3 étapes** (single screen avec `_step`, écart documenté ↓) | `DemarcheurNew` | `lib/screen/client/demarcheur/referrals/new_referral_screen.dart` | ✅ |
| 6.4 | Referral Detail | `DemarcheurReferralDetail` | `lib/screen/client/demarcheur/referrals/referral_detail_screen.dart` | ✅ |
| 6.5 | Wallet | `DemarcheurWallet` | `lib/screen/client/demarcheur/wallet/wallet_screen.dart` | ✅ |
| 6.6 | Profile (transverse) | `Profile` | `lib/screen/client/shared/profile/client_profile_screen.dart` | ✅ |
| 6.7 | Shell + 5 tabs | `app.jsx` | `lib/screen/client/demarcheur/demarcheur_shell.dart` | ✅ |
| 6.8 | `RoleHomeRouter` case demarcheur | `app.jsx::setRole` | `lib/screen/role_home_router.dart` | ✅ |

**Gate vague 6 :** ✅ 36/36 items cochés (9 refactor + 5 modèles/mocks + 14 widgets + 8 écrans/intégrations) · `flutter analyze` 0 nouvelle erreur, 41 issues legacy inchangées · audit 98/100 · doc HTML générée.

### Écart vs plan initial (acté 2026-05-10)
- **Tunnel `NewReferralScreen`** : 1 seul écran avec `int _step` (au lieu de 3 fichiers `new_step{1,2,3}_screen.dart` initialement prévus). Justification : cohérence avec `LocataireReserveScreen` Vague 5, DRY (header partagé), navigation forward/back triviale via `setState`. État du formulaire préservé sans param drilling.

---

## 📦 Vague 7 — Propriétaire (5 onglets + édition) ✅

### Phase 7A — Modèles + mocks + token ✅

| Action | Fichier | Statut |
|---|---|---|
| Token `cashflowCharges` (#A06B30) brun cashflow Dashboard | `lib/theme/app_colors.dart` | ✅ |
| 7 modèles UI-only (`ProprioKpi`, `MonthlyRevenue`, `CashflowSegment`, `PnLEntry` + enum, `PropertyPerf`, `ProjectionPoint`, `PendingRequest` + enum) | `lib/model/ui_only/` | ✅ |
| `SampleProprioStats` (KPIs + 6 mois + cashflow + revenu courant) | `lib/screen/client/proprio/sample/sample_proprio_stats.dart` | ✅ |
| `SamplePnLEntries` (Revenus + Charges + Bénéfice + Marge) | `lib/screen/client/proprio/sample/sample_pnl_entries.dart` | ✅ |
| `SamplePropertyPerf` (4 entries depuis `SampleListings`) | `lib/screen/client/proprio/sample/sample_property_perf.dart` | ✅ |
| `SampleProjectionPoints` (7 mois Sept→Mars) | `lib/screen/client/proprio/sample/sample_projection_points.dart` | ✅ |
| `SamplePendingRequests` (≥2 entries) | `lib/screen/client/proprio/sample/sample_pending_requests.dart` | ✅ |

### Phase 7B — Atome + 6 widgets feature Dashboard ✅

| Widget | Fichier | Statut |
|---|---|---|
| `Sparkbar` (atome — 6 barres ratios + highlight accent + étiquette) | `lib/screen/client/proprio/home/widget/sparkbar.dart` | ✅ |
| `RevenueHeroCard` (gradient or 3 stops + halo + sparkbar) | `lib/screen/client/proprio/home/widget/revenue_hero_card.dart` | ✅ |
| `KpiTile` (label + valeur mono + delta % success/danger) | `lib/screen/client/proprio/home/widget/kpi_tile.dart` | ✅ |
| `CashflowSplitCard` (barre stack 4 segments + légende) | `lib/screen/client/proprio/home/widget/cashflow_split_card.dart` | ✅ |
| `ProprioListingRow` (ImgPh 64×64 + titre + occup + revenus) | `lib/screen/client/proprio/home/widget/proprio_listing_row.dart` | ✅ |
| `PendingRequestRow` (avatar + nom + badge NOUVEAU + sub) | `lib/screen/client/proprio/home/widget/pending_request_row.dart` | ✅ |

### Phase 7C — 11 widgets feature Listings + ListingEdit ✅

| Widget | Fichier | Statut |
|---|---|---|
| `ListingsFilterChips` (4 chips status) | `lib/screen/client/proprio/appartements/widget/listings_filter_chips.dart` | ✅ |
| `ListingFullCard` (ImgPh 16:9 + 2 badges + moreH + body + footer 3 ghost) | `lib/screen/client/proprio/appartements/widget/listing_full_card.dart` | ✅ |
| `NewListingCard` (dashed CTA + cercle accentSoft + plus) | `lib/screen/client/proprio/appartements/widget/new_listing_card.dart` | ✅ |
| `DashedBorderContainer` (atome dashed border réutilisable) | `lib/widget/container/dashed_border_container.dart` | ✅ |
| `ListingEditHero` (ImgPh 16:10 + badge photos blur) | `lib/screen/client/proprio/appartements/widget/listing_edit_hero.dart` | ✅ |
| `ListingEditStatsCard` (Row 2 cols Occupation + Note moy) | `lib/screen/client/proprio/appartements/widget/listing_edit_stats_card.dart` | ✅ |
| `ListingInfosTab` (6 FieldRow Titre/Type/Adresse/Surface/Capacité/Description) | `lib/screen/client/proprio/appartements/widget/listing_infos_tab.dart` | ✅ |
| `ListingCalendarTab` (assemble MiniCalendarGrid + CalendarLegend) | `lib/screen/client/proprio/appartements/widget/listing_calendar_tab.dart` | ✅ |
| `MiniCalendarGrid` (7×N view-only avec couleurs proto) | `lib/screen/client/proprio/appartements/widget/mini_calendar_grid.dart` | ✅ |
| `CalendarLegend` (3 entrées Réservé/En attente/Aujourd'hui) | `lib/screen/client/proprio/appartements/widget/calendar_legend.dart` | ✅ |
| `ListingPricingTab` (tarif base hero + 5 FieldRow calculés depuis price) | `lib/screen/client/proprio/appartements/widget/listing_pricing_tab.dart` | ✅ |
| `ListingRulesTab` (6 FieldRow constantes) | `lib/screen/client/proprio/appartements/widget/listing_rules_tab.dart` | ✅ |

### Phase 7D — 5 widgets Finances + 4 écrans + Shell ✅

| Action | Fichier | Statut |
|---|---|---|
| `PeriodSwitcher` (segmented 4 options) | `lib/screen/client/proprio/comptabilite/widget/period_switcher.dart` | ✅ |
| `BeneficeNetHeroCard` (card simple + montant 30px + delta) | `lib/screen/client/proprio/comptabilite/widget/benefice_net_hero_card.dart` | ✅ |
| `PnLCard` (compte de résultat structuré) | `lib/screen/client/proprio/comptabilite/widget/pnl_card.dart` | ✅ |
| `PropertyPerfRow` (ImgPh 44 + titre + barre progress + revenus + delta) | `lib/screen/client/proprio/comptabilite/widget/property_perf_row.dart` | ✅ |
| `ProjectionChart` (fl_chart 2 séries solid+dashed + area + verticalLine) | `lib/screen/client/proprio/comptabilite/widget/projection_chart.dart` | ✅ |

| # | Écran | Source proto | Fichier | Statut |
|---|---|---|---|---|
| 7.1 | Dashboard | `ProprietaireDashboard` | `lib/screen/client/proprio/home/dashboard_screen.dart` | ✅ |
| 7.2 | Listings | `ProprietaireListings` | `lib/screen/client/proprio/appartements/listings_screen.dart` | ✅ |
| 7.3 | Listing Edit (4 tabs) | `ProprietaireListingEdit` | `lib/screen/client/proprio/appartements/listing_edit_screen.dart` | ✅ |
| 7.4 | Finances P&L | `ProprietaireFinances` | `lib/screen/client/proprio/comptabilite/finances_screen.dart` | ✅ |
| 7.5 | Profile (transverse) | `Profile` | `lib/screen/client/shared/profile/client_profile_screen.dart` (V6 réutilisé) | ✅ |
| 7.6 | Shell + 5 tabs | `app.jsx` | `lib/screen/client/proprio/proprio_shell.dart` | ✅ |
| 7.7 | `RoleHomeRouter` case proprietaire | `app.jsx::setRole` | `lib/screen/role_home_router.dart` | ✅ |

**Gate vague 7 :** ✅ 36/36 items cochés (7 mocks/modèles + 1 token + 6 widgets Dashboard + 1 atome dashed + 11 widgets Listings/Edit + 5 widgets Finances + 4 écrans + 1 Shell + 1 RoleHomeRouter complet) · `flutter analyze` 41 issues legacy inchangées (0 nouvelle) · audit pending.

### Écart vs plan initial (acté 2026-05-10)
- **`FieldRow` regroupé dans Container card unique** par tab (pattern V5 `LocataireReserveScreen`) au lieu de cards individuelles comme dans le proto. Justification : cohérence projet, lisibilité similaire, évite la duplication border.
- **`DashedBorderContainer` extrait en atome transverse** (`lib/widget/container/`) pour respecter règle 4 (1 classe par fichier) et permettre la réutilisation future.

---

## 📦 Vague 8 — Messaging ✅ (Notifications + Receipt PDF reportés à V9)

### Phase 8A — Modèles + helper + mocks ✅

| Action | Fichier | Statut |
|---|---|---|
| `ConversationPreview` + enum `ConversationRole` | `lib/model/ui_only/conversation_preview.dart` | ✅ |
| `ChatMessage` + enums `MessageSender` + `MessageKind` | `lib/model/ui_only/chat_message.dart` | ✅ |
| `ReservationCardPayload` (utilise ListingPreview V5) | `lib/model/ui_only/reservation_card_payload.dart` | ✅ |
| `AcceptedReferralCardPayload` | `lib/model/ui_only/accepted_referral_card_payload.dart` | ✅ |
| `ConversationRoleDisplay` (helper labelOf+toneOf) | `lib/screen/client/shared/inbox/widget/conversation_role_display.dart` | ✅ |
| `SampleConversations.byRole` (3 listes locataire/proprio/démarcheur fidèles proto extras.jsx:80-97) | `lib/screen/client/shared/inbox/sample/sample_conversations.dart` | ✅ |
| `SampleThreads` (3 threads riches L1/P1/D1 fidèles proto + autres conversations vides) | `lib/screen/client/shared/inbox/sample/sample_threads.dart` | ✅ |

### Phase 8B — 6 widgets feature ✅

| Widget | Fichier | Statut |
|---|---|---|
| `MessagingSearchBar` (InputField + icon search + onChanged) | `lib/screen/client/shared/inbox/widget/messaging_search_bar.dart` | ✅ |
| `ConversationRow` (UserAvatar 46 + 3 rows nom+shield+time / badge rôle+sub / last message + unread cercle accent) | `lib/screen/client/shared/inbox/widget/conversation_row.dart` | ✅ |
| `MessageBubble` (maxWidth 78%, accent/bgElev2, radius 18 avec queue 6, heure 10px) | `lib/screen/client/shared/inbox/widget/message_bubble.dart` | ✅ |
| `ReservationMessageCard` (ImgPh 56 + RÉSERVATION + dates + bookingCode mono) | `lib/screen/client/shared/inbox/widget/reservation_message_card.dart` | ✅ |
| `AcceptedReferralMessageCard` (accentSoft + check + label + commission mono) | `lib/screen/client/shared/inbox/widget/accepted_referral_message_card.dart` | ✅ |
| `ChatInputBar` (BlurContainer + plus + InputField + bouton rond send désactivé si vide) | `lib/screen/client/shared/inbox/widget/chat_input_bar.dart` | ✅ |

### Phase 8C — 2 écrans + branchement 3 Shells ✅

| # | Écran | Source proto | Fichier | Statut |
|---|---|---|---|---|
| 8.1 | MessagingList (adaptatif rôle via UserBloc + filtre local) | `extras.jsx::MessagingList` | `lib/screen/client/shared/inbox/messaging_list_screen.dart` | ✅ |
| 8.2 | MessagingThread (header custom + bubbles + cards + setState envoi + scroll auto) | `extras.jsx::MessagingThread` | `lib/screen/client/shared/inbox/messaging_thread_screen.dart` | ✅ |
| 8.3 | LocataireShell branché (suppression `_MessagesPlaceholder`) | — | `lib/screen/client/locataire/locataire_shell.dart` | ✅ |
| 8.4 | DemarcheurShell branché | — | `lib/screen/client/demarcheur/demarcheur_shell.dart` | ✅ |
| 8.5 | ProprioShell branché | — | `lib/screen/client/proprio/proprio_shell.dart` | ✅ |
| 8.6 | Notifications | F6 (V9) | — | ⬜ reporté V9 |
| 8.7 | Receipt PDF preview | F8 (V9) | — | ⬜ reporté V9 |

**Gate vague 8 :** ✅ 21/21 items cochés (4 modèles + 1 helper + 2 mocks + 6 widgets + 2 écrans + 3 Shells modifiés + 3 `_MessagesPlaceholder` supprimés) · `flutter analyze` 41 issues legacy inchangées (0 nouvelle) · audit pending.

🎉 **Avec V8 livrée, les 18 écrans du proto + transverses sont 100% reconstruits.**

### Écart vs plan initial (acté 2026-05-10)
- **Notifications + Receipt PDF reportés à V9** (hors-proto) — décision BA pour scope maîtrisé
- **Threads dynamiques** : 3 threads riches (L1/P1/D1 fidèles proto) + threads vides pour les autres conversations avec placeholder « Démarrez la conversation… ». Header dynamique adapté à la conversation cliquée. Justification utilisateur : « c'est le même compte sous différentes interfaces, ça doit être dynamique »
- **`BlurContainer`** wrappe l'input bar (Liquid Glass cohérent V1-V7) au lieu du flat alpha proto — enrichissement visuel mineur
- **`BadgeStatus` fontSize** : 11 (atome V1) vs 9 (proto) — écart visuel de 2px, non bloquant

---

## 📦 Vague 9 — Hors-proto (F2-F10)

| # | Famille | Réf UI/UX | Statut |
|---|---|---|---|
| 9.1 | F2 — Wizard appart (5-7 étapes) | option A tunnel proto | ⬜ |
| 9.2 | F3 — Scanner QR | option A overlay accent | ⬜ |
| 9.3 | F4 — Comptabilité étendue | option A extension P&L | ⬜ |
| 9.4 | F5 — Démarcheurs côté proprio | option A symétrique | ⬜ |
| 9.5 | F7 — Carte réelle géocodée | option A tiles dark | ✅ (3 sous-versions a/b/c — voir journal 2026-05-11) |
| 9.6 | F9 — Banque / Cartes / Compte | option A wallet récepteur | ⬜ |
| 9.7 | F10 — Calendrier global réservations | option A matrix | ⬜ |

---

## 🔧 Réintégrations TODO REBUILD

> Fichiers commentés à réactiver après reconstruction des widgets correspondants.

| Fichier | Ligne(s) commentée(s) | Réactivation après |
|---|---|---|
| `lib/main.dart` | `WebSocketInitializer` import + wrap | reconstruction `lib/widget/websocket/websocket_initializer.dart` |
| `lib/service/notification/notification_helper.dart` | `ConfirmDialog.show` × 3 | reconstruction `lib/widget/dialog/confirm_dialog.dart` |
| `lib/util/dialog/close_header.dart` | `IconBoutton` import (remplacé par `IconButton` Material) | étape 1.7 (`IconBoutton` reconstruit) |
| `lib/util/payement_add_page.dart` | UI complète stubbée | F9 (Banque/Cartes) |
| `wallet_screen.dart` (V6) | bouton « Retirer maintenant » → SnackBar stub | F9 (Banque/Cartes/Compte) — bottom sheet ou écran retrait selon spec dédiée |
| **Empty states** absents Vague 6 | Mocks toujours remplis donc cas non atteignable visuellement | Quand BLoCs réels branchés (vague de finition post-V9) — créer widget `EmptyState` générique + brancher dans 6 zones (DemarcheurReferralsScreen liste vide, WalletScreen historique vide, Dashboard sections « Clients référés » / « Logements à pousser », LocataireTripsScreen, LocataireFavoriteScreen) |
| **Persistance switch de rôle** | `user.type` muté en mémoire seulement (cf. `client_profile_screen.dart::_onSwitchRole`) | Vague de finition : ajouter event `UserBloc::SetActiveRole` qui persiste le choix en Hive + dispatch UserLoaded sans déclencher la chaîne de préchargement |
| **`DynamicAppBar` slot `sub`** | Le proto utilise `sub` (sous le titre) mais V6/V7 utilisent `eyebrow` (au-dessus) pour cohérence projet | Vague de finition transverse : ajouter un paramètre `sub` à `DynamicAppBar` (alternative à `eyebrow`) et migrer les écrans qui le veulent |
| **Édition calendrier propriétaire** (V7) | `MiniCalendarGrid` view-only, taps = SnackBar | Quand `CalendarPlageBloc` rebranché : permettre tap pour bloquer/débloquer un jour, navigation entre mois |
| **Branchement `ConversationBloc` réel** (V8) | Mocks `SampleConversations` + `SampleThreads` actuellement | Vague de finition post-V9 : brancher `ConversationBloc` existant + `MessageBloc` + WebSocket pour messages temps réel |
| **Cards spéciales tap navigation** (V8) | ✅ **livré V9.2** (2026-05-11) — chaîne backend↔Flutter activée | V9.2 : brief backend confirme Option C minimaliste (`[ASFAR_CARD:reservation]{"ref":"ASF-XXX"}` + `[ASFAR_CARD:partenariat]{"id":12}`) + nouveau endpoint `/api/demande-partenariat/{id}`. Cards refondues en `StatefulWidget` avec lazy fetch (skeleton 3 zones + fallback chip muted). Renommage cascade `referral → partenariat`. Card Résa tap → `LocataireDetailScreen` (focus appart) ; Card Partenariat tap → nouveau `PartenariatDetailScreen` transverse (proprio + démarcheur). Doc complète : `.ai-outputs/docs/v9-2-cards-systeme-map-align.html`. |
| **Bouton phone header thread** (V8) | ✅ livré 2026-05-11 | `MessagingThreadScreen._onCall` branché sur `launchUrl(Uri(scheme: 'tel', path: phone))`. `ConversationPreview.phone` rempli depuis `User.telephone` du proprio/locataire via mapper. Fallback SnackBar si null. |
| **Bouton plus input bar** (V8) | SnackBar stub | Pièce jointe (image/file picker) — V9 |

---

## 📊 Légende

| Symbole | Signification |
|---|---|
| ⬜ | À faire |
| 🟡 | En cours |
| ✅ | Terminé + `flutter analyze` 0 erreur |
| ⚠️ | Bloqué (voir notes) |
| ❌ | Abandonné / hors-scope |

---

## 📝 Journal des décisions

### 2026-05-09
- Cleanup total terminé : 0 widget restant, 0 erreur compile
- Theme Asfar Dark Premium en place (`AppColors`, `AppRadii`, `AppTextStyles`, `AppTheme.dark`)
- Plan de reconstruction validé en 9 vagues
- Démarrage Vague 1 — Atomes
- Vagues 1-4 livrées (21 widgets + 5 écrans)

### 2026-05-11 (V9.2 — Intégration brief backend cards système chat + map align) ✅

Pipeline `/feature full` complet (BA → Architecture → UI/UX → Dev → Audit 93.5/100 → Doc).

**Brief backend reçu 2026-05-11** : confirmation Option C minimaliste pour les cards riches + ajout `isSystem: bool` au modèle `MessageResponse` + nouveau endpoint `GET /api/demande-partenariat/{id}` + renommage `referral → partenariat` côté backend + support conv mixte Proprio↔Démarcheur + cleanup `geoLat/geoLongi` (calculés auto par geocoding serveur).

**4 lots livrés Flutter** :

- **L1 — Cards système chat (Option C activée)** : ajout `@HiveField(9) bool? isSystem` au modèle `ChatMessage` (typeId 1 inchangé, boxes Hive compat). Refonte `ChatMessageToUiMapper` : parse JSON via `jsonDecode` après préfixe + détection via `isSystem` ET préfixe + fallback `MessageKind.text` si parse échoue (try/catch). Préfixes finaux `[ASFAR_CARD:reservation]{"ref":"ASF-XXX"}` (string code) et `[ASFAR_CARD:partenariat]{"id":12}` (int). Renommage cascade `_referralPrefix → _partenariatPrefix`, `AcceptedReferralCardPayload → AcceptedPartenariatCardPayload` (`String referralCode → int demandeId`), `MessageKind.acceptedReferralCard → acceptedPartenariatCard`. Cards refondues `StatefulWidget` avec lazy fetch (skeleton 3 zones bgElev2 statiques + fallback chip `Indisponible` text3 muted). Atomes partagés `system_card_atoms.dart` (DRY entre 2 cards). Nouveau service neutre `PartenariatService` singleton (`getDemandeById(int)` route `api/demande-partenariat/{id}`) — séparation responsabilités avec `PartenariatProprioService` V9.6 inchangé. `ReservationService` étendu (`getByReference(String)` route `api/user/reservations/{ref}`). Callback signature changée vers objet `loaded` (`void Function(Reservation? loaded)?` et `DemandePartenariat?`). Nouveau écran transverse `PartenariatDetailScreen` (dans `lib/screen/client/shared/partenariats/`) — `DynamicAppBar` + section statut (chip large success/warn/danger) + 2 `PartenariatDetailPartyCard` (avatar gradient or 48×48 initiales + nom + tél mono + bouton phone `tel:` via `url_launcher`). `MessagingThreadScreen._onPartenariatTap` push vers nouveau détail si `loaded != null` sinon SnackBar.

- **L2 — Cleanup AddressReq** : `AppartementBackendMapper._buildLegacyResidenceShape` strippe désormais `geoLat` et `geoLongi` du payload `address` avant envoi (backend les calcule auto). Le `GpsCapture` côté Flutter reste utilisé pour pré-remplir `pays/ville/commune` via reverse geocoding offline, mais ses coords ne partent plus.

- **L3 — Conv mixte proprio↔démarcheur** : `ConversationToPreviewMapper._roleFor` élargi pour gérer `ConversationRole.demarcheur` (proprio voit démarcheur). Plus de check rigide locataire.

- **L4 — Docs** : mise à jour `BACKEND_NOTES_RICH_CARDS_V8.md` (passage en statut « ACTIVÉ V9.2 » + §10 récap activation), mise à jour `BACKEND_NOTES_MAP_V9_7B.md` (§7 devise FCFA + §8 `geoLat` strippé côté Flutter), TODO REBUILD V8 « Cards spéciales tap navigation » passe en ✅ effectif livré V9.2.

**Décisions techniques notables** :
- **Hive `isSystem` nullable sans bump typeId** : champ nullable → Hive tolère les boxes pré-V9.2 (field absent = null = traité comme false). `chat_message.g.dart` synced manuellement (numFields 9→10, readByte/writeByte 9 ajoutés pour `isSystem`).
- **Atomes partagés** : 3 widgets (`SystemCardLeadingIcon`, `SystemCardSkeletonRows`, `SystemCardUnavailableChip`) extraits dans `system_card_atoms.dart` → zéro duplication entre les 2 cards système.
- **Service neutre `PartenariatService`** : créé séparément de `PartenariatProprioService` (V9.6 — actions proprio : accepter/refuser/listDemandes) pour le lookup neutre par ID applicable aux 2 rôles → séparation responsabilités propre.
- **Calcul nom partie opposée** : `AcceptedPartenariatMessageCard` lit `UserBloc.state.user.type` pour afficher le nom de l'**interlocuteur** (proprio si user démarcheur, démarcheur si user proprio).
- **Parsing résilient** : `try/catch` sur `jsonDecode`, retour `null` si parse échoue → mapper fallback gracieux vers `MessageKind.text` (jamais de crash sur message mal formé).

**Périmètre fichiers** : 7 créés + 9 modifiés + 2 supprimés (`accepted_referral_card_payload.dart` + `accepted_referral_message_card.dart`). `flutter analyze` : 39 issues legacy inchangées, 0 nouvelle erreur. `grep -rn "Widget _" lib/screen/client/shared/partenariats/ lib/screen/client/shared/inbox/` → vide (règle Flutter n°1 respectée).

**Audit 93.5/100** (toutes dimensions ≥ 92).

**Doc complète HTML** : `.ai-outputs/docs/v9-2-cards-systeme-map-align.html`.

**Hors scope tracker V10** : WebSocket temps réel (actuellement polling), `ReservationDetailScreen` dédié si feedback demande (V9.2 push `LocataireDetailScreen` focus appart), cache local Hive cards (TTL court terme).

---

### 2026-05-11 (Vague 9.5 — Carte réelle géocodée — F7) ✅

3 sous-versions livrées dans la journée via pipelines `/feature full` successifs :

- **V9.5a (audit 98.3/100)** — première carte interactive temps réel d'Asfar. `LocataireMapScreen` avec `flutter_map ^8.1.1`, tuiles OSM filtrées dark via `tileBuilder` + `ColorFiltered` matrice (zéro dépendance externe), markers prix accent or, géoloc OS réelle via `LocationUtil`, `BottomSheet` preview au tap marker, `FAB` Ma position, bouton "Rechercher dans cette zone" après pan/zoom, filtres délégués à `LocataireSearchScreen` existant. 11 fichiers créés + 1 modifié, ~783 lignes Dart.

- **V9.5b (audit 92.5/100)** — refonte modèle suite à pivot métier (suppression notion "résidence" agrégée) : `MapResidence` → `MapAppartement` (1 marker = 1 appart). Dual coordonnées `displayLat/displayLongi` (obfusqué backend ±200m) + `realLat/realLongi` (privé via `/real-location` guard `PAYER`/`FINALISER`). `BottomSheet` refondu `StatefulWidget` avec photo lazy + shimmer or animé 1200ms (option A « Pristine luxe »). Clustering supprimé du périmètre (jamais branché à l'UI). Mapper fallback partiel créé pour échec lazy load. 3 créés + 5 refondus + 4 adaptés + 2 supprimés.

- **V9.5c (audit 93.7/100)** — finalisation chaîne dual-coords : section "Localisation" sur `LocataireDetailScreen` avec mini-carte 180px non-interactive. Double fetch parallèle `AppartementService.getAppartementById` + `MapService.getRealCoordinates` via `Future.wait`. Mode **EXACT** post-résa → chip success + bouton **Itinéraire** `OutlinedCustomButton` qui ouvre Apple Maps (iOS) ou Google Maps (Android) via `url_launcher ^6.3.0` (**ajouté au pubspec**). Mode **APPROXIMATIF** sinon → chip muted, pas de bouton. Factorisation `osmDarkMatrix` dans `lib/util/` (partagée `MapView` + `MiniMapPreview`). Aucun dispatch `MapBloc` (préserve état carte arrière-plan). 5 créés + 1 refondu + 3 adaptés.

**Décisions techniques notables :**
- Backend obfuscation : décalage calculé **une fois à la création** de l'appart (stable entre appels), pas de seed déterministe nécessaire côté client. Voir `BACKEND_NOTES_MAP_V9_7B.md` pour les contraintes Asfar (statuts PAYER/FINALISER, préfixe `api/` vs `auth/`, support `geoLat/geoLongi` dans `AddressReq` à la création).
- Bug iOS 26.2 + Flutter 3.35.2 fixé : `Container.alignment: Alignment.center` du `CustomButton` causait l'expansion infinie du bouton accent en plein écran sur `Scaffold.bottomNavigationBar` (parent loose). Fix : retirer l'alignment (centrage déjà géré par `Row.mainAxisAlignment.center`).
- Bug aliasing backend fixed : champs JSON `lat`/`lng`/`titre`/`prix`/`typeLocation` mappés en aliases côté `MapAppartement.fromJson` (avec fallback sur les noms du contrat `displayLat/displayLongi/title/price/typeAppart` pour résilience future).

**Cleanup specs** : business-spec et architecture V9.5b corrigées pour ne plus mentionner `CONFIRMER` parmi les statuts qui débloquent `/real-location` (seuls `PAYER` et `FINALISER`).

---

### 2026-05-10 (Vague 8 — Messaging)
- **Vague 8 livrée** — 21 items cochés, 3 phases (8A → 8C), `flutter analyze` 41 issues legacy inchangées
- **Onglet Messages débloqué sur les 3 Shells** : suppression des 3 classes `_MessagesPlaceholder` privées (Locataire/Démarcheur/Proprio) → utilisation directe de `MessagingListScreen`
- **MessagingList adaptatif au rôle** : lit `UserBloc.state.user?.type` via `BlocBuilder` et appelle `SampleConversations.forRole()` avec fallback locataire (cohérence proto extras.jsx:98)
- **MessagingThread header custom** (pas DynamicAppBar) : Container borderBottom + Row inline back+avatar+nom+shield+sub+phone — fidélité proto extras.jsx:194-214
- **3 threads riches** (L1 Aminata K. + P1 Rachid B. + D1 Aminata K.) avec cards spéciales fidèles proto (Réservation ASF-7K2N9 + Demande acceptée REF-D8H3K commission 13500) + threads vides pour les autres conversations avec placeholder « Démarrez la conversation… »
- **Bubble queue radius** : 18 sur 3 coins + 6 sur le coin opposé à la queue (bottomRight 6 si me, bottomLeft 6 sinon) — fidélité proto
- **ChatInputBar** : BlurContainer + bouton plus + InputField + bouton rond accent or désactivé visuellement (opacity 0.4) si champ vide. Send → setState ajoute message + scrollToBottom via `WidgetsBinding.addPostFrameCallback`
- **Mocks UI-only séparés** : `lib/model/ui_only/` (4 nouveaux modèles + 3 enums) + `lib/screen/client/shared/inbox/sample/` (2 mocks)
- **Décision threads dynamiques** : « c'est le même compte sous différentes interfaces, ça doit être dynamique » → header adapté à la conversation cliquée + 3 threads riches + autres vides. Branchement BLoC réel (`ConversationBloc` existant) en finition post-V9.

### 2026-05-10 (suite)
- **Vague 7 livrée** — 36 items cochés, 4 phases (7A → 7D), `flutter analyze` 41 issues legacy inchangées
- **Switch tri-directionnel finalisé** : `RoleHomeRouter` case `proprietaire` retourne `ProprioShell`. Suppression du `_RolePlaceholderShell` (plus utile maintenant que les 3 rôles ont leur Shell). Locataire ↔ Démarcheur ↔ Propriétaire bidirectionnel.
- **Profile transverse réutilisé sans modification** : `ClientProfileScreen` V6 + `ProfileDisplayInfo.forRole('proprietaire')` (déjà mappé) — 0 duplication, 0 nouveau widget
- **TabBar Material `DefaultTabController`** retenu au lieu de pattern `_tab` setState V6 — plus idiomatique pour onglets vrais (swipe gratuit + animations)
- **`fl_chart 0.69` line chart Projection** : 2 séries (passé solid + futur dashed avec pivot point Nov pour continuité) + area gradient or + verticalLine séparateur
- **Sparkbar atome custom** (Row de Container ratios) — pas besoin de fl_chart pour le bar chart simple
- **Token couleur `cashflowCharges`** (#A06B30) ajouté à AppColors — couleur brun chaud pour segment « Charges » du cashflow split
- **`DashedBorderContainer`** extrait en atome transverse (CustomPainter) — réutilisable
- **Écart `FieldRow`** : regroupé dans Container card unique par tab (cohérence V5) au lieu de cards individuelles comme dans le proto

### 2026-05-10
- **Vague 6 livrée** — 8 livrables, 4 phases (6A → 6D), `flutter analyze` 0 erreur
- **Profile transverse** : `LocataireProfileScreen` promu en `ClientProfileScreen` partagé par les 3 rôles. Subtitle/badge/settings adaptés via helper `ProfileDisplayInfo` (mapping `extras.jsx::Profile.profiles[role]`)
- **Switch de rôle fonctionnel** : `ProfileRoleSwitcher.onSwitchRole` branché → `RoleHomeRouter.shellFor` + `pushAndRemoveAll`. Mute `user.type` en mémoire (persistance Hive à faire en finition, cf. TODO REBUILD)
- **Tunnel `NewReferralScreen`** : 1 fichier avec `int _step` au lieu de 3 fichiers prévus initialement — écart documenté pour cohérence Vague 5 (`LocataireReserveScreen` même pattern)
- **Empty states + UX retrait Wallet** : reportés (cf. `ui-proposal.md`) — proto n'en a pas, mocks remplis. Tracés dans la section TODO REBUILD pour la vague de finition F9
- **Tokens Wallet bleu-nuit** : `walletBlueAccent` (#8B9AFF), `walletBlueBorder` (rgba 94,108,255,0.25), `walletBlueHalo`, `heroGradientBlueShort` ajoutés à `AppColors`. `heroGradientBlue` 3 stops déjà présent depuis Vague 1.

### 🔍 Audit visuel proto (2026-05-09)
Capture du proto via Chrome DevTools + extraction des CSS computed styles :

| Validation | Résultat |
|---|---|
| **16 tokens couleurs** (`--bg`, `--accent`, `--text*`, `--bg-elev*`, semantic) | ✅ identiques au pixel |
| **7 styles typo** (display/h1/h2/h3/body/small/eyebrow) | ✅ identiques (font-size, weight, letter-spacing, line-height) |
| **Card** (radius 20, bgElev1, border line) | ✅ |
| **Input** (radius 12, bgElev2, focus accent) | ✅ |
| **ListRow** (pad 14×16, gap 12, divider bottom) | ✅ |
| **Tabbar** (blur 20+saturate, border-top, bg rgba 0.85) | ✅ |

**Écarts trouvés et fixés** :
1. ✅ `BadgeStatus` : radius pill→6, fontSize 10→11, letterSpacing 0.4→0.2
2. ✅ `UserAvatar` : couleur initiales `onAccent`→blanc, weight 700→600
3. ✅ `AsfarChip` : padding 14×8→12×7, weight inactif 500→400
4. ✅ `ButtonSize` : refonte complète avec paddingY/X/radius par taille (sm: 9×14 r10 fs13 / md: 14×18 r14 fs16 / lg: 16×20 r16 fs17)
5. ✅ `DynamicAppBar` : padding intérieur 14→18 + ajout pad bottom 12, hauteur ajustée

Captures dans `.ai-outputs/proto-screenshots/`.
