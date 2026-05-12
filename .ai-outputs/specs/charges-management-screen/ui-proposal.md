# 🎨 Design UI Validé : Gestion des Charges

> **Feature :** `charges-management-screen`
> **Date :** 2026-05-12
> **Statut :** ✅ Validée par utilisateur (4 choix recommandés)

---

## 1. Décisions validées

| Aspect | Décision |
|--------|----------|
| **Layout liste** | Cards séparées (gap 12) avec icône type + titre + montant + statut |
| **Hero détail** | Sobre — card `bgElev1` avec icône type + libellé + badge (PAS de gradient or réservé aux revenus) |
| **Swipe action** | Fond vert success pour « Marquer payée » / fond gris neutre pour « Marquer impayée » (si déjà payée) |
| **CTA Finances** | Card alerte intelligente : affichage dynamique selon retards (`X charges en retard / Y FCFA`) ou sobre si rien d'urgent |

---

## 2. Écran 1 : `ChargesListScreen`

### Layout général

```
Scaffold backgroundColor: background
├── DynamicAppBar(title: 'Mes charges', leading: IconBoutton(arrow_back))
├── SafeArea top:false
│   └── Column
│       ├── ChargeFilterBar(padding 18 horizontal, 12 vertical)
│       │   ├── ChargeStatutFilterChips (Toutes/Payées/Impayées/Retard)
│       │   └── Row [AppartPicker + TypePicker + PeriodPicker] (scroll horizontal)
│       ├── [if alerts] ChargeAlertsBanner (margin 18, danger tone)
│       └── Expanded(SingleChildScrollView padding(18, 8, 18, 96))
│           └── Column
│               └── [for charge in filtered] ChargeRow + SizedBox(12)
└── floatingActionButton: FAB accent or « + »
```

### `ChargeRow` (carte swipeable)

```
Dismissible(
  direction: startToEnd,
  background: Container(
    color: estPaye ? AppColors.text3 : AppColors.success,
    padding: EdgeInsets.only(left: 24),
    alignment: centerLeft,
    child: Row [Icon(check_circle) + Text(action label)],
  ),
  confirmDismiss: () async {
    // Dispatcher MarkChargeAsPaid ou inverse
    // Retourner false pour laisser le BLoC piloter le re-render
    return false;
  },
  child: Container bgElev1 + border line + radius md + padding 14
    Row [
      _IconChargeBadge(typeCharge, size: 40),  ← cercle accentSoft + icon accent
      SizedBox(12),
      Expanded(Column [
        Row [Text titre h3, Spacer, Text montant mono bold accent],
        SizedBox(4),
        Text appartementNom small text3,
        SizedBox(6),
        Row [BadgeStatus(status), SizedBox(8), Text dateEcheance small text2],
      ]),
    ]
)
```

### `ChargeAlertsBanner`
```
Container padding 14 + radius lg + dangerSoft bg + border danger 30%
  Row [
    Icon(warning_amber, danger),
    SizedBox(10),
    Expanded(Column [
      Text 'X charges en retard' (h3 danger),
      Text 'XX FCFA à régler' (small text2),
    ]),
    Icon(chevron_right, danger),
  ]
```

### `ChargeFilterBar` détail

- **`ChargeStatutFilterChips`** : `AsfarChip(active: ...)` × 4 (Toutes, Payées, Impayées, En retard) en SingleChildScrollView horizontal
- **Pickers Appartement / Type / Période** : `InputField`-style avec `leadingIcon` + `readOnly` + `onTap` → bottom sheet

---

## 3. Écran 2 : `ChargeDetailScreen`

### Layout

```
Scaffold
├── DynamicAppBar(title: 'Détail charge', leading: back)
├── SafeArea
│   └── SingleChildScrollView padding(18, 18, 18, 96)
│       └── Column [
│           ChargeDetailHeader,                   ← icône + libellé + badge
│           SizedBox(24),
│           SectionWithEyebrow('MONTANT')         ← (réutilise ReservationSectionWithEyebrow)
│              → ChargeDetailMontantCard,
│           SizedBox(24),
│           SectionWithEyebrow('LOGEMENT')
│              → ChargeDetailAppartCard cliquable,
│           SizedBox(24),
│           SectionWithEyebrow('DATES')
│              → ChargeDetailDatesSection (clé/val),
│           [if notes] SizedBox(24)
│              SectionWithEyebrow('NOTES') + Container,
│           SizedBox(24),
│           SectionWithEyebrow('INFORMATIONS')
│              → ChargeDetailMetaSection (créée le / mise à jour le),
│       ]
└── bottomNavigationBar: ChargeDetailActionsBar (sticky)
```

### `ChargeDetailHeader`
```
Container bgElev1 + border line + radius md + padding 18
  Row [
    Container 48×48 accentSoft circle Icon(typeCharge.icon, 24, accent),
    SizedBox(14),
    Expanded(Column [
      Text libelleComplet h2,
      SizedBox(4),
      Text appartementNom small text3,
      SizedBox(8),
      BadgeStatus(chargeStatutDisplay.label, tone),
    ]),
  ]
```

### `ChargeDetailMontantCard`
```
Container bgElev1 + border line + radius md + padding 18
  Column [
    Text 'FcfaFormatter.full(montant)' mono h1 accent,
    SizedBox(4),
    Text frequence.label small text2,
  ]
```

### `ChargeDetailActionsBar`
```
Container bgElev1 + border top line + padding 18
  Row [
    Expanded(
      estPaye
        ? OutlinedCustomButton('Marquer impayée', textColor: text2)
        : CustomButton('Marquer payée', primary)
    ),
    SizedBox(10),
    IconBoutton(Icons.edit_outlined, accent, → onEdit),
    SizedBox(6),
    IconBoutton(Icons.delete_outline, danger, → confirmDelete),
  ]
```

---

## 4. Écran 3 : `ChargeFormScreen`

### Layout (création OU édition)

```
Scaffold
├── DynamicAppBar(title: initial==null ? 'Nouvelle charge' : 'Modifier la charge')
├── SafeArea
│   └── SingleChildScrollView padding(18, 18, 18, 32)
│       └── Column [
│           SectionWithEyebrow('LOGEMENT')
│              → InputField(eyebrow: 'Appartement', readOnly, onTap → AppartementPicker),
│           SizedBox(20),
│           SectionWithEyebrow('TYPE & MONTANT')
│              → Column [
│                   InputField(eyebrow: 'Type', readOnly, onTap → TypePicker),
│                   SizedBox(12),
│                   InputField(eyebrow: 'Libellé (optionnel)', maxLength: 80),
│                   SizedBox(12),
│                   InputField(eyebrow: 'Montant', keyboardType: number, suffix: 'FCFA'),
│                   SizedBox(12),
│                   InputField(eyebrow: 'Fréquence', readOnly, onTap → FrequencePicker),
│                 ],
│           SizedBox(20),
│           SectionWithEyebrow('DATES')
│              → Row [
│                   Expanded(InputField(eyebrow: 'Début', readOnly, onTap → date)),
│                   SizedBox(10),
│                   Expanded(InputField(eyebrow: 'Échéance', readOnly, onTap → date)),
│                 ],
│           SizedBox(20),
│           SwitchListTile(value: estRecurrent, title: 'Récurrente'),
│           SizedBox(8),
│           InputField(eyebrow: 'Notes (optionnel)', maxLines: 4),
│           SizedBox(28),
│           CustomButton(initial==null ? 'Créer' : 'Enregistrer', primary, block, loading),
│       ]
```

### Validation inline
- `appartementId` requis → message si vide
- `montant` > 0 → message inline
- `dateEcheance >= dateDebut` si les deux fournies
- Bouton désactivé tant que validation incomplète

---

## 5. CTA dans `ProprioFinancesScreen` (modification existante)

### Placement

Entre `BeneficeNetHeroCard` et `PnLCard`, **emplacement dédié** :

```dart
BeneficeNetHeroCard(...),
SizedBox(height: 16),
ChargesAlertCard(
  retardCount: state.chargesEnRetard.length,
  retardAmount: state.chargesEnRetard.sum(montant),
  onTap: () => pushScreen(context, const ChargesListScreen()),
),
SizedBox(height: 22),
PnLCard(...),
```

### `ChargesAlertCard` (NOUVEAU widget)

```dart
class ChargesAlertCard extends StatelessWidget {
  final int retardCount;       // 0 = mode sobre
  final int retardAmount;
  final VoidCallback onTap;
}
```

**Variante avec retards (`retardCount > 0`) :**
```
Container InkWell + bgElev1 + border danger 30% + radius lg + padding 14
  Row [
    Icon(warning_amber, 22, danger),
    SizedBox(12),
    Expanded(Column [
      Text '$retardCount charges en retard' h3 danger,
      Text '$amount FCFA à régler' mono small text2,
    ]),
    Icon(chevron_right, 18, danger),
  ]
```

**Variante sobre (`retardCount == 0`) :**
```
Container InkWell + bgElev1 + border line + radius lg + padding 14
  Row [
    Icon(receipt_long_outlined, 20, accent),
    SizedBox(12),
    Expanded(Text 'Gérer mes charges' body fontWeight w600),
    Icon(chevron_right, 18, text3),
  ]
```

---

## 6. Composants à créer (récap final)

### Nouveau widget atomique transverse
- **`ChargesAlertCard`** *(placement final : `widget/finance/charges_alert_card.dart` car réutilisable potentiel ailleurs)* — sinon dans le dossier feature

### Widgets dans `widget/` feature
Tous dans `lib/screen/client/proprio/comptabilite/charges/widget/` :
- `ChargeRow` + sous-widget `_IconChargeBadge`
- `ChargeFilterBar`
- `ChargeStatutFilterChips`
- `ChargeAppartementPicker` (bottom sheet)
- `ChargeTypePicker` (bottom sheet)
- `ChargeFrequencePicker` (bottom sheet)
- `ChargePeriodPicker` (mois/année)
- `ChargeAlertsBanner` (banner liste)
- `ChargesEmptyView` (empty state)
- `ChargesLoadingView` (skeleton)
- `ChargeDetailHeader`
- `ChargeDetailMontantCard`
- `ChargeDetailAppartCard`
- `ChargeDetailDatesSection`
- `ChargeDetailMetaSection`
- `ChargeDetailActionsBar`

### Composants à réutiliser (zéro nouveau atomique générique)
- `DynamicAppBar` · `IconBoutton` · `BadgeStatus` · `BadgeTone` · `AsfarChip`
- `CustomButton` · `OutlinedCustomButton`
- `InputField` · `EmptyState.hero/inline/error` · `InfoBanner`
- `ReservationSectionWithEyebrow` *(à renommer en `SectionWithEyebrow` générique OU dupliquer)*
- `ImgPlaceholder`
- `FcfaFormatter.full` / `.compact`

---

## 7. Contraintes visuelles strictes

### Couleurs (`AppColors` uniquement)
- Cards : `bgElev1` + `border line`
- Statut payée : `BadgeTone.success` / icone `check_circle`
- Statut en retard : `BadgeTone.danger` / icone `warning_amber`
- Statut échéance proche : `BadgeTone.warn` / icone `schedule`
- Statut impayée : `BadgeTone.neutral` / icone `pending`
- Montants : couleur `accent` (or) si à payer, `text2` si payé
- Icône type charge : fond `accentSoft` + couleur `accent`

### Typo
- Libellé charge : `h3`
- Montant : `mono(h2)` ou `mono(h1)` selon contexte (liste vs détail)
- Métadonnées (dates, appart) : `small text3`
- Eyebrows : `AppTextStyles.eyebrow`

### Espacement
- Cards liste : gap 12px
- Sections détail : gap 24px
- Padding interne card : 14-18px
- Padding global horizontal : 18px

### Mode swipe
- Direction : `DismissDirection.startToEnd` uniquement (gauche → droite)
- Pas de swipe inverse (suppression) — réservé au menu détail
- Background : success si non-payée, neutral si déjà payée
- Threshold : 0.4 (swipe modéré requis)

---

## 8. États visuels couverts

| État | Rendu |
|------|-------|
| Loading initial | `ChargesLoadingView` (skeleton structuré comme la liste) |
| Loaded vide | `ChargesEmptyView` avec CTA « Ajouter une charge » |
| Loaded avec retards | Banner + liste |
| Loaded sans retards | Liste seule |
| Action en cours (swipe) | Optimistic UI : bouton bloqué pendant l'API |
| Action success | Toast + auto-refresh liste |
| Erreur réseau | Banner d'erreur + bouton Réessayer |
| Aucun appartement (cas extrême création) | EmptyState.hero avec CTA vers créer un appart |

---

## 9. Notes d'implémentation pour le dev

- **`SectionWithEyebrow`** : décision implémentation — renommer le widget existant `ReservationSectionWithEyebrow` en générique `SectionWithEyebrow` (déplacer dans `lib/widget/`) ou créer une copie dans le dossier charges. Si déplacement → mettre à jour les imports dans `reservation_detail_screen.dart`.
- **`ChargesAlertCard` placement** : si réutilisable ailleurs un jour, placer dans `lib/widget/finance/`. Sinon dans le dossier charges.
- **Bottom sheets pickers** : suivre le pattern de `ExportBottomSheet` du finances (drag handle + padding + actions).
- **Dismissible `confirmDismiss`** : retourner `false` toujours pour empêcher le retrait visuel — le BLoC pilote le re-render via `LoadCharges` auto.
- **Liberté d'arbitrage dev** : si le pattern `SectionWithEyebrow` est trop verbose pour quelque chose de simple (ex. "Notes" ne contenant qu'un texte), inline est acceptable. KISS prévaut.
