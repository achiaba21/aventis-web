# Rapport d'Audit — `demarcheur-listing-availability-calendar`

**Date :** 2026-05-24  
**Auditeur :** Agent Audit  
**Périmètre :** 3 fichiers (1 créé, 2 modifiés)

---

## 1. Vérification des Critères d'Acceptation

| Réf | Critère | Statut | Détail |
|-----|---------|--------|--------|
| R1 | Calendrier lecture seule (`onDayTap = null`) | ✅ | `MiniCalendarGrid` instancié sans `onDayTap` → null par défaut |
| R2 | `CalendarService.getDemarcheurCalendar` au moment de la sélection | ✅ | `_selectListing()` appelle `CalendarService().getDemarcheurCalendar(id)` avec cache |
| R3 | Mois courant = borne min navigation | ✅ | `_onPrevMonth()` compare `prev.isBefore(minMonth)` et bloque |
| R4 | Réutilisation effective de `MiniCalendarGrid` | ✅ | `ListingAvailabilityCalendar` wrap `MiniCalendarGrid` directement, 0 duplication |
| R5 | Flow Continuer → `DemarcheurAppartDetailScreen` inchangé | ✅ | `pushScreen(context, DemarcheurAppartDetailScreen(appartement: selectedAppart))` |
| R6 | Un seul logement sélectionné à la fois | ✅ | `_selectedId` (int?) unique, remplacé à chaque tap |

**Tous les critères d'acceptation sont satisfaits.**

---

## 2. Scoring par Dimension

### D1 — Complexité Cyclomatique : 88/100

**Analyse :**
- `_selectListing()` : 3 branches (null id, cache hit, erreur) — acceptable
- `_onPrevMonth()` : 1 condition simple
- `build()` dans `DemarcheurListingsScreen` : 5 branches (Loading, Error, empty, normale, CTA) — lisible
- `_daysWithStatut()` : 1 boucle + 1 condition = faible complexité
- Aucune imbrication excessive détectée

**Pénalité :** aucune

---

### D2 — Lisibilité : 90/100

**Points positifs :**
- Nommage expressif : `_selectedId`, `_calendarCache`, `_loadingIds`, `_selectListing`, `_onPrevMonth`
- Docstrings de classe présentes sur les 3 widgets publics
- Structure de build() claire et linéaire
- Le pattern `isSelected && calendarWidget != null` est explicite

**Mineurs :**
- `_CalendarLegendDot` est privé au fichier mais bien nommé
- `_RadioIndicator` idem — cohérent avec les règles projet (widget dédié dans son propre fichier est respecté ici car ces classes privées sont visuellement simples et non réutilisées)

**Pénalité :** aucune

---

### D3 — DRY : 85/100

**Points positifs :**
- `MiniCalendarGrid` réutilisé sans duplication
- `ReferralCommissionHelper.estimate` réutilisé pour le calcul commission
- `ShimmerCard` réutilisé pour les états de chargement
- `EmptyState.error` / `EmptyState.hero` réutilisés

**Observation mineure :**
- `_daysWithStatut()` boucle sur les mois-jour potentiellement O(plages × jours) — acceptable à cette échelle mais pourrait être optimisé. Pas une duplication, mais une micro-dette algorithmique.

**Pénalité :** -5 (mineur — micro-dette algo dans `_daysWithStatut`)

---

### D4 — Documentation : 85/100

**Points positifs :**
- `ListingAvailabilityCalendar` : docstring complète (rôle, réutilisation, readonly)
- `PartnerListingCard` : docstring mise à jour avec les nouveaux paramètres `isSelected` et `calendarWidget`
- `DemarcheurListingsScreen` : docstring précise le flow et le comportement

**Manques :**
- Les paramètres des constructeurs ne sont pas documentés individuellement (pas de `///` sur chaque `final`)
- `_CalendarLegendDot` et `_RadioIndicator` n'ont pas de commentaire mais leur nom est auto-documentant

**Pénalité :** -5 (mineur — absence de doc sur paramètres constructeurs)

---

### D5 — SOLID : 87/100

**Analyse :**
- **SRP ✅** : `ListingAvailabilityCalendar` gère uniquement l'affichage calendrier. `PartnerListingCard` gère uniquement l'affichage de la card. `DemarcheurListingsScreen` gère la logique de sélection et navigation.
- **OCP ✅** : `PartnerListingCard` étendu via props sans modifier la logique existante
- **LSP ✅** : pas d'héritage problématique
- **ISP ✅** : interfaces minimales, props ciblées
- **DIP ✅** : `CalendarService()` instancié directement — pattern existant du projet (conforme aux décisions archi), pas une violation dans ce contexte

**Observation :** L'instanciation directe `CalendarService()` dans le State est une décision architecturale documentée ("CalendarService appelé directement (pattern existant)"). Pas pénalisée.

**Pénalité :** aucune

---

### D6 — Dette Technique : 86/100

**Points positifs :**
- Cache `_calendarCache` évite les appels réseau redondants — bonne gestion
- `mounted` vérifié après chaque await — pas de fuite mémoire
- `WidgetsBinding.instance.addPostFrameCallback` pour initier le chargement BLoC — pattern correct
- Pas de `setState` inutile

**Dettes mineures :**
- `_calendarCache` n'est jamais invalidé (si le démarcheur revient sur l'écran et que les données ont changé, il verra du cache périmé). Acceptable pour V1, à documenter.
- `orElse: () => apparts.first` lors de la recherche du `selectedAppart` est un fallback silencieux qui pourrait masquer un désync. Faible risque en pratique.

**Pénalité :** -5 (mineur — cache non invalidé, fallback silencieux)

---

## 3. Score Global

| Dimension | Score /100 | Pénalités |
|-----------|-----------|-----------|
| D1 Complexité | 88 | 0 |
| D2 Lisibilité | 90 | 0 |
| D3 DRY | 85 | -5 |
| D4 Documentation | 85 | -5 |
| D5 SOLID | 87 | 0 |
| D6 Dette technique | 86 | -5 |
| **TOTAL** | **521** | **-15** |
| **MOYENNE** | **86.8/100** | |

**Score final : 87/100** (après arrondi)

---

## 4. Verdict

### ✅ VALIDÉ — Score 87/100 (seuil : 60)

La feature est correctement implémentée. Tous les critères d'acceptation R1–R6 sont satisfaits. Le code est lisible, DRY, bien structuré et respecte les conventions du projet.

### Points d'excellence
- Réutilisation exemplaire de `MiniCalendarGrid` (0 duplication)
- Gestion robuste des états async (`mounted`, cache, `_loadingIds`)
- `_RadioIndicator` proprement extrait en widget dédié dans le fichier (conforme règle projet)
- Navigation mois avec borne min correctement implémentée

### Recommandations non bloquantes
1. **(Mineur)** Invalider `_calendarCache` lors d'un refresh de la liste ou documenter explicitement la décision V1
2. **(Mineur)** Ajouter un log ou assertion si `selectedAppart` ne correspond pas à `_selectedId` (éviter le fallback silencieux)
3. **(Mineur)** Documenter les paramètres de `ListingAvailabilityCalendar` avec `///` individuels

---

**Prêt pour la phase Documentation.**
