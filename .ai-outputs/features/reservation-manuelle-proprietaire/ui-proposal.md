# Analyse UI/UX - Reservation Manuelle Proprietaire

## Stack Detecte

- **Framework** : Flutter (Dart)
- **Theme** : Dark Mode
- **Design System** : Custom (Style class)
- **Widgets** : TextSeed, ImageNet, PlainButtonIcon (custom)

---

## Design System Observe

### Couleurs
| Role | Valeur | Usage |
|------|--------|-------|
| Primary | `#FFA02A` | Boutons, accents, prix |
| Background | `#1D1D1D` | Fond ecran |
| Card/Container | `#2A2A2A` | Inputs, dropdowns |
| Text | `#FFFFFF` | Titres, contenu |
| Text Muted | `Grey[400]` | Labels, hints |
| Error | `#EB4040` | Erreurs |

### Typographie
- Police : System font (via TextSeed widget)
- Titres : 15-18px, FontWeight.w600/bold
- Labels : 14px, FontWeight.w600, Grey[400]
- Corps : 13-14px, normal
- Hints : 12-13px, Grey[500]

### Espacements (Espacement class)
- `paddingBloc` : Padding general des ecrans
- `paddingInput` : Padding interne des elements
- `gapItem` : Espace entre elements
- `gapSection` : Espace entre sections
- `radius` : Border radius standard (12px)

### Composants Reutilisables (depuis ChargeFormScreen)
- `_SectionTitle` : Label de section
- `_CustomTextField` : Champ texte avec icone
- `_ResidenceDropdown` : Dropdown residence
- `_AppartementDropdownRequired` : Dropdown appartement
- `_DatePickerField` : Selecteur de date

---

## Zone d'Insertion

### Page Cible
`lib/screen/client/proprio/reservations/reservations_proprio.dart`

### Structure Actuelle
```
┌─────────────────────────────────────────┐
│ AppBar (geree par parent)               │
├─────────────────────────────────────────┤
│ BlocBuilder<ReservationBloc>            │
│ ┌─────────────────────────────────────┐ │
│ │ Row: Titre + Bouton Refresh         │ │
│ ├─────────────────────────────────────┤ │
│ │ BookingItemProprio                  │ │
│ │ BookingItemProprio                  │ │
│ │ BookingItemProprio                  │ │
│ │ ...                                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│                       [PAS DE FAB]      │
└─────────────────────────────────────────┘
```

---

## Propositions d'Integration

### Option A : Ecran Full-Screen (Recommandee)

**Description :** Nouveau formulaire en plein ecran, identique au pattern ChargeFormScreen existant.

**Placement :**
```
┌─────────────────────────────────────────┐
│ ReservationsProprio                     │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ Row: Titre + Refresh                │ │
│ ├─────────────────────────────────────┤ │
│ │ BookingItemProprio                  │ │
│ │ BookingItemProprio                  │ │
│ │ ...                                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
│                              ┌───┐      │
│                              │ + │ FAB  │
│                              └───┘      │
└─────────────────────────────────────────┘
         │
         │ Navigation push
         ▼
┌─────────────────────────────────────────┐
│ AppBar: X | Nouvelle reservation | Save │
├─────────────────────────────────────────┤
│ ┌─────────────────────────────────────┐ │
│ │ Dropdown: Appartement *             │ │
│ ├─────────────────────────────────────┤ │
│ │ DatePicker: Date debut *            │ │
│ ├─────────────────────────────────────┤ │
│ │ TextField: Duree (jours) *          │ │
│ ├─────────────────────────────────────┤ │
│ │ TextField: Nom client *             │ │
│ ├─────────────────────────────────────┤ │
│ │ TextField: Telephone *              │ │
│ ├─────────────────────────────────────┤ │
│ │ TextField: Email (optionnel)        │ │
│ ├─────────────────────────────────────┤ │
│ │ TextField: Montant (FCFA) *         │ │
│ ├─────────────────────────────────────┤ │
│ │ [====== ENREGISTRER ======]         │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Composants a reutiliser :**
- `_SectionTitle` de ChargeFormScreen
- `_CustomTextField` de ChargeFormScreen
- `_ResidenceDropdown` / `_AppartementDropdownRequired` de ChargeFormScreen
- `_DatePickerField` de ChargeFormScreen

**Avantages :**
- Coherence avec ChargeFormScreen (meme pattern)
- Plus d'espace pour les champs
- Meilleure UX mobile
- Composants deja testes

**Inconvenients :**
- Navigation supplementaire

---

### Option B : BottomSheet Modal

**Description :** Formulaire dans un BottomSheet scrollable qui s'ouvre depuis le FAB.

**Placement :**
```
┌─────────────────────────────────────────┐
│ ReservationsProprio (assombri)          │
├─────────────────────────────────────────┤
│                                         │
│                                         │
├─────────────────────────────────────────┤
│ BottomSheet                             │
│ ┌─────────────────────────────────────┐ │
│ │ Titre: Nouvelle reservation manuelle│ │
│ ├─────────────────────────────────────┤ │
│ │ [Formulaire scrollable]             │ │
│ │ - Appartement                       │ │
│ │ - Date debut                        │ │
│ │ - Duree                             │ │
│ │ - Nom client                        │ │
│ │ - Telephone                         │ │
│ │ - Email                             │ │
│ │ - Montant                           │ │
│ │ [====== ENREGISTRER ======]         │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Avantages :**
- Pas de navigation (reste sur meme page)
- Acces rapide

**Inconvenients :**
- Espace limite sur petits ecrans
- Peut etre difficile a scroller
- Moins coherent avec ChargeFormScreen

---

### Option C : Dialog/AlertDialog

**Description :** Formulaire dans une boite de dialogue centree.

**Placement :**
```
┌─────────────────────────────────────────┐
│ ReservationsProprio (assombri)          │
│                                         │
│    ┌─────────────────────────────┐      │
│    │ Nouvelle reservation        │      │
│    ├─────────────────────────────┤      │
│    │ [Formulaire compact]        │      │
│    │ - Appartement               │      │
│    │ - Date / Duree              │      │
│    │ - Client info               │      │
│    │ - Montant                   │      │
│    ├─────────────────────────────┤      │
│    │ [Annuler]  [Enregistrer]    │      │
│    └─────────────────────────────┘      │
│                                         │
└─────────────────────────────────────────┘
```

**Avantages :**
- Leger et rapide
- Pas de navigation

**Inconvenients :**
- Trop compact pour 7 champs
- Mauvaise UX sur mobile
- Pas adapte a ce cas d'usage

---

## Recommandation

**Option A : Ecran Full-Screen** est recommandee car :

1. **Coherence** : Meme pattern que ChargeFormScreen deja utilise
2. **Reutilisation** : Tous les widgets helper existent deja
3. **UX Mobile** : Espace suffisant pour 7 champs + validation
4. **Maintenabilite** : Code similaire = facile a maintenir

---

## Maquette Detaillee - Option A

### AppBar
```
┌─────────────────────────────────────────┐
│ [X]  Reservation manuelle   [Enregistrer]│
└─────────────────────────────────────────┘
  │                               │
  Close (pop)              TextButton orange
```

### Corps du Formulaire
```
┌─────────────────────────────────────────┐
│ RESIDENCE (filtre)                      │
│ ┌─────────────────────────────────────┐ │
│ │ [v] Villa Cocody                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ APPARTEMENT *                           │
│ ┌─────────────────────────────────────┐ │
│ │ [v] Studio 1 - 25000 FCFA           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ DATE DE DEBUT *                         │
│ ┌─────────────────────────────────────┐ │
│ │ [calendar] 15/01/2026               │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ DUREE (JOURS) *                         │
│ ┌─────────────────────────────────────┐ │
│ │ [timer] 3                           │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ─────── INFORMATIONS CLIENT ─────────   │
│                                         │
│ NOM DU CLIENT *                         │
│ ┌─────────────────────────────────────┐ │
│ │ [person] Kouame Jean                │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ TELEPHONE *                             │
│ ┌─────────────────────────────────────┐ │
│ │ [phone] +225 07 00 00 00 00         │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ EMAIL (OPTIONNEL)                       │
│ ┌─────────────────────────────────────┐ │
│ │ [email] client@email.com            │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ MONTANT (FCFA) *                        │
│ ┌─────────────────────────────────────┐ │
│ │ [payments] 75000                    │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │  INFO: Cette reservation sera       │ │
│ │  enregistree sans frais plateforme  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │      ENREGISTRER LA RESERVATION     │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### FAB Contextuel (dans proprio_navigation.dart)

Le FAB "+" change de comportement selon l'onglet actif :
- **Tab Reservations** → Ouvre ReservationManuelleFormScreen
- **Tab Listings** → Ouvre AddAppartementScreen (existant)

```dart
// Dans proprio_navigation.dart
FloatingActionButton(
  backgroundColor: Style.primaryColor,
  child: Icon(Icons.add, color: Colors.white),
  onPressed: () {
    if (currentTab == TabReservations) {
      pushScreen(context, ReservationManuelleFormScreen());
    } else if (currentTab == TabListings) {
      pushScreen(context, AddAppartementScreen());
    }
  },
)
```

**Option choisie : A (Full-Screen) avec FAB contextuel**

---

## Resume des Options

| Critere | Option A (Full-Screen) | Option B (BottomSheet) | Option C (Dialog) |
|---------|------------------------|------------------------|-------------------|
| Coherence design | ★★★ | ★★ | ★ |
| Espace formulaire | ★★★ | ★★ | ★ |
| UX Mobile | ★★★ | ★★ | ★ |
| Reutilisation code | ★★★ | ★★ | ★ |
| Rapidite acces | ★★ | ★★★ | ★★★ |

---

```
╔══════════════════════════════════════════════════════════════╗
║  ✋ VALIDATION UI/UX REQUISE                                  ║
╠══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Options proposees :                                          ║
║  • A : Ecran Full-Screen (Recommandee) - comme ChargeForm     ║
║  • B : BottomSheet Modal - formulaire en bas de page          ║
║  • C : Dialog centree - compact mais limite                   ║
║                                                               ║
║  Quelle option ? (A/B/C/autre)                                ║
║                                                               ║
╚══════════════════════════════════════════════════════════════╝
```
