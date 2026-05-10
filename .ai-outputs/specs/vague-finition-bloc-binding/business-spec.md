# 📋 Spécification Métier — Vague de finition · Branchement BLoCs réels

> **Auteur :** Business Analyst (workflow `/feature full`)
> **Date :** 2026-05-10
> **Statut :** ✅ Validé par l'utilisateur (4 questions BA tranchées)
> **Parent :** `RECONSTRUCTION_UI_ASFAR.md` (cadre global) + `.ai-outputs/specs/refonte-design-asfar/business-spec.md`

---

## 1. Contexte

Les Vagues 1-8 ont reconstruit l'app Asfar Premium avec **des données mockées** (`Sample*` × 12 fichiers, ~200 entrées en dur). Les 21 BLoCs métier (`AppartementBloc`, `ConversationBloc`, etc.) sont **intacts** mais non branchés sur les écrans reconstruits.

Cette **vague de finition** débranche les mocks et connecte les écrans aux BLoCs réels qui dialoguent avec le backend Spring Boot (`192.168.1.11:7565`). Elle inclut aussi 3 chantiers connexes documentés en TODO REBUILD :
1. Widget `EmptyState` générique + branchement dans 8 zones
2. Édition calendrier propriétaire (tap pour bloquer/débloquer + nav mois)
3. Persistance switch de rôle via Hive

**À l'issue de cette vague, l'app fonctionne en bout-en-bout sur backend réel.**

## 2. Objectif

Connecter **toutes les listes/données affichées** des Vagues 1-8 aux BLoCs métier réels (et donc au backend), gérer les états de chargement/erreur/cache, et finaliser les 3 items de dette technique.

## 3. Acteurs

- **Locataire** — voit ses vraies réservations, favoris, conversations
- **Propriétaire** — voit ses vraies annonces, charges, calendriers
- **Démarcheur** — voit ses vraies références, commissions
- **Équipe technique** — exécute la vague (15 lots par BLoC)

## 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | **Découpage par BLoC** | 15 lots de dev, 1 par BLoC à brancher (cf. § 12). Permet de traçabilité fine et tests isolés |
| RM2 | **Pattern cache-first (Hive)** | Chaque BLoC affiche d'abord le cache Hive (réponse instantanée), puis rafraîchit depuis l'API. Pattern déjà appliqué côté `AppartementBloc`, `ReservationBloc` (cf. `BUGFIX_*.md` + `cache-offline-reservations.html`) |
| RM3 | **Calculs Flutter via helpers** | Les agrégations/calculs locaux (Q1 estimation, ratios cashflow, KPIs Dashboard proprio) sont calculés côté Flutter via des helpers dédiés (`ProjectionCalculator`, `KpiAggregator`, etc.) à partir des données BLoC. Pas d'évolution backend dans cette vague |
| RM4 | **Mapping modèle métier → modèle UI** | Helpers de mapping `Appartement → ListingPreview`, `Reservation → ReferralPreview`, `Conversation → ConversationPreview`, etc. Les modèles UI-only V5-V8 (`lib/model/ui_only/`) sont **conservés** comme value objects de présentation |
| RM5 | **EmptyState générique** | Widget unique `EmptyState` (icon + titre + body + CTA optionnel) réutilisé dans les 8 zones. Variants visuels selon contexte (gradient or hero ou minimal) |
| RM6 | **Indicateur stale** | Si données affichées viennent du cache Hive (offline ou sync impossible), afficher un badge discret `« Mis à jour il y a X » + bouton refresh` |
| RM7 | **Gestion erreur réseau** | Timeout/500/offline : si cache dispo, afficher données stale + indicateur. Si pas de cache, `EmptyState` « Connexion impossible » + bouton retry |
| RM8 | **Édition calendrier proprio** | Tap sur jour disponible → BlocCubit appelle `CalendarPlageBloc::BlockDay` (création plage 1 jour). Tap sur jour bloqué → `UnblockDay`. Navigation mois `<>` → load plages du mois |
| RM9 | **Persistance switch rôle** | Nouvel event `UserBloc::SetActiveRole(roleId)` qui mute le user, persiste en Hive (StorageService), et émet `UserLoaded` MAIS sans déclencher `_startDataPreloading` (pas re-charger toute la chaîne, juste switcher l'UI) |
| RM10 | **Suppression mocks** | Tous les `Sample*` retirés du projet à la fin de la vague. `lib/screen/client/{role}/sample/` et `lib/screen/client/shared/inbox/sample/` supprimés. `SampleListings` (V5 utilisé partout) retiré aussi |
| RM11 | **Modèles UI-only conservés** | `lib/model/ui_only/*` reste — sert de DTO de présentation, mappings backend → UI font le pont |
| RM12 | **Tokens uniquement** | `AppColors.*`, `AppRadii.*`, `AppTextStyles.*` (cohérence V1-V8) |
| RM13 | **0 régression V1-V8** | Tous les écrans précédents continuent de fonctionner après la vague (test E2E manuel par rôle) |

## 5. Cas d'Usage Principal

**Préconditions :**
- Utilisateur connecté avec un rôle valide
- Backend Spring Boot accessible (`192.168.1.11:7565`)
- Cache Hive éventuellement vide (premier lancement post-déploiement)

**Scénario nominal — Locataire :**
1. Splash → `LocataireShell` → Onglet Explorer
2. `LocataireHomeScreen` affiche skeletons puis les **vrais appartements** depuis `AppartementBloc.state.appartements` (mappés en `ListingPreview` via helper)
3. Tap sur un appartement → `LocataireDetailScreen` avec données réelles (`AppartementDetail`)
4. Tap Réserver → `LocataireReserveScreen` 3 étapes → tap final → `ReservationBloc::CreateReservation`
5. Onglet Voyages → `LocataireTripsScreen` affiche les réservations depuis `ReservationBloc` (status à venir / passées)
6. Onglet Favoris → `LocataireFavoriteScreen` depuis `FavoriteBloc`
7. Onglet Messages → `MessagingListScreen` depuis `ConversationBloc` adapté au rôle
8. Onglet Profil → `ClientProfileScreen` (V6) avec utilisateur réel + bouton « Changer rôle » dispatch `UserBloc::SetActiveRole`

**Scénario nominal — Propriétaire (avec édition calendrier) :**
1. `ProprioShell` → onglet Annonces → `ProprioListingsScreen` depuis `AppartementBloc` (filtré sur `mes appartements`)
2. Tap card → `ProprioListingEditScreen` 4 tabs
3. Tab Calendrier → `MiniCalendarGrid` charge les plages du mois courant via `CalendarPlageBloc::LoadPlages(month, listingId)`
4. Tap jour disponible → `CalendarPlageBloc::BlockDay(day, listingId)` → cellule passe en accent
5. Chevron `>` → load mois suivant

**Scénarios cas d'erreur :**
- Backend offline → cache Hive stale + badge `« Mis à jour il y a 2 j »` + bouton refresh
- Cache vide + offline → EmptyState « Connexion impossible, réessayer »
- Liste vide en backend (proprio sans annonces) → EmptyState « Aucune annonce » + CTA « Nouvelle annonce » (qui stub F2)

**Postconditions :**
- 0 fichier `Sample*` dans le projet
- Tous les écrans Vagues 1-8 lisent depuis les BLoCs réels
- 8 zones avec EmptyState branchés
- Édition calendrier fonctionnelle
- Switch de rôle persisté en Hive

## 6. Cas Alternatifs / Limites

| Cas | Comportement |
|---|---|
| CA1 | Modèle UI-only manque un champ (ex: `MonthlyRevenue` n'a pas d'id) | Le helper de mapping fournit un id généré (`'rev-${month}'`) |
| CA2 | Backend retourne un type incompatible (`null`, type mismatch) | Helper de mapping retourne null ou valeur par défaut + log debug |
| CA3 | Édition calendrier — concurrent (autre device modifie) | Reload silencieux après mutation côté serveur |
| CA4 | Switch de rôle — user n'a pas le rôle cible (ex: pas démarcheur) | `RoleHomeRouter` retourne placeholder ou empty state. Mais V6/V7 ont déjà ce pattern (placeholder était utilisé avant V6/V7) |
| CA5 | Mock `SampleProjectionPoints` retire mais `ProjectionCalculator` doit utiliser les `Reservation` historiques | Si `ReservationBloc` n'a pas les 6 derniers mois en cache, fallback projection vide ou EmptyState dédié |
| CA6 | `ConversationBloc` ne fournit pas la distinction `MessageKind` (text/reservationCard/acceptedReferralCard) | Helper de détection : si message contient `bookingCode` → `reservationCard`, si contient `referralCode + commission` → `acceptedReferralCard`, sinon `text` |

## 7. Gestion des Erreurs

| Erreur | Comportement |
|---|---|
| E1 | Timeout API (> 30s) | Cache Hive si dispo + indicateur stale, sinon EmptyState retry |
| E2 | 401 / 403 (token expiré) | Logout + redirection Onboarding (déjà géré dans `dio_request.dart` du projet) |
| E3 | 500 server error | Toast erreur + bouton retry. Si cache Hive → continuer avec stale |
| E4 | Schéma JSON différent (Appartement.fields renommés) | Helper de mapping catch + log + fallback valeur par défaut |
| E5 | `CalendarPlageBloc::BlockDay` échoue côté serveur | Rollback optimistic update + SnackBar erreur |
| E6 | `UserBloc::SetActiveRole` échoue (Hive locked) | Fallback : mute user.type en mémoire seul (cohérence V6 actuelle) |

## 8. Contraintes

- **Performance :** cache-first → écran s'affiche en < 200ms même si backend lent
- **Réseau :** prévoir backend accessible en dev (validé par utilisateur — serveur tourne en local)
- **10 règles Flutter** : NON NÉGOCIABLES
- **Pattern cache-first existant** déjà dans `AppartementBloc`, `ReservationBloc` (cf. `cache-offline-reservations.html`) — reproduire/réutiliser
- **Mappings centralisés** : `lib/util/mapping/` — pas dispersés dans les écrans
- **0 régression V1-V8** : Vagues précédentes continuent de fonctionner pendant le branchement progressif (lot par lot)
- **Tests E2E manuels** : pas de test unitaire ajouté dans cette vague (cohérence convention projet), mais validation runtime obligatoire avant merge

## 9. Critères d'Acceptation

- [ ] **CA-1.** Tous les fichiers `Sample*` supprimés de `lib/` (grep retourne 0)
- [ ] **CA-2.** Helpers de mapping centralisés dans `lib/util/mapping/` : `appartement_to_listing.dart`, `reservation_to_referral.dart`, `conversation_to_preview.dart`, etc.
- [ ] **CA-3.** Helpers de calcul centralisés dans `lib/util/calc/` : `projection_calculator.dart`, `kpi_aggregator.dart`, `cashflow_aggregator.dart`
- [ ] **CA-4.** Widget `EmptyState` générique créé dans `lib/widget/feedback/empty_state.dart` (icon + titre + body + CTA optionnel + variants)
- [ ] **CA-5.** EmptyState branché dans les 8 zones identifiées
- [ ] **CA-6.** Indicateur stale (`StaleBadge` + bouton refresh) intégré dans les écrans qui chargent des listes
- [ ] **CA-7.** `MiniCalendarGrid` interactif : tap jour → BlockDay/UnblockDay via `CalendarPlageBloc`. Chevrons `<>` → `LoadPlages(month)`
- [ ] **CA-8.** `UserBloc::SetActiveRole(roleId)` event créé + persistance Hive (sans `_startDataPreloading`)
- [ ] **CA-9.** `ProfileRoleSwitcher.onSwitchRole` dispatch `SetActiveRole` au lieu de muter `user.type` en mémoire
- [ ] **CA-10.** 15 lots branchement BLoC livrés (cf. § 12)
- [ ] **CA-11.** `flutter analyze` 0 nouvelle erreur (legacy 41 issues inchangées)
- [ ] **CA-12.** Test E2E manuel par rôle : Locataire, Démarcheur, Propriétaire (parcours nominal complet)
- [ ] **CA-13.** Score audit ≥ 60
- [ ] **CA-14.** `RECONSTRUCTION_UI_ASFAR.md` : section TODO REBUILD vidée des items traités + journal mis à jour
- [ ] **CA-15.** Documentation HTML `vague-finition-bloc-binding.html` générée
- [ ] **CA-16.** 0 régression visuelle V1-V8 (les écrans rendent toujours fidèlement le proto)

## 10. Hors Périmètre

- ❌ Modification des modèles Hive existants (`Appartement.g.dart`, etc.)
- ❌ Évolution backend Spring Boot (pas de nouveaux endpoints)
- ❌ Tests unitaires / widgets / intégration (cohérence convention projet, mocks runtime déjà validés)
- ❌ WebSocket temps réel pour Messaging (vague ultérieure)
- ❌ Optimisation perf au-delà du cache Hive existant
- ❌ Refactor des BLoCs existants (qui violent SOLID en mélangeant rôles) — cf. règle projet « SOLID nouveau code uniquement »
- ❌ Vague 9 hors-proto (F2-F10) — chantier indépendant
- ❌ Documentation API/Swagger backend
- ❌ I18n (français-CI uniquement, comme spec parent)

---

## 11. Décisions actées (questions BA)

| Q | Décision |
|---|---|
| Q1 — Découpage | **Par BLoC (15 lots)** — granularité fine, traçabilité maximale, tests isolés. Cf. § 12 pour la liste |
| Q2 — Backend dispo | **Oui, serveur tourne en local** (`192.168.1.11:7565`). Test runtime à chaque lot via `flutter run` |
| Q3 — Calculs locaux | **Calculer côté Flutter** via helpers `lib/util/calc/`. Pas d'évolution backend dans cette vague |
| Q4 — Erreurs réseau | **Cache Hive + indicateur stale** (cohérence pattern V5 `cache-offline-reservations.html`). Si pas de cache → EmptyState retry |

---

## 12. Inventaire des 15 lots (par BLoC)

| # | Lot | BLoC | Mocks à retirer | Écrans concernés |
|---|---|---|---|---|
| 1 | Atomes transverses | — | — | Crée `EmptyState` widget + `StaleBadge` widget + `lib/util/mapping/` + `lib/util/calc/` |
| 2 | UserBloc::SetActiveRole | UserBloc | — | `client_profile_screen.dart` (event dispatch) + persistance Hive |
| 3 | AppartementBloc | AppartementBloc | `SampleListings` | `LocataireHomeScreen`, `LocataireSearchScreen`, `LocataireFavoriteScreen` (heart toggles), `ProprioListingsScreen`, `ProprioListingEditScreen` (Infos tab) |
| 4 | ReservationBloc | ReservationBloc | — | `LocataireTripsScreen`, `LocataireReserveScreen` (création), `ProprioDashboard` (demandes en attente partielles) |
| 5 | FavoriteBloc | FavoriteBloc | — | `LocataireFavoriteScreen`, heart buttons partout |
| 6 | DemarcheurBloc | DemarcheurBloc, ProprietaireDemarcheurBloc | `SampleReferrals`, `SamplePendingRequests` (partie démarcheurs) | `DemarcheurDashboard`, `DemarcheurReferralsScreen`, `ReferralDetailScreen` |
| 7 | PartenariatBloc | PartenariatBloc | — | `DemarcheurReferralsScreen` (partenariats), `ProprioDemarcheursScreen` (F5 hors-V) |
| 8 | CompteBloc + ChargeBloc | CompteBloc, ChargeBloc | `SamplePnLEntries`, `SampleProprioStats`, `SamplePropertyPerf`, `SampleProjectionPoints`, `SampleCommissions` | `ProprioDashboard` (revenus + cashflow), `ProprioFinancesScreen` (P&L + perf + projection), `DemarcheurWalletScreen` (commissions historique) |
| 9 | ConversationBloc | ConversationBloc | `SampleConversations`, `SampleThreads` | `MessagingListScreen`, `MessagingThreadScreen` |
| 10 | NotificationBloc | NotificationBloc | — | Bouton bell des Dashboards (V6/V7) |
| 11 | MapBloc | MapBloc | — | `LocataireSearchScreen` (carte filtrée) |
| 12 | CalendarPlageBloc + AvailabilityBloc | CalendarPlageBloc, AvailabilityBloc, OccupationCalendarBloc | — | `MiniCalendarGrid` interactif (`ProprioListingEditScreen` tab Calendrier) |
| 13 | PaysBloc | PaysBloc | — | Auth (Signup) — listes pays |
| 14 | EmptyState — branchement 8 zones | — | — | LocataireTrips, LocataireFavorite, ProprioListings, DemarcheurReferrals, WalletScreen, MessagingList, MessagingThread vide, Dashboard sections |
| 15 | Documentation + cleanup | — | tous | Suppression `lib/screen/**/sample/`, `lib/screen/client/locataire/home/sample_listings.dart`, mise à jour `RECONSTRUCTION_UI_ASFAR.md` |

### 12.1 Suppressions finales (Lot 15)
- `lib/screen/client/locataire/home/sample_listings.dart` (V5)
- `lib/screen/client/demarcheur/sample/` (3 fichiers V6)
- `lib/screen/client/proprio/sample/` (5 fichiers V7)
- `lib/screen/client/shared/inbox/sample/` (2 fichiers V8)

→ **Total : ~12 fichiers `Sample*` supprimés.**

---

## ✅ Validation BA

- [x] Objectif clair (4 axes : branchement BLoCs + EmptyState + calendrier + persistance switch)
- [x] Règles métier listées (RM1-RM13)
- [x] Cas d'usage nominal Locataire + Proprio décrits
- [x] Cas alternatifs/limites identifiés (CA1-CA6)
- [x] Erreurs identifiées (E1-E6)
- [x] Critères d'acceptation définis (CA-1 à CA-16)
- [x] Hors périmètre clarifié
- [x] **Inventaire 15 lots explicite** avec BLoCs, mocks à retirer, écrans concernés (§ 12)
- [x] Décisions BA Q1-Q4 actées et documentées

**⚠️ Note importante :** Cette vague est **massive** (15 lots). Le dev sera **séquentiel** mais l'audit / docs seront en fin de vague. Si un lot échoue, on s'arrête et on évalue.

**Statut :** spécification validée → transmission à 🏗️ Architecture
