# Architecture - Refonte Structure Screens

**Date :** 2025-12-28
**Statut :** En attente de validation

---

## 1. Vue d'Ensemble

### Objectif
Refactorer tous les écrans (49 fichiers) pour éliminer les fonctions `_buildXxx()` et les fonctions utilitaires privées dupliquées.

### Scope
- **17 fichiers** avec fonctions `_buildXxx()` à extraire
- **11 fichiers** avec fonctions `_formatXxx()` dupliquées
- **~35 widgets** à créer/extraire

---

## 2. Inventaire des Violations

### 2.1 Fonctions _buildXxx() à Extraire

| Fichier | Fonction | Action |
|---------|----------|--------|
| `receipt/receipt_detail_screen.dart` | `_buildDateRow`, `_buildFinancialRow` | Extraire en widgets |
| `shared/notifications/widget/notification_list_view.dart` | `_buildNotificationItem`, `_buildEmptyListView` | Extraire en widgets |
| `proprio/appartements/add_appartement.dart` | `_buildBottomActions` | Extraire en widget |
| `proprio/reservations/qr_scanner_screen.dart` | `_buildScanOverlay`, `_buildInstructions`, `_buildLoadingOverlay` | Extraire en widgets |
| `proprio/appartements/proprio_appart_detail_screen.dart` | `_buildAppartementDetail` | Extraire en widget |
| `shared/notifications/notifications_screen.dart` | `_buildAppBar`, `_buildContent`, `_buildEmptyFilterState` | Extraire en widgets |
| `proprio/comptabilite/comptabilite_screen.dart` | `_buildBody` | Extraire en widget |
| `proprio/home/proprio_home.dart` | `_buildListingsContent` | Extraire en widget |
| `proprio/comptabilite/widget/repartition_ca_chart.dart` | `_buildLegend` | Laisser inline (widget déjà) |
| `locataire/favorite/favorite.dart` | `_buildEmptyState`, `_buildErrorState` | Extraire en widgets |
| `proprio/home/widget/appartements_section.dart` | `_buildEmptyState`, `_buildAppartementsList` | Laisser inline (widget déjà) |
| `locataire/home/explore.dart` | `_buildAppartementsList` | Extraire en widget |
| `locataire/inbox/conversation.dart` | `_buildMessageList` | Extraire en widget |
| `locataire/map/map_explore_screen.dart` | `_buildInfoCard`, `_buildCurrentPositionMarker` | Extraire en widgets |
| `locataire/home/appart_detail_screen.dart` | `_buildAppartementDetail` | Extraire en widget |
| `locataire/home/widget/info_cancel.dart` | `_buildInfoRow` | Laisser inline (widget déjà) |
| `proprio/comptabilite/export/pdf_export_service.dart` | Plusieurs `_build*` | **EXCEPTION** : PDF génération, garder tel quel |

### 2.2 Fonctions Utilitaires à Déplacer

| Fichier | Fonction | Destination |
|---------|----------|-------------|
| `proprio/comptabilite/charge_detail_screen.dart` | `_formatDate`, `_formatDateWithStatus`, `_formatMontant` | `lib/util/formate.dart` |
| `proprio/comptabilite/widget/dashboard_cards.dart` | `_formatMontant`, `_formatMontantComplet` | `lib/util/formate.dart` |
| `proprio/compte/widget/transaction_item.dart` | `_formatDate` | Utiliser `formate.dart` existant |
| `proprio/comptabilite/widget/repartition_ca_chart.dart` | `_formatMontant` | `lib/util/formate.dart` |
| `proprio/comptabilite/widget/evolution_chart.dart` | `_formatAxisValue`, `_formatMontant` | `lib/util/formate.dart` |
| `proprio/comptabilite/widget/charge_list_section.dart` | `_formatMontant`, `_formatDate` | `lib/util/formate.dart` |
| `proprio/comptabilite/export/pdf_export_service.dart` | `_formatMontant`, `_formatPeriode` | `lib/util/formate.dart` |

---

## 3. Plan de Refactoring

### Phase 1 : Centraliser les Utilitaires

**Enrichir `lib/util/formate.dart` avec :**

```dart
/// Formate un montant avec séparateurs de milliers
/// Ex: 1234567.89 → "1 234 567,89 FCFA"
String formatMontant(double montant, {bool showCurrency = true}) {
  // Utiliser helpAmountFormate existant + devise
}

/// Formate un montant compact (K, M)
/// Ex: 1500000 → "1.5M"
String formatMontantCompact(double montant) { ... }

/// Formate une date avec statut de retard
String formatDateWithStatus(DateTime date, {bool isLate = false, bool isUpcoming = false}) { ... }

/// Formate une période
String formatPeriode(DateTime debut, DateTime fin) { ... }

/// Formate une valeur d'axe pour les graphiques
String formatAxisValue(double value) { ... }
```

### Phase 2 : Créer les Dossiers widgets/

```
lib/screen/
├── receipt/
│   ├── receipt_detail_screen.dart
│   └── widgets/                          # À CRÉER
│       ├── receipt_date_row.dart
│       └── receipt_financial_row.dart
├── client/
│   ├── proprio/
│   │   ├── appartements/
│   │   │   ├── add_appartement.dart
│   │   │   ├── proprio_appart_detail_screen.dart
│   │   │   └── widgets/                  # À CRÉER
│   │   │       ├── add_appartement_bottom_actions.dart
│   │   │       └── appartement_detail_content.dart
│   │   ├── reservations/
│   │   │   ├── qr_scanner_screen.dart
│   │   │   └── widgets/                  # À CRÉER
│   │   │       ├── scan_overlay.dart
│   │   │       ├── scan_instructions.dart
│   │   │       └── loading_overlay.dart
│   │   ├── comptabilite/
│   │   │   ├── comptabilite_screen.dart
│   │   │   └── widgets/                  # EXISTE DÉJÀ
│   │   │       └── comptabilite_body.dart  # À CRÉER
│   │   └── home/
│   │       ├── proprio_home.dart
│   │       └── widgets/                  # EXISTE DÉJÀ
│   │           └── listings_content.dart   # À CRÉER
│   ├── locataire/
│   │   ├── favorite/
│   │   │   ├── favorite.dart
│   │   │   └── widgets/                  # À CRÉER
│   │   │       ├── favorite_empty_state.dart
│   │   │       └── favorite_error_state.dart
│   │   ├── home/
│   │   │   ├── explore.dart
│   │   │   ├── appart_detail_screen.dart
│   │   │   └── widgets/                  # EXISTE DÉJÀ
│   │   │       ├── appartements_list.dart  # À CRÉER
│   │   │       └── appart_detail_content.dart  # À CRÉER
│   │   ├── inbox/
│   │   │   ├── conversation.dart
│   │   │   └── widgets/                  # À CRÉER
│   │   │       └── message_list.dart
│   │   └── map/
│   │       ├── map_explore_screen.dart
│   │       └── widgets/                  # À CRÉER
│   │           ├── info_card.dart
│   │           └── current_position_marker.dart
│   └── shared/
│       └── notifications/
│           ├── notifications_screen.dart
│           └── widgets/                  # EXISTE DÉJÀ
│               ├── notifications_app_bar.dart  # À CRÉER
│               ├── notifications_content.dart  # À CRÉER
│               └── empty_filter_state.dart     # À CRÉER
```

### Phase 3 : Ordre d'Exécution

1. **Utilitaires** (1 fichier)
   - Enrichir `lib/util/formate.dart`

2. **Écrans prioritaires** (fichiers les plus impactés)
   - `comptabilite_screen.dart` et widgets associés
   - `notifications_screen.dart`
   - `proprio_home.dart`

3. **Écrans secondaires**
   - `favorite.dart`
   - `explore.dart`
   - `conversation.dart`
   - `map_explore_screen.dart`

4. **Écrans restants**
   - `receipt_detail_screen.dart`
   - `qr_scanner_screen.dart`
   - `add_appartement.dart`
   - `appart_detail_screen.dart` (locataire et proprio)

---

## 4. Exceptions

| Fichier | Raison |
|---------|--------|
| `pdf_export_service.dart` | Génération PDF, les `_build*` sont des builders PDF (pw.Widget), pas des widgets Flutter |
| Widgets existants dans `/widget/` | Les `_build*` dans des fichiers déjà dans un dossier `widget/` peuvent rester inline si simples |

---

## 5. Critères de Validation

- [ ] Aucune fonction `_buildXxx()` dans les fichiers écran au 1er niveau
- [ ] Toutes les fonctions `_formatXxx()` centralisées dans `lib/util/formate.dart`
- [ ] Chaque écran refactoré compile sans erreur
- [ ] Pas de régression fonctionnelle
- [ ] Structure widgets/ créée où nécessaire

---

## 6. Estimation

| Phase | Fichiers | Widgets à créer |
|-------|----------|-----------------|
| Phase 1 - Utilitaires | 1 | 0 |
| Phase 2 - Prioritaires | 3 | 5 |
| Phase 3 - Secondaires | 4 | 8 |
| Phase 4 - Restants | 5 | 7 |
| **TOTAL** | **13** | **~20** |
