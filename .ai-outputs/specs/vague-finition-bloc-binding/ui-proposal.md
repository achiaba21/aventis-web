# 🎨 Proposition UI/UX — Vague de finition · Branchement BLoCs

> **Auteur :** Agent UI/UX (workflow `/feature full`)
> **Date :** 2026-05-10
> **Statut :** ✅ Validé par l'utilisateur (3 décisions actées)
> **Scope UI/UX réduit** : majorité du chantier = branchement BLoC sur écrans déjà conçus V1-V8 (aucun design nouveau requis). 3 nouveaux composants à designer : `EmptyState` (3 variants), `StaleBadge`, édition calendrier interactive.

---

## 1. Démarche

L'archi V8.5 (`architecture.md`) a tranché l'essentiel via les décisions BA. Cette proposition documente :
1. Les **3 décisions UI/UX validées** par l'utilisateur (EmptyState style, StaleBadge position, calendrier édition)
2. Le **changement de scope identifié** : proto étendu (AddListing, Calendar global, AddBooking) **reporté à V9 dédiée**

## 2. Décisions actées

### 2.1 EmptyState.hero — cercle accentSoft + icon accent

**Décision :** cercle 120×120 fond `accentSoft` + halo radial subtil + icon 40 `accent`. Cohérence avec `OnboardingRoleCard` V3 (cercles accentSoft + icon accent).

**Rationale :** subtil, on ne sur-charge pas la palette or. Évite la sensation « trop joyeux » qu'aurait un gradient or pour un état vide.

**Visual spec :**
```
        ┌──────────────┐
        │   ◯  halo    │  120×120 cercle fond accentSoft
        │              │  + halo radial accent.withAlpha(0.10) en arrière-plan
        │   ✦ icon 40  │  + icon size 40 color AppColors.accent
        │              │
        └──────────────┘
        Aucun voyage             Text style h2 (17px w700 text)
   Vos prochaines réservations   Text style body (14px text2)
   apparaîtront ici
   ┌────────────────────────┐
   │   Explorer  →          │   CustomButton primary lg block (V1)
   └────────────────────────┘
```

**Padding général :** 32 horizontal, 48 vertical. Centered.

### 2.2 EmptyState.inline — bgElev3 + icon text2

**Décision proposée par défaut :** carré 64×64 fond `bgElev3` radius lg + icon 28 `text2`. Plus sobre que hero, adapté aux sections de Dashboard.

**Visual spec :**
```
     ┌──────┐
     │ ◯    │  64×64 carré bgElev3 radius lg
     │ icon │  + icon 28 text2
     └──────┘
   Aucun client référé      Text 14 w600 text
   Référez votre 1er         Text 12 text3
   client pour voir vos
   commissions ici
                            (CTA optionnel)
```

**Usage :** sections Dashboard (`Mes clients référés` vide, `Logements à pousser` vide).

### 2.3 EmptyState.error — cloud_off + bouton retry

**Visual spec :**
```
        ☁️             Icon Icons.cloud_off size 64 color text3
   Connexion           h3 17px w600 text (centered)
   impossible
   Vérifiez votre      body 13 text2 (centered)
   connexion ou
   réessayez
   ┌──────────────────┐
   │   Réessayer      │   OutlinedCustomButton md block + leadingIcon refresh
   └──────────────────┘
```

**Usage :** timeout / 500 / pas de cache.

### 2.4 StaleBadge — pill flottant en haut de la liste

**Décision :** pill `bgElev2` border `line` radius pill, icon refresh 12 `text3` + texte 11 `text3` « Mis à jour il y a X ». Tap = trigger refresh. Affiché en haut de la zone scroll (pas sticky), visible dès l'ouverture si données stale.

**Visual spec :**
```
[🔄 Mis à jour il y a 5 min]
 ↑ Container pill, padding 8×12, bgElev2, border line, radius pill
   Row : icon refresh 12 text3 + texte 11 text3
   Tap : appelle widget.onRefresh
```

**Affichage conditionnel :**
- Affiché uniquement si `lastFetch != null` ET `lastFetch.difference(now) > 5min`
- Si `onRefresh != null` → tappable
- Sinon : caché complètement

### 2.5 Édition calendrier — tap immédiat avec animation

**Décision :** Option A — tap = appelle `BlockDay`/`UnblockDay` immédiatement. Cellule passe en accent avec animation 150ms ease (color transition).

**Justification du choix simple :**
- Le `MiniCalendarGrid` V7 actuel est utilisé en V8.5
- En V9 (proto étendu), il sera **remplacé** par `AvailabilityCalendar` du proto qui supporte la sélection de plage
- Pas la peine d'investir dans une UX complexe (long press, bottom sheet) maintenant — l'UX riche viendra en V9

**Comportement :**
- Tap jour disponible → `CalendarPlageBloc::BlockDay(day)` → cellule passe en accent (animation `AnimatedContainer` 150ms)
- Tap jour bloqué → `UnblockDay(day)` → cellule redevient transparent
- Tap jour réservé (déjà accent solid avec onAccent) → SnackBar "Réservation existante - voir détail" (pas modifiable)
- Tap aujourd'hui (bordé accent) → comme jour disponible
- Erreur backend → rollback optimistic + SnackBar `'Échec, réessayez'`

## 3. Hors scope V8.5 (reporté à V9)

L'utilisateur a étendu le proto avec 3 nouvelles fonctions (cf. `/Users/serge.achi/Downloads/asfar (1)/proprietaire-extras.jsx`). Ces écrans sont **reportés à V9 dédiée** :

| Fonction proto | Volume | Périmètre V9 |
|---|---|---|
| `ProprietaireAddListing` | 5 étapes (rooms → title+commune+area → photos → amenities → price) | Wizard création annonce — était F2 hors-proto |
| `ProprietaireCalendar` (global) | Selecteur listing + stats Occupé/Libre/Manque-à-gagner + `AvailabilityCalendar` + liste réservations du mois + conseil | Calendrier global proprio — était F10 hors-proto |
| `ProprietaireAddBooking` | 3 étapes (client info, dates, confirmation) | Ajout manuel réservation proprio — nouveau |
| `AvailabilityCalendar` (`shared.jsx:219`) | Widget partagé (sélection plage + busy days + monthLabel + firstDow) | Widget transverse — remplacera `MiniCalendarGrid` V7 |

**Conséquence pour V8.5** : on garde `MiniCalendarGrid` V7 actuel pour le Lot 12 (édition calendrier basique). En V9, on le remplacera par `AvailabilityCalendar` partagé.

## 4. Décisions de fait par défaut (non remontées car cohérence projet)

- **Toutes typographies** : tokens `AppTextStyles.*` (V1)
- **Tous paddings** : multiples de 4 ou tokens existants (cohérence V1-V8)
- **CTA primary** : `CustomButton` V1 (block lg pour hero, md pour error)
- **CTA secondary** : `OutlinedCustomButton` V1
- **CTA ghost** : `PlainButton` V1
- **Icones** : Material Icons standard (cohérence V5-V8)

## 5. Composants à créer (récap)

Aucun ajout par rapport à l'archi validée § 5. Les décisions ci-dessus précisent uniquement les visuels.

## 6. Composants à réutiliser

Aucun ajout par rapport à l'archi validée § 1.2.

## 7. Note V9 « Proto étendu »

Une nouvelle vague V9 sera dédiée aux extensions proto identifiées :
- `ProprietaireAddListing` (wizard 5 étapes)
- `ProprietaireCalendar` (global avec stats + conseil)
- `ProprietaireAddBooking` (ajout manuel)
- `AvailabilityCalendar` widget partagé (remplace `MiniCalendarGrid` V7)

À cadrer avec un `/feature full` séparé après V8.5.

---

## ✅ Validation UI/UX

- [x] 3 décisions UI/UX actées (EmptyState style, StaleBadge position, calendrier édition)
- [x] Visuels documentés au pixel-near
- [x] Cohérence avec identité Asfar Premium (V1-V8)
- [x] Changement de scope (proto étendu) identifié et reporté à V9
- [x] Aucun design nouveau hors EmptyState/StaleBadge/feedback calendrier

**Statut :** proposition UI/UX validée → transmission à l'agent Flutter Dev pour implémentation.
