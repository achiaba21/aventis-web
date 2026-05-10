# 🎨 Proposition UI/UX — Vague 6 Démarcheur

> **Auteur :** Agent UI/UX (workflow `/feature full`)
> **Date :** 2026-05-10
> **Statut :** ✅ Résolu par fidélité proto (R5 du `RECONSTRUCTION_UI_ASFAR.md`)
> **Source primaire :** `~/Downloads/Asfar Prototype.html` + extraits dans `.ai-outputs/prototype-extract/*.jsx`

---

## 1. Démarche

L'archi (`architecture.md`) avait identifié 4 zones où des choix d'intégration restaient ouverts. **Avant de proposer du neuf**, j'ai vérifié que le prototype HTML/JSX ne tranchait pas déjà ces décisions. Conclusion : **3 sur 4 sont résolues par le proto lui-même**, la 4ᵉ (factoriser ou non) est tranchée par fidélité au proto.

## 2. Décisions par zone

### 2.1 Wallet card (Dashboard) vs Wallet card (Wallet screen)

**Décision : 2 widgets distincts** — `WalletHeroCard` (Dashboard) et `WalletSoldeCard` (Wallet screen).

**Justification :** le proto les implémente comme 2 blocs distincts avec des contenus structurellement différents (pas juste des params).

**Comparaison source :**

| Aspect | `WalletHeroCard` (Dashboard) | `WalletSoldeCard` (Wallet) |
|---|---|---|
| Gradient | `linear-gradient(135deg, #1A2A4A 0%, #0E1626 60%, #060A14 100%)` (3 stops) | `linear-gradient(135deg, #1A2A4A 0%, #0E1626 100%)` (2 stops) |
| Border | `1px solid rgba(94,108,255,0.25)` | identique |
| Border-radius | 22 | 22 |
| Padding | 18 | 20 |
| Halo radial bleu | ✅ position `top:-50, right:-30`, 180×180 px, `rgba(94,108,255,0.18)` | ❌ absent |
| Eyebrow | « Mes commissions ce mois » couleur `#8B9AFF` + icon `wallet` | « Solde disponible » couleur `#8B9AFF` |
| Montant | **32px** mono bold letter-spacing -1 | **36px** mono bold letter-spacing -1 |
| Sous-bloc | Mini-stats inline 3 cols (Cumul / En attente / Clients) sur fond `rgba(255,255,255,0.05)` border `rgba(255,255,255,0.08)` radius 12 | Texte info versement vendredi 12px |
| CTA intégré | ❌ | ✅ Bouton block fond `rgba(255,255,255,0.1)` border `rgba(255,255,255,0.15)` + icon download + label « Retirer maintenant » |

**Implication code :** 2 fichiers Dart distincts, comme prévu dans le contrat d'archi (§ 5.8 et § 5.10). Pas de factorisation prématurée.

### 2.2 Animation switch de rôle

**Décision : pas d'animation custom** — `pushAndRemoveAll` standard via `MaterialPageRoute`.

**Justification :** le proto (`extras.jsx:323`) appelle simplement `onSwitchRole(r.id)` qui est un `useState setter` React → re-render instantané du shell. Aucune transition, aucune confirmation.

**Implication code :** réutiliser `pushAndRemoveAll` depuis `lib/util/navigation.dart:10` tel quel. Pas de `PageRouteBuilder` custom.

### 2.3 Empty states (aucune référence / aucun client / aucune commission)

**Décision : hors Vague 6** — non implémentés dans cette vague.

**Justification :**
1. Le proto **n'a aucun empty state** sur les 8 fichiers JSX (`grep -i "empty|aucun|vide"` = 0 résultat). Toutes les listes sont remplies de mocks.
2. La spec Vague 6 RM8 impose **mocks** uniquement → les listes (`SampleReferrals`, `SampleCommissions`) sont **toujours remplies** → cas empty state non atteignable visuellement dans cette vague.
3. À traiter dans une **vague de finition** (post-Vague 9) quand les BLoCs réels seront branchés et que des listes vides deviendront possibles en prod.

**Implication code :** aucun widget `EmptyState` créé en Vague 6. Pas de fallback dans les écrans.

**TODO post-finition (à ajouter dans `RECONSTRUCTION_UI_ASFAR.md` section "Réintégrations TODO REBUILD") :**
- `EmptyState` widget générique (gradient or hero + icon + titre + body + CTA)
- Branchement dans 6 zones : DemarcheurReferralsScreen (liste vide), WalletScreen (historique vide), Dashboard "Clients référés" (aucun client), Dashboard "Logements à pousser" (aucun listing à référer), TripsScreen (équivalent côté locataire), FavoriteScreen (favoris vides)

### 2.4 CTA "Retirer maintenant"

**Décision : SnackBar stub** Vague 6 — UX retrait reportée à la vague F9 (Banque/Cartes/Compte).

**Justification :**
1. Le proto (`demarcheur.jsx:501-506`) implémente un bouton **sans handler** : `<button>...Retirer maintenant</button>` n'a pas de `onClick`. Pas de bottom sheet, pas d'écran, pas de modale dans le proto.
2. La logique de retrait dépend de la **gestion banque/cartes/compte** identifiée comme **F9 hors-proto** dans `RECONSTRUCTION_UI_ASFAR.md` ligne 240.
3. Implémenter une UX de retrait Vague 6 risquerait de la refaire en F9 quand le vrai contexte (méthodes de retrait, validation, confirmation) sera défini.

**Implication code :**
```dart
onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Retrait disponible prochainement'),
    behavior: SnackBarBehavior.floating,
  ),
),
```

**TODO F9 :** définir la UX de retrait avec spec dédiée (bottom sheet vs écran selon les besoins métier émergents).

## 3. Tous les autres écrans Vague 6

Les écrans suivent le proto **au pixel-near** comme prévu par R5 :

| Écran | Source proto | Spécificité UI |
|---|---|---|
| `DemarcheurDashboard` | `demarcheur.jsx::DemarcheurDashboard` | Voir détail § 2.1 + status pills + carrousel logements à pousser |
| `DemarcheurReferralsScreen` | `app.jsx::ReferralsScreen` | 5 chips de filtre + liste `ReferralRow` |
| `NewReferralScreen` (3 steps) | `demarcheur.jsx::DemarcheurNew` | Tunnel single screen avec `_step` (pattern Vague 5) |
| `DemarcheurReferralDetail` | `demarcheur.jsx::DemarcheurReferralDetail` | Timeline 5 étapes + cards listing/client/proprio + commission |
| `DemarcheurWalletScreen` | `demarcheur.jsx::DemarcheurWallet` | Voir détail § 2.1 (`WalletSoldeCard`) + historique |
| `ClientProfileScreen` | `extras.jsx::Profile` | Subtitle adaptatif au rôle (cf. mapping `profiles[role]` lignes 292-296) |

## 4. Mapping `profiles[role]` du proto (référence pour `ClientProfileScreen`)

D'après `extras.jsx:292-296` :

| Rôle | Nom mock | Sub | Verified | Badge |
|---|---|---|---|---|
| `locataire` | « Aïcha Camara » | « Locataire · Membre depuis 2024 » | ✅ | — |
| `proprietaire` | « Aminata Koné » | « Propriétaire · 4 biens » | ✅ | « ★ Hôte certifié » |
| `demarcheur` | « Diallo Mamadou » | « Démarcheur · 27 clients » | ✅ | « Top démarcheur » |

→ `ClientProfileScreen` doit reproduire ces 3 mappings. Le `name` réel viendra du `UserBloc`, mais le `sub` et le `badge` se calculent depuis `user.type`.

## 5. Composants à créer

Aucun ajout par rapport à l'architecture validée. Le contrat d'implémentation `architecture.md § 5` reste la source de vérité.

## 6. Composants à réutiliser

Aucun ajout par rapport à l'architecture validée (§ 1.2).

## 7. Contraintes visuelles consolidées

| Token | Usage Vague 6 |
|---|---|
| `AppColors.bgElev1` | fond cards (statut pills, listrows, settings, recap, listing summary) |
| `AppColors.line` | bordures cards |
| `AppColors.accent` (or chaud) | montants, badges accent, ronds active du timeline, halos success |
| `AppColors.accentSoft` | fond CTA "Envoyer un client" + InfoBanner commission |
| `AppColors.success` | badge accepté + montant entrée transaction |
| `AppColors.warn` | badge en attente + montant "En attente" mini-stats |
| `AppColors.info` | montant sortie transaction |
| `AppColors.danger` | bouton "Se déconnecter" + badge refusé |
| **Gradient bleu-nuit** | `[#1A2A4A, #0E1626, #060A14]` (Dashboard) ou `[#1A2A4A, #0E1626]` (Wallet) |
| **Bleu accent (mini-stats hero)** | `#8B9AFF` (eyebrow + icon) |
| `AppRadii.lg` (≈ 20-22) | cards principales |
| `AppTextStyles.h1/h2/h3/body/small/eyebrow` | typo |

> **Note importante :** les couleurs `#1A2A4A`, `#0E1626`, `#060A14`, `#8B9AFF` ne sont **pas** dans `AppColors`. À ajouter en tokens Vague 6 (`AppColors.walletBlueDark1/2/3` + `AppColors.walletBlueAccent`) — sinon contradiction avec R1 (tokens uniquement). À acter au moment du dev (Lot 1) ou immédiatement.

## 8. Points en suspens (à valider en début Lot 1)

- [ ] **Tokens couleurs bleu-nuit Wallet** : ajouter dans `lib/theme/app_colors.dart` (4 nouvelles constantes)
- [ ] **Confirmation report empty states + retrait F9** : tracer dans `RECONSTRUCTION_UI_ASFAR.md` section "Réintégrations TODO REBUILD"

---

## ✅ Validation UI/UX

- [x] Le proto a été lu directement comme source primaire
- [x] Aucune création de pattern UI/UX qui n'existe pas dans le proto
- [x] Les zones où le proto ne tranche pas sont reportées (empty states, retrait) avec justification documentée
- [x] La factorisation est rejetée car le proto fait 2 cards distinctes
- [x] Cohérence avec la règle R5 (Layout 100% prototype)
- [x] Référence claire au mapping `profiles[role]` pour `ClientProfileScreen`

**Statut :** proposition UI/UX validée → transmission à l'agent Flutter Dev pour implémentation.
