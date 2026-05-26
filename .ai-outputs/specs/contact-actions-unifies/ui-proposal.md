# 🎨 Design UI Validé — Contact Actions Unifiés

> **Option choisie : A — Conservative**
> Date : 2026-05-20
> Statut : ✅ Validée par l'utilisateur

---

## 1. Placement

### 1.1 ContactSheet (bottom sheet)

Reprise fidèle du style actuel de `reservation_contact_sheet.dart`, étendue à **3 options** au lieu de 2.

```
ContactSheet (bottom sheet)
┌─────────────────────────────────┐
│      ━━━━ (handle 40×4)         │
│                                 │
│  CONTACTER          ← eyebrow   │
│  Jean Dupont         ← h3       │
│                                 │
├─────────────────────────────────┤
│ 💬  Discuter dans Asfar      ›  │  ← icon accent or 20px
├─────────────────────────────────┤
│ 📱  WhatsApp +225 07 XX...   ›  │  ← grisé si indispo
├─────────────────────────────────┤
│ 📞  Appeler +225 07 XX...    ›  │
└─────────────────────────────────┘
```

### 1.2 ContactButton — bouton "Contacter"

Reprend exactement le pattern `OutlinedCustomButton` existant :
- Background `bgElev2`
- Border `line`
- Texte clair + icône chat à gauche
- Scale-on-press 0.97

### 1.3 CallButton — bouton "Appeler"

Deux variantes (sélectionnables) :
- **Default** : `OutlinedCustomButton(leadingIcon: phone, text: "Appeler")` — pour cards desktop-like
- **iconOnly** : `IconBoutton(icon: phone, size: 36)` — pour cards compactes (cf. `partenariat_detail_party_card.dart` actuel)

---

## 2. Composants à créer

| Fichier | Type | Description |
|---|---|---|
| `lib/widget/contact/contact_sheet.dart` | StatelessWidget | Bottom sheet (méthode statique `show()`) |
| `lib/widget/contact/contact_sheet_tile.dart` | StatelessWidget | Tile atomique (icon, label, enabled, onTap) |
| `lib/widget/contact/contact_button.dart` | StatelessWidget | Bouton "Contacter" wrappant `OutlinedCustomButton` |
| `lib/widget/contact/call_button.dart` | StatelessWidget | Bouton "Appeler" avec variantes (outlined / iconOnly) |

---

## 3. Composants à réutiliser

| Composant existant | Usage |
|---|---|
| `OutlinedCustomButton` | Backbone de `ContactButton` et `CallButton.outlined` |
| `IconBoutton` | Backbone de `CallButton.iconOnly` |
| `AppColors` (`accent`, `bgElev1`, `textDisabled`, `line`, `text3`) | Couleurs |
| `AppTextStyles` (`eyebrow`, `h3`) | Typographie |
| `AppRadii` (`lg`) | Border radius |

---

## 4. Contraintes visuelles

### 4.1 Couleurs

| Élément | Couleur | Token |
|---|---|---|
| Background sheet | `#131316` | `AppColors.bgElev1` |
| Handle | `#76767E` | `AppColors.textDim` (existant) |
| Eyebrow "CONTACTER" | text muted | `AppColors.textMuted` |
| Nom h3 | blanc cassé | `AppColors.text` |
| Icône tile **active** | or chaud `#E8B86B` | `AppColors.accent` |
| Label tile **actif** | clair | `AppColors.text` |
| Chevron `›` actif | gris clair | `AppColors.text3` |
| Icône tile **désactivée** | `#4A4A52` | `AppColors.textDisabled` |
| Label tile **désactivé** | `#4A4A52` | `AppColors.textDisabled` |
| Chevron **désactivé** | masqué (visibility: false) | — |
| Séparateurs tiles | line subtil 1px | `AppColors.line` |

### 4.2 Espacements

| Élément | Valeur |
|---|---|
| Handle margin top/bottom | 10 / 14 |
| Padding horizontal sheet content | 20 |
| Tile padding | horizontal 20, vertical 14 |
| Bottom padding sheet | `mq.padding.bottom` (safe area) |
| Spacing entre eyebrow / nom | 6 |
| Spacing entre header / 1ère tile | 16 |

### 4.3 Typographie

- **Eyebrow "CONTACTER"** : `AppTextStyles.eyebrow` (uppercase, letter-spacing)
- **Nom destinataire** : `AppTextStyles.h3`
- **Label tile** : `fontSize: 15, color: AppColors.text` (active) ou `AppColors.textDisabled` (inactive)

### 4.4 Iconographie

| Action | Icon (Material) |
|---|---|
| Chat | `Icons.chat_bubble_outline` |
| WhatsApp | `Icons.whatshot_outlined` (ou Material `Icons.message` + override commentaire) |
| Appeler | `Icons.phone_outlined` |
| Chevron | `Icons.arrow_forward_ios` (size 12) |

**Note WhatsApp** : pas d'icône Material native pour WhatsApp. Options :
- Utiliser `Icons.chat_outlined` (proche)
- Utiliser un SVG depuis `assets/` (vérifier disponibilité)
- Décision : démarrer avec `Icons.chat_outlined` puis remplacer par SVG si dispo

### 4.5 États des tiles

| État | Visuel |
|---|---|
| **Active** | Icône accent or, label `text`, chevron visible, `InkWell` actif |
| **Disabled** | Icône `textDisabled`, label `textDisabled`, chevron masqué, `onTap: null` (pas de tap feedback) |

### 4.6 Format label

| Action | Texte affiché |
|---|---|
| Chat | `"Discuter dans Asfar"` |
| WhatsApp | `"WhatsApp ${phone}"` ou `"WhatsApp"` (si phone vide → grisé) |
| Appeler | `"Appeler ${phone}"` ou `"Appeler"` (si phone vide → grisé) |

---

## 5. Variantes des boutons

### 5.1 `ContactButton`

```dart
ContactButton(
  contact: contact,
  availability: availability,
  label: 'Contacter',           // optionnel, défaut "Contacter"
)
```

Affichage : `OutlinedCustomButton` avec `leadingIcon: Icons.chat_bubble_outline`. Désactivé si `availability.contactButtonEnabled == false`.

### 5.2 `CallButton`

```dart
// Default — outlined avec texte
CallButton(phone: '+225...', enabled: true)

// IconOnly — pour cards compactes
CallButton(phone: '+225...', enabled: true, variant: CallButtonVariant.iconOnly)
```

Désactivé si `phone` vide/null ou `enabled: false`.

---

## 6. Comportement (rappel BA)

- **Sheet toujours affichée**, même si 1 seule option active
- Options indisponibles → **grisées** dans la sheet (visibles, non-cliquables)
- Si les 3 options indispo → **bouton "Contacter" lui-même grisé**
- Bouton "Appeler" grisé si pas de téléphone
- Démarcheur → toujours actif (statut ignoré)
- Proprio/Locataire → désactivés si statut terminal

---

**✅ Design UI validé — transmis à l'Agent Flutter Dev**
