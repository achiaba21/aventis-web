# 🎨 Proposition UI/UX — Vague 7 Propriétaire

> **Auteur :** Agent UI/UX (workflow `/feature full`)
> **Date :** 2026-05-10
> **Statut :** ✅ Résolu par fidélité proto (R5 du `RECONSTRUCTION_UI_ASFAR.md`)
> **Source primaire :** `~/Downloads/Asfar Prototype.html` + extraits dans `.ai-outputs/prototype-extract/proprietaire.jsx` + `app.jsx`
> **Consigne utilisateur :** « se référer DIRECTEMENT à la maquette source ». Aucune UX inventée — tout vient du proto.

---

## 1. Démarche

L'archi V7 (`architecture.md`) a tranché l'essentiel via les décisions BA. Cette proposition documente les **zones où le proto laisse un comportement ouvert** (taps non câblés, indicateurs visuels nécessaires, mocks de calcul) et tranche par fidélité au proto.

## 2. Zones résolues par lecture directe du proto

### 2.1 TabBar ListingEdit — indicator underline

Le proto (`proprietaire.jsx:504-520`) implémente la TabBar comme un Row de `<div onClick>` avec :

```css
padding: 12px 4px;
text-align: center;
font-size: 13px;
font-weight: 600;
color: tab === t.id ? var(--accent) : var(--text-3);
border-bottom: tab === t.id ? "2px solid var(--accent)" : "2px solid transparent";
margin-bottom: -1px; /* aligner sur la borderBottom du parent */
```

**Décision Flutter :** `DefaultTabController` + `TabBar` Material avec :
- `indicator: UnderlineTabIndicator(borderSide: BorderSide(color: AppColors.accent, width: 2))`
- `labelColor: AppColors.accent`
- `unselectedLabelColor: AppColors.text3`
- `labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)`
- `dividerColor: AppColors.line` (la borderBottom du parent)
- `tabAlignment: TabAlignment.fill` (chaque tab prend `flex: 1`)

### 2.2 Calendar grid (tab Calendrier) — pattern proto exact

Le proto (`proprietaire.jsx:585-645`) implémente :
- Header card avec chevrons gauche/droite + titre `Novembre 2025` h3
- Grid 7 colonnes (jours `L M M J V S D` en `t-small` 11px bold) + cellules carrées (aspectRatio 1:1)
- Offset au début (5 cellules vides pour Nov 1 = samedi)
- 30 cellules pour les jours
- Couleurs cellules :
  - **Réservé** (booked) : fond `accent` solid + texte `#1A1206` + weight 700 + radius 8
  - **En attente** (pending) : fond `accentSoft` + texte `accent` + radius 8
  - **Aujourd'hui** (today, !booked) : `border 1.5 accent` + texte `accent` + radius 8
  - **Disponible** : transparent + texte `text` + radius 8

**Mock proto (Nov 2025) :**
- Today = jour 7
- Booked = `[9, 10, 11, 14, 15, 16, 17, 22, 23, 24, 25]`
- Pending = `[28, 29]`

**Légende :** **3 entrées** seulement (proto ne montre PAS « Disponible ») :
- Réservé : carré `12×12 radius 4 background accent`
- En attente : carré `12×12 radius 4 background accentSoft + border 1 rgba(232,184,107,0.4)`
- Aujourd'hui : carré `12×12 radius 4 border 1.5 accent`

**Comportement :** view-only (décision BA). Tap sur jour ou chevrons = SnackBar « Édition calendrier disponible prochainement ».

### 2.3 ListingFullCard (Listings) — structure proto

Le proto (`proprietaire.jsx:377-430`) implémente :
- `ImgPh` ratio 16:9 + 2 badges en absolute (top: 12, left: 12) : `● Actif` (success) + `★ Certifié` (accent) si superhost
- Bouton `moreH` en absolute (top: 12, right: 12) : `32×32 radius 99 rgba(10,10,11,0.6) + blur 10` avec icon blanche
- Body padding 14 :
  - Row : titre 15px w600 (gauche) + prix mono `{fmtFCFAk}/n` 14px w700 (droite)
  - Sub `t-small` 12px : `${area} · ${surface} m²`
  - Row 3 KPIs inline (flex 1 each) : eyebrow 9px + valeur mono 14px w700
    - OCCUP. : `Math.round(occupancy*100)%`
    - NOTE : icon star + rating
    - REV. MOIS : `fmtFCFAk(revenue)`
- Footer : `borderTop 1 line`, padding 6, gap 4, 3 boutons ghost flex 1 (Calendrier / Modifier / Stats)

### 2.4 Card « Nouvelle annonce » dashed

Le proto (`proprietaire.jsx:432-444`) :
- `padding: 24, textAlign: center, borderStyle: dashed, borderWidth: 1.5`
- Cercle 50×50 radius 99 fond `accentSoft` + icon plus 22 accent
- Label « Nouvelle annonce » 14px w600
- Sub `t-small` 12px : « Mettez votre logement en location en 5 min »

→ Tap = SnackBar « Création d'annonce disponible prochainement (F2) »

### 2.5 ListingEdit — Hero et stats

Le proto (`proprietaire.jsx:467-502`) :
- `ImgPh` ratio 16:10 + badge en bottom-right (12px) : `rgba(10,10,11,0.7) + blur 10`, padding `8px 12px`, radius 10, icon image 14 + texte `8 photos` 12px w600
- Stats card : padding 16, Row de 2 cols + séparateur vertical 1px line :
  - Col 1 : eyebrow `Occupation` + valeur mono 22px w700 + barre progress 4px (background `bgElev3` + fill `accent` à `occupancy*100%`)
  - Col 2 : eyebrow `Note moy.` + Row icon star 20 + valeur mono 22px + sub `${reviews} avis` 11px

### 2.6 Tarifs (tab Tarifs) — tarif de base hero + 5 FieldRow

Le proto (`proprietaire.jsx:535-551`) :
- Card hero : padding 16, eyebrow « Tarif de base » + valeur 28px w700 mono `${price}` + suffix 14px text-3 `/nuit`
- 5 `FieldRow` :
  - `Tarif weekend (ven-sam)` : `price × 1.2` (formaté FCFA)
  - `Tarif haute saison` : `price × 1.4`
  - `Réduction semaine (≥7 nuits)` : `−price × 0.10` (préfixe `−`)
  - `Réduction mois (≥28 nuits)` : `−price × 0.20`
  - `Frais ménage (par séjour)` : `8 000 FCFA`

**Implication :** ces valeurs sont calculées à la volée depuis `listing.price`. Pas besoin de mock dédié — c'est du dérivé.

### 2.7 Règles (tab Règles) — 6 FieldRow constantes

Le proto (`proprietaire.jsx:553-564`) :
- Arrivée : « À partir de 14h »
- Départ : « Avant 11h »
- Animaux : « Non autorisés »
- Fêtes : « Non autorisées »
- Fumeurs : « Non autorisé »
- Caution : « 50 000 FCFA »

**Implication :** valeurs en dur dans le widget `ListingRulesTab`. Pas de mock.

### 2.8 Dashboard — Cashflow split (proto exact)

Le proto (`proprietaire.jsx:88-118`) :
- Header Row : `t-h3` « Flux financier » + lien `t-small accent` « Détails → »
- Card padding 16
- Stacked bar : height 14, radius 99, overflow hidden, background `bgElev3`, 4 segments :
  - 62% `accent`
  - 20% `#A06B30` (brown)
  - 12% `#5E6CFF` (cardPay)
  - 6% `text-3`
- 4 lignes de légende avec dot 8×8 radius 99 + label 13px text-2 + montant mono 13px w600 :
  - `Locations nettes` : 1 178 000 (color accent)
  - `Charges (entretien, eau, élec.)` : 380 000 (color #A06B30)
  - `Commissions démarcheurs` : 228 000 (color #5E6CFF)
  - `Frais plateforme` : 114 000 (color text-3)

**Tokens manquants AppColors :** `#A06B30` (brown charges) — à ajouter en `cashflowCharges`. `#5E6CFF` existe déjà sous `cardPay` (V5) — réutilisable.

### 2.9 ProjectionChart Finances (line chart)

Le proto (`proprietaire.jsx:317-336`) implémente un SVG inline :
- viewBox 280×80
- Linear gradient or (alpha 0.4 → 0)
- Path 1 (passé Sept-Nov) : `M0,60 L40,50 L80,42 L120,32 L160,22` solid stroke 2 accent
- Path 2 (futur Nov-Mars) : `M160,22 L200,18 L240,12 L280,8` dashed `4 4` stroke 2 accent
- Path area : `... L280,80 L0,80 Z` fill gradient
- Marker : `circle cx=160 cy=22 r=4 fill accent` (point Nov)
- Vertical line séparateur passé/futur : `x1=160 y1=0 x2=160 y2=80 stroke rgba(232,184,107,0.3) dashed 2 2`
- Labels mois en bas (Sept/Oct/Nov/Déc/Jan/Fév/Mars) : 7 spans flex 1 textCenter, `Nov` en accent + bold (i === 2)

**Décision Flutter :** `fl_chart 0.69` `LineChart` avec :
- 2 séries `LineChartBarData` :
  - Passé (indices 0-2 inclus) : color `accent`, no dash, dotData false
  - Futur (indices 2-6) : color `accent`, dashArray [4, 4], dotData false
  - Pivot point sur indice 2 (Nov) inclus dans les 2 séries pour continuité visuelle
- `belowBarData` sur la série « passée+futur fusionnée » : gradient or alpha 0.4 → 0
- `extraLinesData` : 1 verticalLine sur x=2 (Nov) avec dashes [2, 2] et alpha 0.3
- Marker accent or sur Nov : ajouté via une 3e série (1 point) `dotData: FlDotData(show: true, getDotPainter: ...)`
- titlesData : bottomTitles avec labels mois (Nov bold + accent)

**Eyebrow + montant + badge** au-dessus du chart (proto:308-314) :
- Row : eyebrow « Estimation Q1 2026 » + montant mono 22px w700 (gauche) + badge accent « ★ Haute saison » (droite)

## 3. CTAs / interactions tranchées

| CTA / interaction | Action V7 |
|---|---|
| Tap row `ProprioListingRow` (Dashboard) | `pushScreen(ProprioListingEditScreen(listing))` |
| Tap « Tout voir » Mes annonces (Dashboard) | `pushScreen(ProprioListingsScreen())` |
| Tap « Détails → » Flux financier (Dashboard) | `pushScreen(ProprioFinancesScreen())` |
| Tap demande en attente (Dashboard) | SnackBar « Détail demande disponible prochainement (F5) » |
| Tap card `ListingFullCard` (Listings) | `pushScreen(ProprioListingEditScreen(listing))` |
| Tap bouton `moreH` (Listings) | SnackBar « Plus d'options bientôt » |
| Tap footer « Calendrier » (Listings card) | `pushScreen(ProprioListingEditScreen(listing, initialTab: 1))` |
| Tap footer « Modifier » (Listings card) | `pushScreen(ProprioListingEditScreen(listing, initialTab: 0))` |
| Tap footer « Stats » (Listings card) | SnackBar « Statistiques détaillées disponibles prochainement » |
| Tap card « Nouvelle annonce » | SnackBar « Création d'annonce disponible prochainement (F2) » |
| Tap bouton `moreV` (ListingEdit header) | SnackBar « Plus d'options bientôt » |
| Tap chevrons navigation calendrier | SnackBar « Navigation calendrier disponible prochainement » |
| Tap jour calendrier | SnackBar « Édition calendrier disponible prochainement » |
| Tap `FieldRow` icon edit (ListingEdit Infos / Tarifs / Règles) | SnackBar « Édition disponible prochainement » |
| Tap CTA « Exporter PDF/CSV » (Finances) | SnackBar « Export PDF/CSV disponible prochainement (F8) » |
| Tap icon `download` header Finances | SnackBar « Export PDF/CSV disponible prochainement (F8) » |
| Tap notif bell header Dashboard | SnackBar « Notifications disponibles prochainement (V8) » |
| Tap icon `grid` left header Dashboard | SnackBar (proto = vue alternative, pas câblée) |

## 4. Token couleur supplémentaire à ajouter

Le proto utilise un brun `#A06B30` pour le segment « Charges » de la barre stack cashflow. À ajouter à `AppColors` :

```dart
/// Brown chaud — segment "Charges" du cashflow split (Dashboard proprio).
static const Color cashflowCharges = Color(0xFFA06B30);
```

Les autres couleurs requises (`accent`, `cardPay` pour démarcheurs, `text3` pour frais plateforme) sont déjà disponibles.

## 5. Header `sub` vs `eyebrow` — cohérence V6

Le proto utilise `sub` (en-dessous du titre) pour les TopNav. La V6 a utilisé `eyebrow` (au-dessus). Pour cohérence V6, on continue avec `eyebrow` :
- Dashboard : `eyebrow: 'TABLEAU DE BORD'` + `title: 'Bonjour, $firstName'`
- Finances : `eyebrow: 'P&L · CHARGES · PROJECTIONS'` + `title: 'Finances'`
- ListingEdit : `eyebrow: 'ANNONCE ACTIVE'` + `title: '${listing.title}'`

**Note (TODO REBUILD)** : harmoniser `DynamicAppBar` pour ajouter un slot `sub` (alternative à `eyebrow`) dans une vague de finition transverse — concerne aussi l'ajustement éventuel de V6.

## 6. Composants à créer (récap)

Aucun ajout par rapport à l'archi validée § 5. Les décisions ci-dessus précisent uniquement les **comportements** (taps) et les **valeurs visuelles exactes**.

## 7. Composants à réutiliser

Aucun ajout par rapport à l'archi § 1.2.

## 8. Points en suspens (à acter en début Lot 1)

- [ ] **Token `cashflowCharges`** (`#A06B30`) à ajouter dans `lib/theme/app_colors.dart`
- [ ] **Confirmation report** : harmonisation `eyebrow` vs `sub` dans `DynamicAppBar` → reportée à finition transverse
- [ ] **Confirmation report** : empty states + édition calendrier + UX exports → reportés à finition F8 / post-V9 (tracé dans `RECONSTRUCTION_UI_ASFAR.md` TODO REBUILD)

---

## ✅ Validation UI/UX

- [x] Le proto a été lu directement comme source primaire (proprietaire.jsx + app.jsx)
- [x] Aucune création de pattern UI/UX qui n'existe pas dans le proto
- [x] Toutes les zones où le proto ne câblait pas un tap sont tranchées avec un SnackBar stub explicite
- [x] Les comportements navigationnels (Tout voir / Détails / Modifier / Calendrier) sont précisés
- [x] Couleurs proto exactes documentées (#A06B30, alphas, gradients)
- [x] Cohérence avec la règle R5 (Layout 100% prototype)
- [x] Mocks calculés à la volée (Tarifs depuis `price`) vs mocks dédiés (perf, projection)

**Statut :** proposition UI/UX validée → transmission à l'agent Flutter Dev pour implémentation.
