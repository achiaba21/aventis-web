# 🎨 Spécification UI/UX - Système de Compte Propriétaire

## Option Choisie : C - Écran Compte Intégré

---

## 1. Point d'Entrée

**Fichier :** `lib/screen/client/proprio/profile/profile_proprio.dart`

**Modification :** Remplacer l'item "Payment and payouts" (ligne 82-86) par :

```dart
ProfileMenuItem(
  icon: Icons.account_balance_wallet_outlined,
  title: "Mon Compte",
  onTap: () => pushScreen(context, const CompteScreen()),
),
```

---

## 2. Écran Principal : CompteScreen

### Layout

```
┌─────────────────────────────────────────┐
│ ←  Mon Compte           N° PRO-xxx-xxx │  AppBar
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  💰 SOLDE DISPONIBLE            │    │
│  │     150 000 FCFA                │    │  SoldeCard (gradient vert)
│  │                    [Retirer →]  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌───────────────┐ ┌───────────────┐    │
│  │ 🕐 En attente │ │ 🔒 Verrouillé │    │  Row de MiniMetricCard
│  │ 25 000 FCFA   │ │ 10 000 FCFA   │    │
│  └───────────────┘ └───────────────┘    │
│                                         │
│  Transactions récentes                  │  Section titre
│  ─────────────────────────────────────  │
│  ↓ Réservation #123      +15 000 FCFA  │
│  ↑ Retrait               -50 000 FCFA  │  TransactionItem (liste)
│  ↓ Réservation #122      +20 000 FCFA  │
│                                         │
│  [Voir tout l'historique →]             │  TextButton
│                                         │
└─────────────────────────────────────────┘
```

### Composants

| Widget | Pattern réutilisé | Description |
|--------|-------------------|-------------|
| `SoldeCard` | `_BeneficeCard` | Gradient vert, solde principal + bouton retrait |
| `MiniMetricCard` | `_MetricCard` | Solde attente et montant verrouillé |
| `TransactionItem` | Nouveau | Ligne avec icône, description, montant coloré |

---

## 3. Écran Historique : HistoriqueScreen

### Layout

```
┌─────────────────────────────────────────┐
│ ←  Historique                    🔍     │  AppBar + filtre
├─────────────────────────────────────────┤
│  [Tous] [Crédits] [Débits]              │  Tabs filtre
│                                         │
│  Décembre 2024                          │  Section par mois
│  ─────────────────────────────────────  │
│  24 déc  Réservation #125  +15 000     │
│  22 déc  Retrait           -50 000     │
│  20 déc  Réservation #124  +20 000     │
│                                         │
│  Novembre 2024                          │
│  ─────────────────────────────────────  │
│  ...                                    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 4. Bottom Sheet : RetraitForm

### Layout

```
┌─────────────────────────────────────────┐
│  ─────  (handle)                        │
│                                         │
│  Demander un retrait                    │  Titre
│                                         │
│  Solde disponible : 150 000 FCFA        │  Info
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  Montant                        │    │  TextField
│  │  [___________________________]  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [Tout retirer]                         │  Chip/Button
│                                         │
│  ┌─────────────────────────────────┐    │
│  │      Confirmer le retrait       │    │  PlainButtonExpand
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

---

## 5. Design Tokens

### Couleurs spécifiques

| Usage | Couleur |
|-------|---------|
| Solde disponible (gradient) | `Colors.green.shade900` → `Colors.green.shade700` |
| Montant crédit | `Colors.green` |
| Montant débit | `Colors.red` |
| En attente | `Colors.orange` |
| Verrouillé | `Colors.grey` |
| Compte suspendu | `Colors.red` avec opacité |

### Icônes

| Usage | Icône |
|-------|-------|
| Mon Compte (menu) | `Icons.account_balance_wallet_outlined` |
| Solde disponible | `Icons.account_balance` |
| En attente | `Icons.hourglass_empty` |
| Verrouillé | `Icons.lock_outline` |
| Crédit (transaction) | `Icons.arrow_downward` (vert) |
| Débit (transaction) | `Icons.arrow_upward` (rouge) |
| Retrait | `Icons.send` |

---

## 6. États UI

### Compte actif
- Affichage normal
- Bouton retrait actif

### Compte suspendu
- Banner rouge en haut : "Compte suspendu"
- Bouton retrait désactivé (grisé)
- Soldes visibles mais actions bloquées

### Chargement
- Shimmer sur les cards
- Skeleton sur la liste transactions

### Erreur
- Message centré avec icône
- Bouton "Réessayer"

### Vide (pas de transactions)
- Illustration + message "Aucune transaction"

---

*Spécification UI validée le 2025-12-24*
