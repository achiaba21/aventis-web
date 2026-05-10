# 📋 Spécification Métier : Refonte Design Asfar Premium

> **Auteur :** Business Analyst (workflow `/feature full`)
> **Date :** 2026-05-07
> **Statut :** ✅ Validation tacite — utilisateur a demandé `continu` après questions BA, hypothèses par défaut documentées en §11

---

## 1. Contexte

L'application Asfar (Flutter, multi-rôle locataire/propriétaire/démarcheur) tourne aujourd'hui sur un thème **clair** (fond blanc, accent orange `#FFA02A`). Un prototype HTML/React (`~/Downloads/Asfar Prototype.html`) propose une **nouvelle identité visuelle dark "Asfar Premium"** avec :

- Palette dark (fond `#0A0A0B`), accent or chaud `#E8B86B`
- Identité "hospitalité + luxe africain" assumée
- 18 écrans définis sur les 3 rôles + parcours transverses (onboarding, messaging, profil)
- Composants soignés : Liquid Glass iOS, sparkbars, timelines, gradients radiaux

L'utilisateur souhaite **substituer** entièrement l'identité visuelle actuelle par celle du prototype, sans coexistence de thèmes.

## 2. Objectif

**Remplacer intégralement l'identité visuelle de l'application par celle du prototype Asfar Premium**, sans dégrader les fonctionnalités métier existantes ni l'architecture sous-jacente (BLoCs, services, données).

## 3. Acteurs

- **Locataire** — voyageur cherchant un logement meublé
- **Propriétaire** — bailleur listant ses appartements
- **Démarcheur** — apporteur d'affaires gagnant 10% de commission
- **Équipe technique** — exécute la refonte

## 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | **Refonte totale** | Pas de coexistence de thèmes — le clair disparaît, le dark devient l'unique identité |
| RM2 | **Pas de code parallèle** | Chaque élément est soit modifié, soit supprimé. Pas de namespace `Asfar*` qui coexiste avec l'ancien |
| RM3 | **Design 100% prototype** | Aucune liberté chromatique, typo, ou layout vis-à-vis du prototype HTML |
| RM4 | **Adaptation des manquants** | Tout écran/widget de l'app absent du prototype DOIT être redessiné dans le langage Asfar Premium (cohérence visuelle) |
| RM5 | **Structure préservée** | L'architecture du projet (dossiers, BLoCs, models, services, repos, backend) ne change pas. Seule la couche UI est touchée |
| RM6 | **Tier unique** | Pas de système free/premium — le dark est le thème de tous les utilisateurs |
| RM7 | **Inventaire exhaustif** | Chaque écran existant doit être adressé : soit migré, soit supprimé. Aucun écran ne doit rester en thème clair après livraison finale |
| RM8 | **Scope UI only** | BLoCs (mêmes ceux qui violent SOLID en mélangeant les rôles), models, repositories, services API, schémas Hive, backend Spring Boot, WebSocket : **non touchés** |

## 5. Cas d'Usage Principal

**Préconditions :**
- L'utilisateur ouvre l'application après la livraison de la refonte
- Son rôle (locataire / propriétaire / démarcheur) est déjà connu (auth existante)

**Scénario :**
1. L'utilisateur lance l'app → splash dark Asfar
2. Si non connecté → écran d'onboarding/auth en style Asfar Premium
3. Si connecté → home de son rôle (Locataire Explorer, Propriétaire Dashboard, ou Démarcheur Dashboard) en style Asfar Premium
4. Toute navigation (réservation, listings, finances, messages, profil) → écrans en style Asfar Premium
5. Les fonctionnalités absentes du proto (auth, scanner QR, wizard appart, comptabilité, notifs, démarcheurs côté proprio, carte réelle, PDF, gestion banque) → écrans **redessinés** dans le langage Asfar (couleurs, typo, composants `AsfarXxx`, mêmes flows métier)

**Postconditions :**
- 0 écran en thème clair encore actif dans l'app
- 0 référence à `AppColors.*` (palette claire) dans le code productif
- Tous les écrans utilisent les widgets/tokens Asfar
- Les données et flows métier restent fonctionnels (réservations, paiements, notifs, etc.)

## 6. Cas Alternatifs

| Cas | Condition | Comportement |
|---|---|---|
| CA1 | Écran absent du proto mais présent dans l'app (auth, wizard, scanner, comptabilité, démarcheurs proprio, notifs, banque, carte) | Phase UI/UX — propositions de design dans le langage Asfar, validation utilisateur |
| CA2 | Écran obsolète dans l'app | Suppression pure (sera identifiée par l'agent Architecture lors du scan) |
| CA3 | Composant proto pas encore présent dans l'app (ex. timeline démarcheur, sparkbar) | Création nette, pas de migration |
| CA4 | Composant existant qui peut servir tel quel (ex. shimmer, error widget) | Migration cosmétique : couleurs Asfar, garder la logique |
| CA5 | Conflit entre la maquette et une contrainte métier (ex. proto ne montre pas la modale de confirmation OTP) | Le métier prime, le design s'adapte au langage Asfar |

## 7. Gestion des Erreurs

| Erreur | Condition | Comportement |
|---|---|---|
| E1 | Régression visuelle après bascule | Test sur 5 écrans représentatifs avant merge ; rollback possible via revert git |
| E2 | Backdrop-filter non rendu sur Android < 12 | Fallback opaque (bgElev1) géré par `AsfarBlurContainer` |
| E3 | Police SF Pro Display non disponible sur Android | Fallback Inter via `google_fonts` |
| E4 | Ancien widget utilisé par erreur dans nouveau code | Audit qualité bloque (score < 60) — règle SOLID nouveau code |
| E5 | Feature en cours dans `.ai-outputs/features/` qui touche au visuel | Phase Architecture identifie + flag pour intégration |

## 8. Contraintes

- **Performance :** rendu fluide sur low-end Android (RAM 2 Go, Android 10+) — fallbacks blur prévus
- **Accessibilité :** contrastes WCAG AA minimum, surtout les `t-small` sur fond `bg-elev-2`
- **Localisation :** français-CI uniquement, FCFA, formats de dates fr-FR
- **Plateformes :** iOS 13+ et Android 10+
- **Délai :** non précisé — exécution par vagues, validation par lot
- **Backend :** intact, pas de migration API
- **10 règles Flutter du projet** : NON NÉGOCIABLES (1 widget = 1 fichier, pas de fonction privée retournant Widget, etc.)
- **SOLID nouveau code** : tout nouveau widget Asfar respecte la séparation rôles ; le legacy non refactoré explicitement (règle projet)

## 9. Critères d'Acceptation

- [ ] **CA-1.** L'app au lancement est entièrement en thème dark Asfar — aucun fond blanc visible
- [ ] **CA-2.** Tous les 18 écrans du prototype sont implémentés à l'identique pixel-near (à 5% près sur les paddings/sizes)
- [ ] **CA-3.** Tous les écrans de l'app non-couverts par le proto sont redessinés en style Asfar Premium et validés par l'utilisateur
- [ ] **CA-4.** Aucun ancien widget (CustomButton, InputField, BottomNav, DynamicAppBar, TextSeed…) n'est encore référencé dans les écrans en production
- [ ] **CA-5.** `AppColors` est supprimé ou inutilisé ; `AppTheme.light` est supprimé ; `MaterialApp.theme = AsfarTheme.dark`
- [ ] **CA-6.** Tous les blics, services, repos, models, schémas Hive sont **inchangés**
- [ ] **CA-7.** Toutes les fonctionnalités métier passent leurs tests existants (régression nulle)
- [ ] **CA-8.** Score audit ≥ 60 sur les 6 dimensions
- [ ] **CA-9.** Documentation HTML générée et indexée

## 10. Hors Périmètre

- ❌ Refactor des BLoCs existants (séparation rôles SOLID) — chantier indépendant
- ❌ Migration vers `go_router` ou `auto_route` — chantier indépendant
- ❌ Internationalisation (i18n) — chantier indépendant
- ❌ Mode clair / theme switching — supprimé, plus de coexistence
- ❌ Évolution fonctionnelle (pas de nouvelles features métier dans cette refonte)
- ❌ Refonte du backend Spring Boot
- ❌ Migration des modèles Hive existants
- ❌ Performance / cache (sauf régressions introduites par la refonte)

---

## 11. Hypothèses retenues (Q1-Q4 BA, validation tacite via "continu")

> L'utilisateur a répondu `continu` après que le BA ait posé 4 questions essentielles. Les hypothèses ci-dessous sont retenues comme défaut. Si une hypothèse s'avère fausse en cours de route, retour BA pour révision.

| Q | Question | Hypothèse retenue |
|---|---|---|
| Q1 | Suppression vs adaptation des écrans absents du proto | **Tout est conservé et redesigné** dans le langage Asfar Premium. Aucun écran supprimé sauf si l'agent Architecture identifie du code mort lors du scan |
| Q2 | Périmètre UI only ou métier inclus | **UI only** : BLoCs / models / repos / services / Hive / backend / WebSocket = inchangés |
| Q3 | Ordre de migration | **Option A** : Vague 1 fondations (theme/tokens/primitives) → Vague 2 atomes → Vague 3 molécules → Vague 4 écrans dans cet ordre : Onboarding+Auth → Locataire → Démarcheur → Proprio → Messaging+Profil |
| Q4 | Cadence de validation | **Option B** : par lot logique (ex. tout l'onboarding+auth d'un coup, puis toute la zone locataire d'un coup, etc.) |

---

## 12. Inventaire des éléments app vs prototype

### Présents dans le proto (18 écrans cibles)

| # | Écran | Rôle | Fichier source proto |
|---|---|---|---|
| 1 | Onboarding choix de rôle | transverse | `extras.jsx` |
| 2 | Locataire Home (Explorer) | locataire | `locataire.jsx` |
| 3 | Locataire Search (filtres) | locataire | `locataire.jsx` |
| 4 | Locataire Detail | locataire | `locataire.jsx` |
| 5 | Locataire Reserve étape 1 (confirmer) | locataire | `locataire.jsx` |
| 6 | Locataire Reserve étape 2 (paiement) | locataire | `locataire.jsx` |
| 7 | Locataire Reserve étape 3 (confirmation) | locataire | `locataire.jsx` |
| 8 | Locataire Trips | locataire | `locataire.jsx` |
| 9 | Saved (Favoris) | locataire | `app.jsx` |
| 10 | Proprio Dashboard | propriétaire | `proprietaire.jsx` |
| 11 | Proprio Listings | propriétaire | `proprietaire.jsx` |
| 12 | Proprio Listing Edit (4 tabs) | propriétaire | `proprietaire.jsx` |
| 13 | Proprio Finances P&L | propriétaire | `proprietaire.jsx` |
| 14 | Démarcheur Dashboard | démarcheur | `demarcheur.jsx` |
| 15 | Démarcheur New (3 étapes) | démarcheur | `demarcheur.jsx` |
| 16 | Démarcheur Referral Detail | démarcheur | `demarcheur.jsx` |
| 17 | Démarcheur Wallet | démarcheur | `demarcheur.jsx` |
| 18a | Démarcheur Referrals (liste filtrée) | démarcheur | `app.jsx` |
| 18b | Messaging List | transverse | `extras.jsx` |
| 18c | Messaging Thread | transverse | `extras.jsx` |
| 18d | Profile (avec switch rôle) | transverse | `extras.jsx` |

### Absents du proto, à adapter en style Asfar (à valider Phase UI/UX)

| # | Élément app | Périmètre | Volume estimé |
|---|---|---|---|
| 1 | **Auth** : login, signup, OTP, vérification identité | `screen/login/`, `screen/signup/` | 4-5 écrans |
| 2 | **Wizard création appartement** (multi-step proprio) | `bloc/appartement_wizard_bloc/`, `widget/form/` | 5-7 étapes |
| 3 | **Scanner QR / check-in** | `widget/qr_*`, `mobile_scanner_*` | 1-2 écrans |
| 4 | **Comptabilité proprio étendue** (au-delà du P&L) | `screen/client/proprio/comptabilite/`, `bloc/charge_bloc/` | 3-4 écrans |
| 5 | **Démarcheurs côté proprio** (qui sont mes partenaires) | `screen/client/proprio/demarcheurs/` | 2-3 écrans |
| 6 | **Page Notifications** | `widget/notification/` | 1-2 écrans |
| 7 | **Carte réelle géocodée** | `flutter_map`, geolocator | 1-2 écrans |
| 8 | **Export PDF / impression reçus** | `pdf:`, `printing:` | 1 modale + intégration |
| 9 | **Gestion banque / cartes** | `widget/`, assets bank | 2-3 écrans |
| 10 | **Calendrier global réservations** | `widget/calendar/` | 1 écran |

> **Total estimé :** ~22 à 30 écrans supplémentaires à designer dans le langage Asfar Premium.

---

## ✅ Validation BA

- [x] Objectif clair et précis
- [x] Règles métier listées (RM1-RM8)
- [x] Cas d'usage principal décrit
- [x] Cas alternatifs identifiés (CA1-CA5)
- [x] Erreurs identifiées (E1-E5)
- [x] Critères d'acceptation définis (CA-1 à CA-9)
- [x] Hors périmètre clarifié
- [x] Hypothèses Q1-Q4 documentées (validation tacite via `continu`)

**Statut :** spécification validée → transmission à 🏗️ Architecture
