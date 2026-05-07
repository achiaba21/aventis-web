# 🎨 Propositions UI/UX Révisées : Calendrier Intelligent d'Occupation

**Date :** 2026-02-12
**Agent :** UI/UX
**Statut :** En validation (Version 2 - Révisée)

---

## 🎯 Vision Utilisateur

### Pour le Locataire 🏠
- **Intégration dans SejourSelector/DateItem existant**
- Quand le locataire clique sur `DateItem` (mode non `readOnly`)
- → Afficher le **calendrier d'occupation** au lieu du date picker simple
- Le calendrier montre les périodes occupées (bandes de couleur)
- Le locataire peut sélectionner des dates **non occupées**

### Pour le Propriétaire 🏢
- **Icône calendrier** dans les détails de l'appartement OU résidence
- Clic sur l'icône → Ouvre le **calendrier d'occupation** (modal/bottom sheet)
- **Mode appartement** : Vue 1 seul appartement
- **Mode résidence** : Vue multi-appartements avec légende
- Possibilité de cliquer sur une période pour voir détails

---

## 📊 Analyse Existant

### DateItem Widget (Locataire)

**Fichier :** `lib/widget/date/date_item.dart`

**Fonctionnement actuel :**
```dart
GestureDetector(
  onTap: widget.readOnly ? null : _selectDates,
  // ...
)

Future<void> _selectDates() async {
  final result = await dateRangePicker(context);  // ← Date picker simple
  if (result != null) {
    plage = result;
    widget.onSelectRange!(plage);
  }
}
```

**États :**
- `readOnly = false` : Cliquable, ouvre date picker
- `readOnly = true` : Non cliquable (grisé)
- État vide : "Quand partez-vous ?"
- État rempli : "Arrivée → Départ" + badge nuits

### ProprioAppartDetailScreen (Propriétaire)

**Fichier :** `lib/screen/client/proprio/appartements/proprio_appart_detail_screen.dart`

**Structure :**
```
Scaffold
└── SafeArea
    └── SingleChildScrollView
        └── Column
            ├── AppartDetailHeader  ← 🎯 Zone icône calendrier
            └── AppartDetailContent
```

---

## 💡 Proposition Révisée Unique

---

## ✅ Solution Intégrée : Calendrier dans DateItem + Icône Proprio

### 🏠 Partie 1 : Locataire - Calendrier dans DateItem

**Modification du comportement de `DateItem` :**

#### Ancien Flow :
```
Clic sur DateItem
    ↓
dateRangePicker() (simple date picker)
    ↓
Retour DateTimeRange
```

#### Nouveau Flow :
```
Clic sur DateItem
    ↓
OccupationCalendarPicker() (calendrier avec occupation)
    ↓
- Affiche calendrier mensuel
- Charge périodes occupées (bandes orange)
- Utilisateur sélectionne début + fin
- Empêche sélection dates occupées
    ↓
Retour DateTimeRange
```

#### Maquette Visuelle :

**État initial (DateItem) :**
```
┌─────────────────────────────────────────┐
│ 📅  Quand partez-vous ?                 │
│     Appuyez pour sélectionner vos dates │ ← Clic ici
└─────────────────────────────────────────┘
```

**Après clic → Dialog (Centre écran) :**
```
        ┌─────────────────────────────────┐
        │ Sélectionnez vos dates    [X]   │
        ├─────────────────────────────────┤
        │                                 │
        │    < Février 2026 >             │
        │                                 │
        │  L   M   M   J   V   S   D      │
        │ ───────────────────────────     │
        │       1   2   3   4   5   6   7 │
        │      ▁▁  ▁▁      ▁▁  (occupé)  │
        │  8   9  10  11  12  13  14      │
        │ ▁▁▁ ●●● ●●●          (sélect.)  │
        │ 15  16  17  18  19  20  21      │
        │                 ▁▁▁▁            │
        │ 22  23  24  25  26  27  28      │
        │                                 │
        ├─────────────────────────────────┤
        │ 💡 Les dates colorées sont      │
        │    occupées                     │
        │                                 │
        │ Arrivée: 9 fév → Départ: 10 fév │
        │                                 │
        │   [Annuler]      [Confirmer]    │
        └─────────────────────────────────┘

Légende :
▁ = Période occupée (bande orange)
● = Date sélectionnée par l'utilisateur (fond bleu)
```

#### Modification Code DateItem :

**Avant (ligne 216-225) :**
```dart
Future<void> _selectDates() async {
  if (widget.onSelectRange != null) {
    final result = await dateRangePicker(context);
    if (result != null) {
      plage = result;
      widget.onSelectRange!(plage);
      setState(() {});
    }
  }
}
```

**Après :**
```dart
Future<void> _selectDates() async {
  if (widget.onSelectRange != null) {
    // 🆕 Ouvrir le calendrier d'occupation au lieu du picker simple
    final result = await showOccupationCalendarPicker(
      context: context,
      appartementId: widget.appartementId,  // 🆕 Nouveau paramètre requis
      initialRange: plage,
    );

    if (result != null) {
      plage = result;
      widget.onSelectRange!(plage);
      setState(() {});
    }
  }
}
```

#### Nouveau Widget à Créer :

**Fichier :** `lib/util/dialog/occupation_calendar_picker.dart`

```dart
/// Affiche un dialog avec calendrier d'occupation pour sélection de dates
Future<DateTimeRange?> showOccupationCalendarPicker({
  required BuildContext context,
  required int appartementId,
  DateTimeRange? initialRange,
}) async {
  return showDialog<DateTimeRange>(
    context: context,
    builder: (context) => OccupationCalendarPickerDialog(
      appartementId: appartementId,
      initialRange: initialRange,
    ),
  );
}
```

**Widget Dialog :**
```dart
class OccupationCalendarPickerDialog extends StatefulWidget {
  final int appartementId;
  final DateTimeRange? initialRange;
  // ...
}
```

**Comportement :**
- Affiche `OccupationCalendar` en mode sélection
- Bloque sélection sur dates occupées
- Permet sélection plage (début → fin)
- Boutons Annuler / Confirmer
- Retourne `DateTimeRange?`

---

### 🏢 Partie 2 : Propriétaire - Icône Calendrier

#### Option A : Icône dans Header Appartement (RECOMMANDÉE)

**Fichier :** `lib/widget/detail_appart/appart_detail_header.dart` (ou créer si n'existe pas)

**Position :**
```
┌─────────────────────────────────────────┐
│ ←  [Titre Appartement]       📆  ⭐     │ 🆕 Icône calendrier
├─────────────────────────────────────────┤
│                                         │
│ 📸 Image Carousel                       │
│                                         │
└─────────────────────────────────────────┘
```

**Code :**
```dart
// Dans AppartDetailHeader
Row(
  children: [
    IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: onBack,
    ),
    Expanded(child: TextSeed(appartement.name)),

    // 🆕 Icône calendrier
    IconButton(
      icon: Icon(Icons.calendar_month, color: Style.primaryColor),
      tooltip: "Calendrier d'occupation",
      onPressed: () => _showOccupationCalendar(context),
    ),

    if (showFavoriteButton)
      IconButton(...), // Favori existant
  ],
)
```

**Action au clic :**
```dart
void _showOccupationCalendar(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => OccupationCalendarDialog(
      mode: OccupationCalendarMode.apartment,
      appartementId: appartement.id,
      isInteractive: true, // Proprio peut cliquer
      onPeriodTap: (reservationId) {
        // Naviguer vers détails réservation
        Navigator.pop(context);
        Navigator.push(...);
      },
    ),
  );
}
```

**Dialog (Centre écran) :**
```
        ┌─────────────────────────────────┐
        │ Calendrier - Appt A1       [X]  │
        ├─────────────────────────────────┤
        │                                 │
        │    < Février 2026 >             │
        │                                 │
        │  L   M   M   J   V   S   D      │
        │ ───────────────────────────     │
        │       1   2   3   4   5   6   7 │
        │      ▁▁  ▁▁      ▁▁  (orange)  │
        │  8   9  10  11  12  13  14      │
        │ ▁▁▁▁▁                           │
        │ 15  16  17  18  19  20  21      │
        │                 ▁▁▁▁            │
        │ 22  23  24  25  26  27  28      │
        │                                 │
        ├─────────────────────────────────┤
        │ 💡 Cliquez sur un jour pour     │
        │    voir les détails             │
        └─────────────────────────────────┘

---

#### Option B : Icône dans Header Résidence

**Fichier :** `lib/screen/client/proprio/residences/residence_detail_screen.dart`

**Position :**
```
┌─────────────────────────────────────────┐
│ AppBar: Détail résidence           📆   │ 🆕 Icône dans AppBar
├─────────────────────────────────────────┤
│ ResidenceInfoSection                    │
│ Localisation                            │
│ Map                                     │
│ Appartements                            │
└─────────────────────────────────────────┘
```

**Code :**
```dart
AppBar(
  title: TextSeed("Détail résidence"),
  actions: [
    // 🆕 Icône calendrier
    IconButton(
      icon: Icon(Icons.calendar_month, color: Style.primaryColor),
      tooltip: "Calendrier d'occupation",
      onPressed: () => _showOccupationCalendar(context, residence),
    ),
  ],
)
```

**Dialog Mode Résidence :**
```
        ┌─────────────────────────────────┐
        │ Résidence Les Palmiers     [X]  │
        ├─────────────────────────────────┤
        │                                 │
        │    < Février 2026 >             │
        │                                 │
        │  L   M   M   J   V   S   D      │
        │ ───────────────────────────     │
        │       1   2   3   4   5   6   7 │
        │      ▁▁  ▁▁      ▁▁  (multi)   │
        │      🔴  🔵      🟢             │
        │  8   9  10  11  12  13  14      │
        │ ▁▁▁▁▁▁▁▁                        │
        │ 🔴🔵                             │
        │ 15  16  17  18  19  20  21      │
        │                 ▁▁▁▁            │
        │                 🔵              │
        │ 22  23  24  25  26  27  28      │
        │                                 │
        ├─────────────────────────────────┤
        │ Légende:                        │
        │ ▁ A1 (🔴) ▁ A2 (🔵) ▁ A3 (🟢)  │
        │                                 │
        │ 💡 Cliquez sur un jour pour     │
        │    voir les réservations        │
        └─────────────────────────────────┘

---

## 📋 Composants à Créer/Modifier

### Fichiers à Créer :

```
lib/
├── util/
│   └── dialog/
│       └── occupation_calendar_picker.dart   # 🆕 Picker pour locataire
│
└── widget/
    └── calendar/
        ├── occupation_calendar.dart           # 🆕 Widget calendrier (déjà prévu)
        ├── occupation_calendar_picker_dialog.dart  # 🆕 Dialog sélection
        └── occupation_calendar_dialog.dart     # 🆕 Dialog visualisation (proprio)
```

### Fichiers à Modifier :

| Fichier | Modification |
|---------|--------------|
| `lib/widget/date/date_item.dart` | Remplacer `dateRangePicker()` par `showOccupationCalendarPicker()` |
| `lib/widget/date/date_item.dart` | Ajouter paramètre `int? appartementId` |
| `lib/screen/client/locataire/home/widget/sejour_selector.dart` | Passer `appartementId` à `DateItem` |
| `lib/widget/detail_appart/appart_detail_header.dart` | Ajouter icône calendrier + action |
| `lib/screen/client/proprio/residences/residence_detail_screen.dart` | Ajouter icône calendrier dans AppBar |

---

## 🎨 Design Patterns

### Couleurs

**Locataire (Sélection) :**
- **Dates occupées** : Bande orange `#FFA02A` (non cliquables)
- **Dates sélectionnées** : Fond bleu clair `#448AFF` (cliquables)
- **Dates disponibles** : Transparent/blanc (cliquables)
- **Dates passées** : Grisées `#757575` (non cliquables)

**Propriétaire (Visualisation) :**
- **Bandes multi-couleurs** : Couleurs aléatoires persistantes
- **Légende** : Affichage couleur + nom appartement
- **Interaction** : Toutes dates occupées cliquables

### Espacements

- Padding modal : `Espacement.paddingBloc` (16px)
- Gap sections : `Espacement.gapSection` (12px)
- Border radius : `Espacement.radius` (8px)

---

## 🔄 Flux UX Complet

### Locataire - Réserver un Appartement

```
1. Locataire sur AppartDetailScreen
2. Voit SejourSelector (DateItem vide)
3. Clique sur "Quand partez-vous ?"
    ↓
4. Dialog s'ouvre au centre de l'écran avec calendrier d'occupation
5. Voit les périodes occupées (bandes orange)
6. Sélectionne dates disponibles (ex: 9-10 fév)
    - Si clic sur date occupée → Vibration + message
7. Clique "Confirmer"
    ↓
8. Retour à AppartDetailScreen
9. DateItem affiche "Arrivée → Départ"
10. Peut procéder à la réservation
```

### Propriétaire - Voir Occupation Appartement

```
1. Proprio sur ProprioAppartDetailScreen
2. Voit icône 📆 dans le header
3. Clique sur icône calendrier
    ↓
4. Dialog s'ouvre au centre de l'écran avec calendrier
5. Voit périodes occupées (mode 1 appartement)
6. Clique sur jour occupé (ex: 5 février)
    ↓
7. Popup/card affiche détails réservation
8. Bouton "Voir réservation complète"
9. Navigate vers ReservationDetailScreen
```

### Propriétaire - Voir Occupation Résidence

```
1. Proprio sur ResidenceDetailScreen
2. Voit icône 📆 dans AppBar
3. Clique sur icône calendrier
    ↓
4. Dialog s'ouvre au centre de l'écran avec calendrier multi-appartements
5. Voit légende (Appt A1, A2, A3 avec couleurs)
6. Voit bandes multiples sur jours occupés
7. Clique sur jour avec plusieurs réservations
    ↓
8. Dialog secondaire liste les réservations de ce jour
9. Sélectionne une réservation
10. Navigate vers ReservationDetailScreen
```

---

## ✅ Avantages de cette Approche

### Pour Locataire :
- ✅ **Intégration naturelle** : Utilise DateItem existant
- ✅ **Visibilité immédiate** : Voit périodes occupées avant sélection
- ✅ **Prévention erreurs** : Impossible de sélectionner dates occupées
- ✅ **UX fluide** : Un seul clic pour voir + sélectionner

### Pour Propriétaire :
- ✅ **Accès rapide** : Icône toujours visible
- ✅ **Non intrusif** : N'alourdit pas l'interface
- ✅ **Flexible** : Fonctionne pour appartement ET résidence
- ✅ **Interactif** : Clic pour détails réservation

### Technique :
- ✅ **Réutilisation** : Même `OccupationCalendar` pour locataire et proprio
- ✅ **Minimal impact** : Modification légère de DateItem
- ✅ **Cohérence** : Dialog = pattern Flutter standard
- ✅ **Testable** : Composants indépendants

---

## 🎯 Comparaison avec Propositions Initiales

| Aspect | Proposition Initiale (Section) | Proposition Révisée |
|--------|-------------------------------|---------------------|
| **Locataire** | Section calendrier dans scroll | Intégré dans DateItem (dialog) |
| **Propriétaire** | Section calendrier dans scroll | Icône → Dialog |
| **Visibilité** | ⭐⭐⭐ Toujours visible | ⭐⭐ Visible via icône/DateItem |
| **UX** | ⭐⭐ Scroll requis | ⭐⭐⭐ 1 clic, focus total |
| **Pollution visuelle** | ⚠️ Augmente scroll | ✅ Aucune |
| **Sélection dates** | ❌ Pas intégré | ✅ Intégré naturellement |

---

## 📝 Checklist Validation

- [x] Intégration dans DateItem existant (locataire)
- [x] Icône calendrier dans header (propriétaire)
- [x] Mode appartement + résidence
- [x] Bandes de couleur fines
- [x] Sélection dates non occupées (locataire)
- [x] Clic sur période → détails (propriétaire)
- [x] Réutilise composants existants
- [x] Cohérence design (dark theme, orange)
- [x] Minimal impact sur code existant

---

**Document prêt pour validation utilisateur.**
