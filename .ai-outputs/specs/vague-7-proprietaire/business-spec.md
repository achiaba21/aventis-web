# 📋 Spécification Métier — Vague 7 Propriétaire

> **Auteur :** Business Analyst (workflow `/feature full`)
> **Date :** 2026-05-10
> **Statut :** ✅ Validé par l'utilisateur
> **Parent :** `.ai-outputs/specs/refonte-design-asfar/business-spec.md` (cadre global)

---

## 1. Contexte

La reconstruction UI Asfar Premium a livré les Vagues 1 à 6. Vague 6 a aussi débloqué le **switch de rôle fonctionnel** via `ClientProfileScreen` transverse + `RoleHomeRouter`. La Vague 7 attaque le **rôle Propriétaire** — dernier rôle à reconstruire — en réutilisant maximum les acquis Vagues 5-6.

## 2. Objectif

Reconstruire les **5 onglets du Shell Propriétaire** fidèlement au prototype HTML (proto `proprietaire.jsx` + `01-prototype-screens-analysis.md` lignes 119-161), brancher le `RoleHomeRouter` pour `case 'proprietaire'`, et finaliser le switch de rôle tri-directionnel (Locataire ↔ Démarcheur ↔ Propriétaire).

## 3. Acteurs

- **Propriétaire** — bailleur listant ses appartements et suivant ses revenus
- **Propriétaire multi-rôle** — propriétaire qui peut aussi être locataire ou démarcheur (bascule via Role Switcher V6)
- **Équipe technique** — exécute la vague

## 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | **Hero card revenus** | Affiche le revenu mensuel en gradient or (`heroGradientGold` déjà dans `AppColors`), badge delta vs mois précédent, sparkbar 6 mois |
| RM2 | **KPI Dashboard** | 4 KPIs (Occupation, ADR moyen, Réservations, Note moyenne) avec delta % vs mois précédent |
| RM3 | **P&L détaillé** | Compte de résultat structuré : Revenus en `success`, Charges en `danger`, Bénéfice net en `accent` or, Marge nette en `success` |
| RM4 | **Period switcher Finances** | Segmented control 4 options : Semaine / Mois / Trimestre / Année |
| RM5 | **Listings filtre status** | 4 chips : Tout / Actifs / En pause / Brouillon |
| RM6 | **ListingEdit 4 onglets** | TabBar Material standard avec indicator underline accent or — Infos / Calendrier / Tarifs / Règles |
| RM7 | **Calendrier view-only** | Grid 7×N avec couleurs (réservé / attente / aujourd'hui) + légende. Tap sur jour = SnackBar stub (édition future quand `CalendarPlageBloc` branché) |
| RM8 | **Profile transverse** | Réutilise `ClientProfileScreen` V6 — subtitle « Propriétaire · 4 biens » + badge « ★ Hôte certifié » via `ProfileDisplayInfo.forRole('proprietaire')` (déjà mappé) |
| RM9 | **Switch rôle complet** | `RoleHomeRouter.shellFor('proprietaire')` retourne `ProprioShell` (au lieu du placeholder V6) |
| RM10 | **Mocks** | Cohérence V5-V6 : pas de branchement BLoC réel. Mocks `SampleListings` réutilisé + nouveaux mocks Dashboard/Finances/Listings |
| RM11 | **CTAs hors-V7 stubés** | "Nouvelle annonce" → SnackBar « F2 wizard », "Exporter PDF/CSV" → SnackBar « F8 ». "Demandes en attente" tap = SnackBar (proprio side, F5 hors-proto) |
| RM12 | **Onglet Messages stubé** | 4ᵉ onglet du Shell = `_MessagesPlaceholder` (pattern V5-V6, reconstruction réelle V8) |
| RM13 | **Tokens uniquement** | `AppColors.*`, `AppRadii.*`, `AppTextStyles.*` — pas de couleur/size en dur. `heroGradientGold` déjà disponible. Couleurs P&L (success/danger) déjà dispo. |
| RM14 | **Charts** | Sparkbar 6 mois Dashboard = custom Container ratios. Line chart Projection 3 mois Finances = `fl_chart` (déjà installé 0.69.0) avec passé solid + futur dashed + area gradient |

## 5. Cas d'Usage Principal

**Préconditions :** utilisateur connecté avec `user.type == 'proprietaire'`.

**Scénario nominal :**
1. Splash → Auth → `RoleHomeRouter` redirige vers `ProprioShell` (5 onglets)
2. **Onglet Accueil** → `ProprioDashboard` : greeting + hero revenus + sparkbar 6 mois + KPI 2×2 + flux financier + mes annonces compactes + demandes en attente
3. **Onglet Annonces** → `ProprioListingsScreen` : 4 chips filtre + cards 16:9 avec KPIs inline + bouton "Calendrier/Modifier/Stats" + card "Nouvelle annonce" dashed
4. Tap "Modifier" sur une annonce → `ProprioListingEditScreen` (4 tabs)
5. **Onglet Finances** → `ProprioFinancesScreen` : period switcher + bénéfice net hero + compte de résultat + perf par bien + projection 3 mois (line chart)
6. **Onglet Messages** → `_MessagesPlaceholder` (stub V8)
7. **Onglet Profil** → `ClientProfileScreen` (transverse V6) avec subtitle « Propriétaire · 4 biens » + badge « ★ Hôte certifié »

**Cas multi-rôle :**
8. Propriétaire tap "Démarcheur" dans le Role Switcher → `RoleHomeRouter` push `DemarcheurShell`
9. Propriétaire tap "Locataire" → `RoleHomeRouter` push `LocataireShell`
10. Tous les Shells sont maintenant fonctionnels — le switch de rôle est tri-directionnel.

**Postconditions :**
- Shell propriétaire fonctionnel sur 5 onglets
- Switch de rôle bidirectionnel **complet** entre les 3 rôles
- 0 erreur `flutter analyze`
- Tous les écrans suivent le proto au pixel-near (à 5% près)

## 6. Cas Alternatifs / Limites

| Cas | Comportement |
|---|---|
| CA1 | Propriétaire sans aucune annonce | Empty state HORS V7 (cf. RM6 V6, traité en finition post-V9) — mocks toujours remplis donc cas non atteignable |
| CA2 | Propriétaire avec mock chart (line chart Projection) | Données mockées 7 mois Sept→Mars, marker accent sur Nov, ligne verticale séparateur passé/futur |
| CA3 | Tap "Nouvelle annonce" | SnackBar "Création d'annonce disponible prochainement (F2)" |
| CA4 | Tap "Exporter PDF/CSV" | SnackBar "Export disponible prochainement (F8)" |
| CA5 | Tap sur jour calendrier (tab 2 ListingEdit) | SnackBar "Édition calendrier disponible prochainement" |
| CA6 | Tap "Demandes en attente" Dashboard | SnackBar "Détail demande disponible prochainement (F5)" |

## 7. Gestion des Erreurs

| Erreur | Comportement |
|---|---|
| E1 | Mock incohérent (revenu négatif, occupation > 100%) | Pas de gestion runtime — les mocks sont contrôlés en dur, pas de validation |
| E2 | Switch de rôle pendant que ProprioShell est actif | `RoleHomeRouter` `pushAndRemoveAll` reset le stack — pas de fuite d'état |
| E3 | `fl_chart` ne supporte pas un cas (mix solid/dashed dans même série) | Fallback : 2 séries `LineChartBarData` distinctes — passé solid + futur dashed |

## 8. Contraintes

- **Performance :** rendu fluide low-end Android (`fl_chart` léger, sparkbar custom = simple Container)
- **Accessibilité :** contrastes WCAG AA, surtout les `t-small` sur la hero card gradient or
- **Plateformes :** iOS 13+, Android 10+
- **10 règles Flutter du projet** : NON NÉGOCIABLES (1 widget = 1 fichier, pas de fonction privée → Widget, helpers dédiés)
- **Réutilisation maximale** des Vagues 1-6 (`BlurContainer`, `BadgeStatus`, `AsfarChip`, `DynamicAppBar`, `BottomNav`, `SectionHeader`, `ScreenScaffold`, `ListingPushCard` réadapté ?, `MiniStatsInline`, `StatusPillsRow`, `FieldRow`)
- **SOLID nouveau code** : nouveaux widgets respectent la séparation rôles
- **Profile transverse** déjà ready V6 — pas de duplication

## 9. Critères d'Acceptation

- [ ] **CA-1.** `ProprioShell` fonctionnel sur 5 onglets avec `IndexedStack` + `BottomNav` + `BottomNavTabs.proprio`
- [ ] **CA-2.** Les 4 écrans propriétaire du proto sont implémentés au pixel-near (≤ 5% d'écart paddings/sizes)
- [ ] **CA-3.** `ProprioListingEditScreen` fonctionnel sur 4 tabs (Infos / Calendrier / Tarifs / Règles) via `DefaultTabController` + TabBar underline custom accent
- [ ] **CA-4.** `RoleHomeRouter.shellFor('proprietaire')` retourne `ProprioShell` (au lieu du `_RolePlaceholderShell` V6)
- [ ] **CA-5.** Switch de rôle tri-directionnel fonctionnel (Locataire ↔ Démarcheur ↔ Propriétaire) testable depuis le tab Profil de chaque rôle
- [ ] **CA-6.** Sparkbar 6 mois Dashboard = `Container` ratios custom (height proportionnelle aux valeurs mock, dernière barre en accent or avec étiquette flottante)
- [ ] **CA-7.** Line chart Finances « Projection 3 mois » via `fl_chart` : 7 mois Sept→Mars, passé solide + futur dashed + area gradient + marker accent sur Nov + ligne verticale séparateur
- [ ] **CA-8.** Calendrier ListingEdit view-only — grid 7×N avec couleurs réservé/attente/aujourd'hui + légende + tap = SnackBar
- [ ] **CA-9.** Onglet Messages = `_MessagesPlaceholder` (cohérence V5-V6)
- [ ] **CA-10.** Profile = `ClientProfileScreen` (transverse V6) — pas de duplication
- [ ] **CA-11.** Tous CTAs hors-V7 = SnackBar avec mention de la vague cible (F2 / F5 / F8)
- [ ] **CA-12.** Données via mocks (réutilise `SampleListings` + nouveaux `SampleProprioStats`, `SamplePnLEntries`, `SamplePropertyPerf`, `SampleProjectionPoints`)
- [ ] **CA-13.** `flutter analyze` 0 nouvelle erreur (legacy 41 issues inchangées)
- [ ] **CA-14.** Score audit ≥ 60 sur les 6 dimensions
- [ ] **CA-15.** `RECONSTRUCTION_UI_ASFAR.md` Vague 7 entièrement cochée + journal mis à jour
- [ ] **CA-16.** Documentation HTML `vague-7-proprietaire.html` générée et indexée

## 10. Hors Périmètre

- ❌ Branchement BLoC réel (`AppartementBloc`, `ChargeBloc`, `CompteBloc`, `ReservationBloc`) → vague de finition
- ❌ Wizard de création d'annonce (`F2`, hors-proto)
- ❌ Export PDF/CSV (`F8`, hors-proto)
- ❌ Démarcheurs côté proprio (`F5`, hors-proto)
- ❌ Calendrier interactif édition (sera traité quand `CalendarPlageBloc` rebranché)
- ❌ Reconstruction de l'onglet Messages (Vague 8)
- ❌ Modification du backend / API / models
- ❌ Refactoring des BLoCs existants (règle SOLID nouveau code uniquement)
- ❌ Modification du `ClientProfileScreen` ou `ProfileDisplayInfo` (déjà ready V6 — l'archi V7 valide juste son utilisation)

---

## 11. Décisions actées (questions BA)

| Q | Décision |
|---|---|
| Q1 — Pattern 4 tabs ListingEdit | `DefaultTabController` Material standard avec TabBar indicator underline accent or |
| Q2 — Charts | Sparkbar Dashboard = custom Container ratios (simple). Line chart Projection Finances = `fl_chart` 0.69 (déjà installé) |
| Q3 — Calendrier | View-only — tap jour = SnackBar « Édition disponible prochainement ». Édition réelle quand `CalendarPlageBloc` rebranché en finition |
| Q4 — CTAs hors-V7 | Tous SnackBar stub avec mention de la vague cible (F2 wizard / F5 démarcheurs proprio / F8 PDF) |

---

## 12. Inventaire des livrables Vague 7

### Écrans nouveaux (5)
| # | Écran | Fichier cible | Source proto |
|---|---|---|---|
| 7.1 | Dashboard | `lib/screen/client/proprio/home/dashboard_screen.dart` | `ProprietaireDashboard` |
| 7.2 | Listings (mes annonces) | `lib/screen/client/proprio/appartements/listings_screen.dart` | `ProprietaireListings` |
| 7.3 | ListingEdit (4 tabs) | `lib/screen/client/proprio/appartements/listing_edit_screen.dart` | `ProprietaireListingEdit` |
| 7.4 | Finances P&L | `lib/screen/client/proprio/comptabilite/finances_screen.dart` | `ProprietaireFinances` |
| 7.5 | Shell + 5 tabs | `lib/screen/client/proprio/proprio_shell.dart` | `app.jsx` |

### Refactor (1)
| # | Action | Fichier | Note |
|---|---|---|---|
| R1 | Compléter `RoleHomeRouter.shellFor` pour proprio | `role_home_router.dart` | Retourner `ProprioShell` (au lieu du placeholder V6) |

### Mocks (≥4)
| # | Mock | Fichier |
|---|---|---|
| M1 | `SampleProprioStats` (revenus, occupation, ADR, etc.) | `lib/screen/client/proprio/sample/sample_proprio_stats.dart` |
| M2 | `SamplePnLEntries` (lignes Revenus + Charges + Bénéfice) | `lib/screen/client/proprio/sample/sample_pnl_entries.dart` |
| M3 | `SamplePropertyPerf` (performance par bien : occupation+delta+revenus) | `lib/screen/client/proprio/sample/sample_property_perf.dart` |
| M4 | `SampleProjectionPoints` (7 mois Sept→Mars line chart) | `lib/screen/client/proprio/sample/sample_projection_points.dart` |
| M5 | `SamplePendingRequests` (demandes en attente Dashboard) | `lib/screen/client/proprio/sample/sample_pending_requests.dart` |

---

## ✅ Validation BA

- [x] Objectif clair (5 onglets + finalisation switch tri-directionnel)
- [x] Règles métier listées (RM1-RM14)
- [x] Cas d'usage nominal + multi-rôle décrit
- [x] Cas alternatifs/limites identifiés (CA1-CA6)
- [x] Erreurs identifiées (E1-E3)
- [x] Critères d'acceptation définis (CA-1 à CA-16)
- [x] Hors périmètre clarifié
- [x] Inventaire des livrables explicite (5 écrans + 1 refactor + ≥4 mocks)

**Statut :** spécification validée → transmission à 🏗️ Architecture
