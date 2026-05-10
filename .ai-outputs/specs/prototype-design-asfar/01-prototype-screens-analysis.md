# 📱 Asfar Prototype — Inventaire des écrans

> **Source :** `~/Downloads/Asfar Prototype.html` (bundle React/Babel auto-portant)
> **Extraction :** `.ai-outputs/prototype-extract/` (8 scripts JSX décodés depuis le manifest gzip+base64)
> **Date d'analyse :** 2026-05-07

---

## 🗂️ Vue d'ensemble

Le prototype simule **3 applications mobiles** dans des cadres iOS (402×874 px) côte à côte, partageant un même design system **Asfar Dark Premium**.

| Fichier source | Rôle | Écrans | Lignes |
|---|---|---|---|
| `app.jsx` | Shell + routage par rôle | TabBar, stack navigation | 188 |
| `shared.jsx` | Primitives UI partagées | Icons (60+), TopNav, Stat, ListingCard data | 216 |
| `locataire.jsx` | Côté **voyageur** | 5 écrans | 770 |
| `proprietaire.jsx` | Côté **propriétaire** | 4 écrans + sous-vues | 648 |
| `demarcheur.jsx` | Côté **démarcheur** | 4 écrans | 548 |
| `extras.jsx` | Onboarding, messaging, profil | 5 écrans | 377 |

---

## 🧭 Architecture de navigation

### Pattern de routing

Le shell `PhoneApp` utilise une **pile de frames** (stack) couplée à une **TabBar** dynamique selon le rôle. Chaque frame est `{ tab, sub?, id? }`. Une fonction `push()` ajoute au stack, `pop()` retire, `setTab()` réinitialise.

> ⚙️ Implication Flutter : reproduire avec un `Navigator` imbriqué par tab (stack par onglet, comme ShellRoute de `go_router`), ou un système route-based avec `IndexedStack` pour préserver l'état des onglets.

### TabBars par rôle

| Rôle | Tab 1 | Tab 2 | Tab 3 | Tab 4 | Tab 5 |
|---|---|---|---|---|---|
| 🛏️ **Locataire** | Explorer (search) | Voyages (calendar) | Favoris (heart) | Messages (chat) | Profil (user) |
| 🏠 **Propriétaire** | Accueil (grid) | Annonces (listings) | Finances (chart) | Messages (chat) | Profil (user) |
| 🤝 **Démarcheur** | Accueil (grid) | Demandes (send) | Gains (wallet) | Messages (chat) | Profil (user) |

> La tab bar est **masquée** automatiquement sur les écrans de détail (réservation, recherche, thread message).

---

## 🛏️ Écrans LOCATAIRE (5)

### 1. `LocataireHome` — Explorer

Hero d'accueil personnalisé.

- **En-tête :** salutation contextuelle (« Bonsoir, Aïcha 👋 »), avatar 36px + bell icon.
- **Search bar pseudo-card :** quartier · dates · voyageurs (Abidjan · 12-15 nov · 2 voy.) + bouton sliders or pour filtres.
- **Filtres horizontaux :** chips scrollables (`Tout`, `Studio`, `1 chambre`, `2+ chambres`, `Avec piscine`, `Court séjour`).
- **Section "À la une" :** carrousel horizontal de cartes 220×275, ratio 4:5, badges rating + heart + "★ Hôte certifié".
- **Section "Près de vous" :** carte (map placeholder) avec **pins prix** (45k, 32k, 68k, 55k) — pin actif en accent or.
- **Section "Recommandés" :** liste verticale de `ListingCard` (carte 16:10 + métadonnées : note, surface, beds, baths, wifi, prix/nuit, total 3 nuits).

### 2. `LocataireSearch` — Filtres avancés

Sheet de filtrage modal.

- **Destination** (input texte avec icon search).
- **Dates** : 2 inputs (Arrivée / Départ) avec eyebrow + date.
- **Budget par nuit** : slider gold custom + valeur dynamique (« jusqu'à 60k FCFA »), range 10k-150k step 5k.
- **Chambres** : 5 chips (`Studio`, `1`, `2`, `3`, `4+`).
- **Équipements indispensables** : grid 2 cols de chips XL avec icône (WiFi, Parking, Sécurité, Cuisine).
- **CTA bottom fixe :** « Voir 124 logements » (btn primary lg, blur background).

### 3. `LocataireDetail` — Fiche logement

Vue détaillée d'un appartement.

- **Galerie hero :** image carrée 1:1 + indicateurs photo en bas (5 dots dont 1 actif élargi à 24px), compteur « 1/5 ».
- **Boutons flottants :** back (gauche) + share/heart (droite).
- **Bloc titre :** eyebrow type (« Loft entier »), h1 titre, ligne note + lieu.
- **Quick specs card :** 4 colonnes avec divider — lit, bain, m², voyageurs (icônes accent or).
- **Hôte card :** avatar + nom + badge "★ Certifié" + délai de réponse + btn "Contacter".
- **Description** (3-4 lignes).
- **Équipements :** grid 2 cols (5 visibles + lien « Voir les 18 équipements »).
- **Emplacement :** map avec pin animé (halo concentrique) + card adresse au-dessus de la carte.
- **Avis :** carrousel horizontal de cartes (5 étoiles, citation, avatar + nom + date).
- **Bottom bar fixe :** prix/nuit + dates + btn « Réserver » primary (flex 1).

### 4. `LocataireReserve` — Tunnel de réservation (3 étapes)

Header avec sub `Étape 1/3, 2/3, 3/3`.

**Étape 1 — Confirmer**
- Card résumé logement (img 80px + titre + lieu + note).
- Card "Votre séjour" : Dates + Voyageurs (avec icon edit).
- Card "Détail du prix" : `prix × nuits`, frais service, divider, **Total** en gras.
- Banner accent or "Annulation flexible" avec icon shield.
- CTA primary lg « Continuer vers le paiement ».

**Étape 2 — Paiement**
- Liste 4 méthodes mobile money locales : **Orange Money** (#FF6B00), **Wave** (#1DC4D5), **MTN MoMo** (#FFCC00), **Carte bancaire** (#5E6CFF).
- Chaque ligne : badge couleur 38px + nom + masque numéro + radio gold.
- Card total à payer (montant en accent or).
- CTA « Payer 159 000 FCFA ».

**Étape 3 — Confirmation**
- Cercle accent or 88px avec icon check + halo doublé concentrique.
- "Réservation confirmée !" + message hôte.
- Card code de réservation : `ASF-7K2N9` (mono, large, letter-spacing 2).
- Card récap (logement, dates, total).
- CTA primary « Voir mes réservations » + ghost « Retour accueil ».

### 5. `LocataireTrips` — Mes voyages

- 2 chips : « À venir (1) » / « Passés (2) ».
- Cards horizontales : image 110×110 gauche + content droite (badge statut, titre, dates, code mono).
- Si à venir : footer 3 boutons ghost (Hôte, Itinéraire, Reçu).

### Bonus : `SavedScreen` — Favoris (depuis app.jsx)

Grid 2 cols de cartes carrées avec heart actif en or.

---

## 🏠 Écrans PROPRIÉTAIRE (4)

### 1. `ProprietaireDashboard` — Tableau de bord

Centre de contrôle financier.

- **Greeting** : eyebrow « Bienvenue, » + h1 « Aminata K. ».
- **Hero card revenus** : gradient brun-or, halo radial top-right, eyebrow accent, montant 32px (1.9M FCFA), badge ↑ +20% vs octobre, **sparkbar 6 mois** (Juin-Nov, dernier mois en accent avec étiquette flottante).
- **KPI grid 2×2** : Occupation (84%), ADR moyen (48k), Réservations (42), Note moy. (4.91) — chacun avec delta % vs mois précédent.
- **Flux financier** : barre stack horizontale 4 segments (Locations 62%, Charges 20%, Commissions démarcheurs 12%, Frais Asfar 6%) + légende avec montants.
- **Mes annonces** : 4 cards horizontales compactes (img 64px + titre + occup% + revenus).
- **Demandes en attente** : avatar + qui (Diallo M. démarcheur / Direct: Rachid B.) + badge "NOUVEAU" + détails + arrow.

### 2. `ProprietaireFinances` — P&L détaillé

- **Period switcher** segmented control 4 options (Semaine/Mois/Trimestre/Année).
- **Bénéfice net hero** (1 178 000 FCFA, +24%).
- **Compte de résultat** :
  - `+ Revenus` (vert success) : Locations brutes (1.9M sur 42 nuits), Frais ménage facturés (84k).
  - `− Charges` (rouge danger) : Frais Asfar 6%, Commissions démarcheurs, Ménage, Eau/élec, Maintenance, Internet/TV.
  - **Bénéfice net** : 1 178k en accent or 18px + Marge nette 62% (success).
- **Performance par bien** : liste 4 cards avec barre de progress occupation + delta % par bien.
- **Projection 3 mois** : SVG line chart custom (passé solid + futur dashed + area gradient) avec 7 mois Sept→Mars, marker accent sur Nov, ligne verticale séparateur passé/futur.
- CTA secondary block « Exporter en PDF / CSV ».

### 3. `ProprietaireListings` — Mes annonces

- Chips filtre status : Tout (4), Actifs (4), En pause (0), Brouillon (1).
- Cards complètes 16:9 image + badges actif/certifié + bouton more.
- Body : titre + prix/n + lieu + 3 KPI inline (OCCUP%, NOTE★, REV.MOIS).
- Footer : 3 btns ghost (Calendrier, Modifier, Stats).
- **Card "Nouvelle annonce"** dashed outline avec cercle accent + plus + label CTA.

### 4. `ProprietaireListingEdit` — Édition d'annonce (4 onglets)

- Hero photo 16:10 + badge "8 photos" en bas-droit.
- Card stats compacte (occupation% + barre + note★).
- **Onglets underline** : Infos / Calendrier / Tarifs / Règles.
  - **Infos** : `FieldRow` (eyebrow + valeur + edit icon) — Titre, Type, Adresse, Surface, Capacité, Description.
  - **Calendrier** : grid 7×N avec couleurs pour Réservé (accent solid), En attente (accent soft), Aujourd'hui (border accent) + légende.
  - **Tarifs** : tarif de base hero + 5 FieldRow (weekend +20%, haute saison +40%, réduction semaine -10%, réduction mois -20%, frais ménage 8k).
  - **Règles** : 6 FieldRow (Arrivée 14h, Départ 11h, Animaux non, Fêtes non, Fumeurs non, Caution 50k).

---

## 🤝 Écrans DÉMARCHEUR (4)

### 1. `DemarcheurDashboard`

Centré sur les commissions.

- **Wallet hero card** : gradient bleu-nuit (`#1A2A4A → #0E1626`), halo radial bleu, montant 32px (228k FCFA ce mois), ↑ +32%.
- **Mini-stats inline** : Cumul total / En attente (warn) / Clients (27) — séparateurs verticaux.
- **CTA card or** : « Envoyer un client à un propriétaire » avec gradient subtil + icon send + arrow.
- **Status pills 3 cols** : En attente (3 warn), Acceptées (12 success), Taux acceptation (89%).
- **Mes clients référés** : liste de `ReferralRow` (img tone + client + badge statut + listing/nuits + date + commission accent à droite).
- **Logements à pousser** : carrousel horizontal de cards 200px avec commission estimée (10% du prix) + btn « Référer ».

### 2. `DemarcheurReferrals` (depuis app.jsx)

- Chips de filtre : Toutes/En attente/Acceptées/Terminées/Refusées.
- Card avec stack de `ReferralRow`.
- Btn « Nouvelle » primary sm dans top-right de la nav.

### 3. `DemarcheurNew` — Tunnel nouvelle demande (3 étapes)

**Étape 1 — Choisir un logement**
- Search bar.
- Liste de cards radio (border accent + bg accent-soft si sélectionné) : img + titre + propriétaire + prix + commission estimée.

**Étape 2 — Infos client**
- Inputs : Nom, Téléphone (WhatsApp), Dates (2 inputs Arrivée/Départ), Note libre (textarea).
- Banner accent or : commission estimée + détail (« 10% du séjour · versée après paiement »).

**Étape 3 — Confirmation**
- Cercle accent + icon send.
- Card récap : Référence (REF-D8H3K), Logement, Client, Commission accent or.

### 4. `DemarcheurReferralDetail`

- **Timeline statut** : 5 étapes verticales avec ronds (success, accent or pour étape courante "hi", grisé pour à venir) reliés par des lignes verticales.
  1. Demande envoyée
  2. Vue par le propriétaire
  3. Acceptée par Aminata K. (étape courante en or)
  4. Paiement client (en attente)
  5. Commission versée (montant à venir)
- Card listing résumée.
- Card client (avatar + nom + tel + btn "Appeler").
- Card propriétaire (avatar + nom + badge certifiée + btn "Message").
- **Card commission** : sous-total séjour 135k → 10% → **À recevoir 13 500 FCFA** (en accent or).

### 5. `DemarcheurWallet` — Mes commissions

- **Solde card** : gradient bleu-nuit, montant 36px (164 000 FCFA), texte "Versement auto vendredi sur Orange Money", btn « Retirer maintenant » sur fond translucide.
- **Historique** : liste 6 transactions (entrée/sortie), chaque ligne avec icon arrow up/down, label, sous-titre date, montant signé en accent or (entrée) ou bleu info (sortie).

---

## 🔁 Écrans transverses (4)

### `Onboarding` (extras.jsx) — Choix de rôle au lancement

- Hero radial gradient or top-left + accent bottom-right.
- Logo (carré or "A" italique + asfar).
- Headline display 32px : « Voyagez, louez, **gagnez.** » (dernier mot en accent).
- Body 15px de pitch.
- **3 cartes rôle** : Locataire (key), Propriétaire (home), Démarcheur (handshake) — chacune avec badge icon 46px accent-soft + titre + sub + arrow.
- Lien bas : « Vous avez déjà un compte ? Se connecter ».

### `MessagingList` — Conversations

Liste différenciée par rôle (locataire voit hôtes, propriétaire voit locataires + démarcheurs, démarcheur voit hôtes + clients).

- Search input.
- Card avec stack de listrows : avatar 46px + qui + badge rôle (Hôte/Locataire/Démarcheur/Asfar/Client) + sub (référence ou listing) + dernier message tronqué + heure + badge unread (cercle accent or 18px avec compteur).
- Icône **shield** accent à côté du nom si "certifié".

### `MessagingThread` — Chat 1-to-1

- Header custom : back + avatar 38px + nom + shield si certifié + sub (rôle · listing) + btn phone.
- Messages **bubbles** : me = accent or fond + texte foncé `#1A1206`, them = bg-elev-2 + texte clair, max-width 78%, radius 18px avec coin opposé à 6px (queue), heure 10px en bas.
- **Cards spéciales** dans le flow :
  - **Card "Réservation"** : img listing 56px + eyebrow RÉSERVATION + titre + dates + code mono.
  - **Card "Demande acceptée"** : fond accent-soft + check + libellé + commission (pour démarcheur).
- Input bar : btn plus + champ "Message…" + btn rond accent or send.

### `Profile` — Profil & paramètres

- **Hero card** : avatar 78px + nom + shield vérifié + sub rôle/membre + badge "★ Hôte certifié" / "Top démarcheur" si applicable.
- **Section "Changer de rôle"** : card avec 3 listrows (icon dans badge accent si actif, gris sinon) + label Actif badge ou arrow.
- **Section "Compte"** : 5 listrows (Infos perso, Vérification d'identité [Vérifié], Méthodes de paiement [3 actives], Notifications, Préférences).
- Btn secondary block en danger : « Se déconnecter ».
- Footer : « Asfar v1.0 · 🇨🇮 Côte d'Ivoire ».

---

## 📊 Données mockées clés

### `LISTINGS` (4 biens)

| ID | Titre | Ville | Quartier | Prix | Note | Beds/Baths | Surface | Tone | Superhost | Occupation | Revenu mois |
|---|---|---|---|---:|---:|---|---|---|---|---|---|
| L1 | Loft moderne — Plateau | Abidjan | Plateau | 45 000 | 4.92 | 1/1 | 38 m² | 1 (or) | ✓ | 84% | 1 245 000 |
| L2 | Studio cosy — Cocody | Abidjan | Cocody Riviera | 32 000 | 4.78 | 1/1 | 28 m² | 2 (vert) |  | 71% | 720 000 |
| L3 | Appartement vue lagune | Abidjan | Marcory Zone 4 | 68 000 | 4.95 | 2/2 | 64 m² | 3 (violet) | ✓ | 92% | 2 080 000 |
| L4 | Penthouse — Almadies | Dakar | Almadies | 120 000 | 4.97 | 3/2 | 110 m² | 4 (bleu) | ✓ | 88% | 3 500 000 |

> Toutes les annonces ont la même hôte mock : **Aminata K.**, hôte depuis 2023, note 4.9.
> Les `tone` 1-4 mappent à 4 gradients radiaux différents pour les `img-ph`.

### Méthodes de paiement supportées

Orange Money (#FF6B00), Wave (#1DC4D5), MTN MoMo (#FFCC00), Carte bancaire (#5E6CFF).

### Modèle commission

Commission démarcheur = **10% du sous-total séjour**, versée après paiement client. Versement auto **chaque vendredi sur Orange Money**.

### Modèle économique propriétaire (P&L novembre type)

| Poste | Montant (FCFA) |
|---|---:|
| Revenus locations brutes | 1 900 000 |
| Frais ménage facturés | 84 000 |
| **Total revenus** | **1 984 000** |
| Frais Asfar (6%) | 114 000 |
| Commissions démarcheurs | 228 000 |
| Ménage & blanchisserie | 168 000 |
| Eau & électricité | 92 000 |
| Maintenance | 75 000 |
| Internet & TV | 45 000 |
| **Total charges** | **722 000** |
| **Bénéfice net (Marge 62%)** | **1 178 000** |

---

## 🎨 Patterns visuels récurrents à transposer

1. **Hero cards à gradient sombre + halo radial** (or pour propriétaire, bleu-nuit pour démarcheur).
2. **Tunnels d'étapes** avec sub `Étape n/3` dans le header — pattern utilisé 2× (réservation locataire, nouvelle demande démarcheur).
3. **Confirmation success** : cercle accent 88px + icon check/send + double halo concentrique (ombres rgba).
4. **Cards de récap** post-confirmation avec rows label/valeur (la valeur est mono + bold pour les montants).
5. **Bottom bar sticky** avec `backdrop-filter: blur(20px) saturate(180%)` (Liquid Glass iOS) sur les CTAs primaires (Réserver, Continuer).
6. **Status badges** systématiques : success/warn/info/danger/accent/neutral — déclinés en fond rgba 0.14 + texte saturé.
7. **Map placeholder** avec pins prix + grid 28px + halo radial (pas de tile maps réels).
8. **Sparkbar/charts** : SVG inline, gradient sous courbe, dashed pour projections.
9. **Timeline verticale** (démarcheur referral detail) : ronds reliés par lignes, état coloré par étape.
10. **Mobile money colorés** : chaque opérateur a sa couleur signature, fond rgba 0.14 + initiales en monogram.

---

## 📝 Notes pour l'implémentation Flutter

> Le fichier compagnon **`02-flutter-component-priority.md`** liste les widgets à créer en priorité, mappés aux écrans ci-dessus.

- Le prototype est **400×874 px viewport** — caler les breakpoints mobile sur ces dimensions.
- Pas d'images binaires : tout est gradient CSS, donc transposable en `LinearGradient` / `RadialGradient` Flutter sans assets.
- Les icônes sont des paths SVG inline 24×24 stroke 1.8 — utilisables avec `flutter_svg` ou redessinables en `CustomPainter`.
- Tous les montants sont des **entiers FCFA** sans décimales, formatés `1 900 000 FCFA` (espaces) ou `1.9 M FCFA` / `45 k FCFA` (compact).
- Letter-spacing négatif marqué sur les titres → utiliser `TextStyle(letterSpacing: -0.4)`.
