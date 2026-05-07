# Spécification Métier - Refonte Structure Screens

**Date :** 2025-12-28
**Statut :** Validé

---

## 1. Contexte

Claude Code génère du code non conforme aux conventions du projet :
- Fonctions privées `_buildXxx()` retournant des widgets
- Fonctions utilitaires dupliquées dans chaque fichier

La structure de dossiers actuelle par rôles/fonctionnalités est correcte et doit être conservée.

---

## 2. Objectif

Établir et appliquer des règles strictes de structure de code pour tous les écrans de l'application, puis refactorer l'existant pour se conformer à ces règles.

---

## 3. Structure de Dossiers

```
lib/screen/
├── auth/
│   ├── login_screen.dart           ← écran
│   ├── register_screen.dart        ← écran
│   └── widgets/                    ← widgets spécifiques à auth
│       └── auth_form.dart
├── client/
│   ├── proprio/
│   │   ├── residences/
│   │   │   ├── residence_detail_screen.dart   ← écran
│   │   │   ├── add_residence_screen.dart      ← écran
│   │   │   └── widgets/                        ← widgets spécifiques
│   │   │       └── residence_form.dart
│   │   └── appartements/
│   │       ├── add_appartement.dart           ← écran
│   │       └── widgets/
│   └── locataire/
│       └── ...
└── map/
    ├── maps.dart                   ← écran
    └── widgets/
```

**Règle clé :**
- Fichier `.dart` au **1er niveau** d'un dossier = **écran**
- Dossier `widgets/` = **widgets spécifiques** à ce niveau

---

## 4. Règles Métier

| ID | Règle | Description |
|----|-------|-------------|
| R1 | Structure par rôles | Conserver la structure existante par rôles/fonctionnalités |
| R2 | Écrans au 1er niveau | Tout `.dart` au 1er niveau d'un dossier screen = un écran |
| R3 | Widgets spécifiques | Placés dans dossier `widgets/` au même niveau que l'écran |
| R4 | Widgets génériques | Placés dans `lib/widget/[categorie]/` |
| R5 | Fonctions utilitaires | Placées dans `lib/utils/[role].dart` selon leur rôle |
| R6 | **INTERDIT** | Fonctions `_buildXxx()` retournant un Widget |
| R7 | **INTERDIT** | Fonctions de calcul/formatage privées dans screens |
| R8 | Widgets simples inline | Les widgets très simples (Row, Column basiques) restent dans `build()` |

---

## 5. Détail des Règles

### R6 - Interdiction des _buildXxx()

**INTERDIT :**
```dart
class MyScreen extends StatelessWidget {
  Widget _buildHeader() { ... }      // ❌ INTERDIT
  Widget _buildContent() { ... }     // ❌ INTERDIT
  Widget _buildFooter() { ... }      // ❌ INTERDIT
}
```

**CORRECT :**
```dart
// lib/screen/my_screen/widgets/my_header.dart
class MyHeader extends StatelessWidget { ... }  // ✅ OK

// lib/screen/my_screen/my_screen.dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MyHeader(),        // ✅ Widget séparé
          MyContent(),       // ✅ Widget séparé
          MyFooter(),        // ✅ Widget séparé
        ],
      ),
    );
  }
}
```

### R7 - Interdiction des fonctions utilitaires privées

**INTERDIT :**
```dart
class MyScreen extends StatelessWidget {
  String _formatDate(DateTime date) { ... }  // ❌ INTERDIT
  double _calculateTotal(List items) { ... } // ❌ INTERDIT
}
```

**CORRECT :**
```dart
// lib/utils/date_util.dart
String formatDate(DateTime date) { ... }  // ✅ OK

// lib/utils/calculation_util.dart
double calculateTotal(List items) { ... }  // ✅ OK
```

### R8 - Widgets simples inline

**AUTORISÉ inline :**
```dart
Row(
  children: [
    Icon(Icons.star),
    Text("Simple"),
  ],
)
```

**DOIT être extrait :**
- Widget avec logique conditionnelle complexe
- Widget avec plus de ~15 lignes
- Widget réutilisé plusieurs fois

---

## 6. Critères d'Acceptation

- [ ] Aucune fonction `_buildXxx()` dans les fichiers écran
- [ ] Aucune fonction utilitaire privée dans les screens
- [ ] Widgets complexes extraits dans `widgets/`
- [ ] Fonctions utilitaires dans `lib/utils/`
- [ ] Structure par rôles/fonctionnalités préservée
- [ ] Code compile sans erreur
- [ ] Pas de régression fonctionnelle

---

## 7. Scope

**Refactorer TOUS les écrans existants maintenant.**
