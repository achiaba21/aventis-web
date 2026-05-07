# Design UI Validé — Système de Partenariat

**Option choisie :** B (formulaire inline)

## Côté Démarcheur — DemarcheurPartenariatScreen

### Placement
- AppBar "Partenariats" + bouton refresh
- Formulaire inline en haut : champ téléphone + bouton envoi (toujours visible)
- Liste des demandes envoyées en dessous

### Layout
```
AppBar: "Partenariats" [refresh]
─────────────────────────────────
Card formulaire:
  📱 Numéro du propriétaire
  [TextField__________________] [→ Envoyer]
─────────────────────────────────
ListView demandes envoyées:
  Card: avatar lettre / nom proprio / téléphone / date / badge statut
```

### Composants à Créer
- DemarcheurPartenariatScreen (screen principal)
- EnvoyerDemandeForm (widget formulaire inline — champ téléphone + bouton)
- DemandeEnvoyeeItem (card demande envoyée avec badge statut)

## Côté Propriétaire — ProprioPartenariatScreen

### Placement
- AppBar "Partenariats" + bouton refresh
- ListView des demandes reçues

### Layout
```
AppBar: "Demandes partenariat" [refresh]
─────────────────────────────────
ListView demandes reçues:
  Card EN_ATTENTE: avatar / nom démarcheur / téléphone / date
                   [Refuser]  [Accepter]
  Card traitée:    avatar / nom démarcheur / badge ACCEPTÉE ou REFUSÉE
```

### Composants à Créer
- ProprioPartenariatScreen (screen principal)
- DemandeRecueItem (card avec boutons Accepter/Refuser si EN_ATTENTE, sinon badge)

## Composants à Réutiliser
- TextSeed (textes)
- Style.containerColor3 (fond)
- Color(0xFF2A2A2A) (couleur card)
- Pattern avatar cercle 44px (lettre initiale, fond primary 15%)
- Pattern badge statut pill (bordure + fond coloré, radius 20)
- Espacement.paddingBloc / Espacement.gapSection

## Contraintes Visuelles
- Fond écran : Style.containerColor3 (#1D1D1D)
- Cards : #2A2A2A, borderRadius 12, padding 16
- AppBar : #1D1D1D, elevation 0
- Badge EN_ATTENTE : orange (#FFA02A)
- Badge ACCEPTEE : vert (Style.successColor #4CAF50)
- Badge REFUSEE : rouge (Style.errorColor)
- Bouton Accepter : Style.primaryColor (orange)
- Bouton Refuser : gris/neutre (pas rouge — action non destructive)
- Champ téléphone : fond #1D1D1D, border none, hint gris
