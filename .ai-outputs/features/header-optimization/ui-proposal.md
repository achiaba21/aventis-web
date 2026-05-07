# Propositions UI/UX - Optimisation des en-têtes

## Analyse UI/UX

**Stack détecté :** Flutter (Dart)

**Design System observé :**

| Élément | Valeur |
|---------|--------|
| Couleur primaire | Orange `#FFA02A` |
| Background | Dark `#1D1D1D` |
| Texte | Blanc `#FFFFFF` |
| Border radius | 8px |
| Gap item | 4px |
| Gap section | 12px |
| Padding bloc | 16px |

**Composants réutilisables identifiés :**
- `TextSeed` - Texte stylé
- `PlainButton` - Bouton avec bordure
- `IconBoutton` - Bouton icône SVG
- `ElevatedButton.icon` - Bouton Material avec icône

---

## Décision 1 : GreetingHeader (Propriétaire)

### Option A : Layout vertical compact

Garder le layout vertical mais réduire drastiquement le gap.

```
┌─────────────────────────────────────┐
│ Hi, Jean-Pierre                     │
│ [+ Add new listing]                 │  ← gap réduit à 4px
└─────────────────────────────────────┘
```

**Modification :** `SizedBox(height: Espacement.gapItem)` (4px au lieu de 24px)

**Avantages :**
- Changement minimal
- Conserve le style actuel
- Bouton reste bien visible

**Inconvénients :**
- Prend encore 2 lignes
- ~80px de hauteur

---

### Option B : Layout horizontal (Recommandé)

Titre à gauche, bouton à droite sur une seule ligne.

```
┌─────────────────────────────────────┐
│ Hi, Jean-Pierre    [+ Add listing]  │
└─────────────────────────────────────┘
```

**Modification :** Remplacer `Column` par `Row` avec `MainAxisAlignment.spaceBetween`

**Avantages :**
- Une seule ligne (~48px)
- Gain d'espace maximal
- Design moderne type dashboard

**Inconvénients :**
- Bouton plus petit (texte raccourci)
- Sur petit écran, peut être serré

---

### Option C : Supprimer le GreetingHeader

Intégrer "Hi, [nom]" directement dans le titre de l'AppBar.

```
┌─────────────────────────────────────┐
│ Hi, Jean      [+] [🔔] [📷]        │  ← AppBar
│ Réservations | Listings             │  ← TabBar
└─────────────────────────────────────┘
```

**Modification :** Modifier l'AppBar title + ajouter IconButton "+" dans actions

**Avantages :**
- Supprime complètement le header séparé
- Gain maximal (~100px)
- Plus cohérent avec les standards Material

**Inconvénients :**
- Bouton devient une icône sans label
- Moins explicite pour l'action "Add"

---

## Décision 2 : Bouton "Vue carte" (Locataire)

### Option A : IconButton simple (Recommandé)

Icône carte à droite de la barre de recherche.

```
┌─────────────────────────────────────┐
│ 🔍 Rechercher...        [⚙] [🗺]   │
└─────────────────────────────────────┘
```

**Composant :** `IconButton(icon: Icon(Icons.map_outlined))`

**Avantages :**
- Compact
- Icône universellement comprise
- Cohérent avec l'icône filtre existante

**Inconvénients :**
- Moins explicite que "Vue carte"

---

### Option B : Chip/Badge avec texte

Petit badge "Carte" à droite.

```
┌─────────────────────────────────────┐
│ 🔍 Rechercher...      [⚙] [Carte]  │
└─────────────────────────────────────┘
```

**Composant :** `PlainButton(value: "Carte", plain: false)`

**Avantages :**
- Texte explicite
- Réutilise PlainButton existant

**Inconvénients :**
- Prend plus de place
- Peut créer un déséquilibre visuel

---

## Décision 3 : Bouton "Add" dans AppBar (Propriétaire)

### Option A : IconButton "+" seul (Recommandé)

Icône "+" orange dans les actions de l'AppBar.

```
Actions: [ [+] ] [ 🔔 ] [ 📷 ]
```

**Style :**
```dart
IconButton(
  icon: Icon(Icons.add_circle_outline),
  color: Style.primaryColor,
  iconSize: 28,
)
```

**Avantages :**
- Compact
- Aligné avec les autres actions
- Couleur primaire le distingue

**Inconvénients :**
- Moins explicite sans label

---

### Option B : FloatingActionButton mini

FAB mini en position standard.

```
┌─────────────────────────────────────┐
│                                [+]  │  ← FAB flottant
│ [CONTENU]                           │
└─────────────────────────────────────┘
```

**Avantages :**
- Convention Material Design
- Toujours accessible (flottant)

**Inconvénients :**
- Superposé au contenu
- Peut gêner sur mobile

---

## Recommandations finales

| Décision | Option recommandée | Justification |
|----------|-------------------|---------------|
| GreetingHeader | **Option B** (horizontal) | Gain d'espace optimal, design moderne |
| Bouton carte | **Option A** (IconButton) | Compact, cohérent avec l'icône filtre |
| Bouton Add | **Option A** (IconButton "+") | Intégré dans AppBar, cohérent |

