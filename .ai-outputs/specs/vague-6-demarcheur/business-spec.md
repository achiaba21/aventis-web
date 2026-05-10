# 📋 Spécification Métier — Vague 6 Démarcheur

> **Auteur :** Business Analyst (workflow `/feature full`)
> **Date :** 2026-05-09
> **Statut :** ✅ Validé par l'utilisateur
> **Parent :** `.ai-outputs/specs/refonte-design-asfar/business-spec.md` (cadre global de la refonte)

---

## 1. Contexte

La reconstruction UI Asfar Premium (pilotée par `RECONSTRUCTION_UI_ASFAR.md`) a livré les Vagues 1 à 5 (atomes + layouts + Onboarding + Auth + parcours Locataire complet). La Vague 6 attaque le **rôle Démarcheur**.

Particularité métier découverte au BA : **un utilisateur peut cumuler plusieurs rôles** (un démarcheur peut aussi être locataire, un propriétaire aussi). Le `ProfileRoleSwitcher` livré en Vague 5 est le mécanisme qui permet de basculer entre interfaces. Ce mécanisme n'a pas été branché en Vague 5 par dépendance avec les Shells démarcheur/proprio (Vagues 6/7).

## 2. Objectif

1. Reconstruire les écrans du rôle Démarcheur fidèlement au prototype (sources : `demarcheur.jsx`, `app.jsx`, `extras.jsx`).
2. Débloquer le **switch de rôle** lancé en Vague 5 (Profile transverse + RoleHomeRouter complet).
3. Intégrer ces écrans dans un Shell démarcheur 5 onglets cohérent avec la Vague 5.

## 3. Acteurs

- **Démarcheur** — apporteur d'affaires gagnant 10% de commission sur les séjours qu'il référence
- **Démarcheur multi-rôle** — démarcheur qui est aussi locataire ou propriétaire (bascule via Role Switcher)
- **Équipe technique** — exécute la vague

## 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | **Commission démarcheur** | 10% du sous-total séjour, versée après paiement effectif du client |
| RM2 | **Versement automatique** | Tous les vendredis, sur le compte Orange Money lié |
| RM3 | **Profile transverse** | Le Profile est un écran partagé entre tous les rôles. Le subtitle s'adapte au rôle actif |
| RM4 | **Switch de rôle fonctionnel** | Un utilisateur multi-rôle peut basculer entre Locataire / Démarcheur / Propriétaire via `ProfileRoleSwitcher` → `RoleHomeRouter` |
| RM5 | **Tunnel "Nouvelle demande" en 3 étapes** | (1) choix logement, (2) infos client, (3) confirmation — pattern identique au tunnel Reserve locataire |
| RM6 | **Statuts de référence** | En attente / Acceptées / Terminées / Refusées (4 chips de filtre dans Referrals) |
| RM7 | **Timeline de suivi** | Le détail d'une référence montre 5 étapes verticales (Envoyée / Vue / Acceptée / Paiement / Commission versée), étape courante en accent or |
| RM8 | **Mocks UI** | Cohérence Vague 5 : pas de branchement BLoC réel pour cette vague (mocks `SampleReferrals`, `SampleCommissions`, etc.) — branchement réel dans une vague de finition future |
| RM9 | **Onglet Messages stubé** | 4ᵉ onglet du Shell = `_MessagesPlaceholder` (cohérent avec Vague 5), reconstruction réelle en Vague 8 |
| RM10 | **Tokens uniquement** | `AppColors.*`, `AppRadii.*`, `AppTextStyles.*` — pas de couleur ni size magique |

## 5. Cas d'Usage Principal

**Préconditions :** utilisateur connecté avec `user.type == 'demarcheur'`.

**Scénario nominal :**
1. Splash → Auth → `RoleHomeRouter` redirige vers `DemarcheurShell` (5 onglets)
2. **Onglet Accueil** → `DemarcheurDashboard` : wallet hero + stats + clients référés + logements à pousser
3. **Onglet Demandes** → `DemarcheurReferralsScreen` : chips de filtre + liste de `ReferralRow` + bouton "Nouvelle"
4. Tap "Nouvelle" → `DemarcheurNew` étape 1 (choix logement) → étape 2 (infos client) → étape 3 (confirmation avec REF + commission)
5. Tap sur une référence existante → `DemarcheurReferralDetail` : timeline 5 étapes + cards listing/client/proprio + commission
6. **Onglet Gains** → `DemarcheurWalletScreen` : solde card bleu-nuit + historique transactions
7. **Onglet Messages** → `_MessagesPlaceholder` (stub Vague 8)
8. **Onglet Profil** → `ClientProfileScreen` (transverse) avec subtitle "Démarcheur · Top démarcheur" + Role Switcher fonctionnel

**Cas multi-rôle :**
9. Démarcheur tap "Locataire" dans le Role Switcher → `RoleHomeRouter` push `LocataireShell` (avec navigation propre, pas de stack pollué)
10. Locataire tap "Démarcheur" → `RoleHomeRouter` push `DemarcheurShell`

**Postconditions :**
- Shell démarcheur fonctionnel sur 5 onglets
- Switch de rôle fonctionnel entre tous les Shells construits
- 0 erreur `flutter analyze`
- Tous les écrans suivent le prototype au pixel-near (à 5% près)

## 6. Cas Alternatifs / Limites

| Cas | Comportement |
|---|---|
| CA1 | Utilisateur sans rôle Propriétaire essaie de switcher vers Propriétaire | Le Role Switcher affiche les 3 rôles mais le switch vers Proprio aboutit toujours sur `_RolePlaceholderShell('Vague 7')` jusqu'à livraison Vague 7 |
| CA2 | Démarcheur sans aucune référence (liste vide) | Empty state cohérent avec le langage Asfar (illustration + texte + CTA "Créer une demande") |
| CA3 | Logement à pousser inexistant (mocks vides) | Empty state inline dans la section "Logements à pousser" |
| CA4 | Tunnel New interrompu (back/dismiss) | Aucun draft sauvegardé (mocks), l'utilisateur recommence à zéro la prochaine fois |

## 7. Gestion des Erreurs

| Erreur | Comportement |
|---|---|
| E1 | Mock incohérent (référence pointe sur listing inexistant) | Fallback gracieux (img placeholder, "Logement supprimé") — pas de crash |
| E2 | Validation step 2 (infos client) : champ obligatoire vide | Inline error sous le champ + CTA "Suivant" désactivé |
| E3 | Switch de rôle pendant que des données sont en cours de chargement | `RoleHomeRouter` reset tout le stack avec `pushAndRemoveAll` — pas de fuite d'état |

## 8. Contraintes

- **Performance :** rendu fluide low-end Android (carrousels horizontaux pas trop chargés, listes virtualisées si > 20 items)
- **Accessibilité :** contrastes WCAG AA, surtout les `t-small` sur les hero cards à gradient
- **Plateformes :** iOS 13+, Android 10+
- **10 règles Flutter du projet** : NON NÉGOCIABLES (1 widget = 1 fichier, pas de fonction privée → Widget, etc.)
- **Réutilisation maximale** des atomes/molécules Vagues 1-5 (BlurContainer, BadgeStatus, ListRow, FieldRow, FeaturedListingCard, etc.)
- **SOLID nouveau code** : nouveaux widgets respectent la séparation rôles

## 9. Critères d'Acceptation

- [ ] **CA-1.** `DemarcheurShell` fonctionnel sur 5 onglets avec `IndexedStack` (préservation d'état) + `BottomNav` Vague 2
- [ ] **CA-2.** Les 5 écrans démarcheur du proto sont implémentés au pixel-near (≤ 5% d'écart paddings/sizes)
- [ ] **CA-3.** Tunnel `DemarcheurNew` fonctionnel sur 3 étapes avec navigation back/forward + state preservé entre steps
- [ ] **CA-4.** Profile promu en `ClientProfileScreen` transverse — subtitle adapté au rôle, réutilisé par `LocataireShell` et `DemarcheurShell`
- [ ] **CA-5.** `ProfileRoleSwitcher.onSwitchRole` branché → `RoleHomeRouter` reset le shell
- [ ] **CA-6.** `RoleHomeRouter.shellFor` retourne `DemarcheurShell` pour `case 'demarcheur'`
- [ ] **CA-7.** Onglet Messages = `_MessagesPlaceholder` (cohérence Vague 5)
- [ ] **CA-8.** Données via `SampleReferrals` / `SampleCommissions` / `SampleListingsToReferral` (pattern Vague 5 `SampleListings`)
- [ ] **CA-9.** `flutter analyze` 0 erreur, 0 warning
- [ ] **CA-10.** Score audit ≥ 60 sur les 6 dimensions
- [ ] **CA-11.** `RECONSTRUCTION_UI_ASFAR.md` Vague 6 entièrement cochée + journal des décisions mis à jour
- [ ] **CA-12.** Documentation HTML `vague-6-demarcheur.html` générée et indexée

## 10. Hors Périmètre

- ❌ Branchement BLoC réel (`DemarcheurBloc`, `PartenariatBloc`, `ReservationBloc`) → vague de finition future
- ❌ Reconstruction de l'onglet Messages (Vague 8)
- ❌ Reconstruction du Shell Propriétaire (Vague 7)
- ❌ Modification du backend / API / models
- ❌ Refactoring des BLoCs existants (règle SOLID nouveau code uniquement)
- ❌ Wizard appartement (F2 — Vague 9)

---

## 11. Décisions actées (questions BA)

| Q | Décision |
|---|---|
| Q1 — Onglet Messages | **Placeholder stubé** (cohérent avec `_MessagesPlaceholder` Vague 5) |
| Q2 — Profile démarcheur | **Profile transverse partagé** : refactor `LocataireProfileScreen` → `ClientProfileScreen`, réutilisé dans tous les Shells. Justification utilisateur : « un demarcheur peut avoir une interface de locataire pareil pour un proprietaire » |
| Q3 — Données | **Mocks** (cohérence Vague 5 — pattern `SampleListings`) |

---

## 12. Inventaire des livrables Vague 6

### Écrans nouveaux
| # | Écran | Fichier cible | Source proto |
|---|---|---|---|
| 6.1 | Dashboard | `lib/screen/client/demarcheur/home/dashboard_screen.dart` | `DemarcheurDashboard` |
| 6.2 | Referrals (liste filtrée) | `lib/screen/client/demarcheur/reservations/referrals_screen.dart` | `DemarcheurReferrals` (app.jsx) |
| 6.3 | New étape 1 (Logement) | `lib/screen/client/demarcheur/reservations/new_step1_screen.dart` | `DemarcheurNew` |
| 6.4 | New étape 2 (Client) | `lib/screen/client/demarcheur/reservations/new_step2_screen.dart` | `DemarcheurNew` |
| 6.5 | New étape 3 (Confirm) | `lib/screen/client/demarcheur/reservations/new_step3_screen.dart` | `DemarcheurNew` |
| 6.6 | Referral Detail | `lib/screen/client/demarcheur/reservations/referral_detail_screen.dart` | `DemarcheurReferralDetail` |
| 6.7 | Wallet | `lib/screen/client/demarcheur/wallet/wallet_screen.dart` | `DemarcheurWallet` |
| 6.8 | Shell + 5 tabs | `lib/screen/client/demarcheur/demarcheur_shell.dart` | `app.jsx` |

### Refactor (Profile transverse)
| # | Action | Fichier | Note |
|---|---|---|---|
| R1 | Promouvoir `LocataireProfileScreen` → `ClientProfileScreen` | déplacer vers `lib/screen/client/shared/profile/client_profile_screen.dart` | subtitle adapté au rôle |
| R2 | Mettre à jour `LocataireShell` pour utiliser `ClientProfileScreen` | `locataire_shell.dart` | sans rupture |
| R3 | Brancher `ProfileRoleSwitcher.onSwitchRole` | `client_profile_screen.dart` | dispatch via `RoleHomeRouter` |
| R4 | Compléter `RoleHomeRouter.shellFor` pour démarcheur | `role_home_router.dart` | retourner `DemarcheurShell` |

### Mocks
| # | Mock | Fichier |
|---|---|---|
| M1 | `SampleReferrals` (clients référés) | `lib/screen/client/demarcheur/sample_referrals.dart` |
| M2 | `SampleCommissions` (transactions wallet) | `lib/screen/client/demarcheur/sample_commissions.dart` |
| M3 | `SampleListingsToReferral` (logements à pousser) | `lib/screen/client/demarcheur/sample_listings_to_referral.dart` |

---

## ✅ Validation BA

- [x] Objectif clair (3 axes : écrans démarcheur + Profile transverse + switch fonctionnel)
- [x] Règles métier listées (RM1-RM10)
- [x] Cas d'usage nominal + multi-rôle décrit
- [x] Cas alternatifs/limites identifiés (CA1-CA4)
- [x] Erreurs identifiées (E1-E3)
- [x] Critères d'acceptation définis (CA-1 à CA-12)
- [x] Hors périmètre clarifié
- [x] Inventaire des livrables explicite (8 écrans + 4 refactors + 3 mocks)

**Statut :** spécification validée → transmission à 🏗️ Architecture
