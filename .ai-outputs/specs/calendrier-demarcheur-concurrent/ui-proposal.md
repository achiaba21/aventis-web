# Design UI Validé

**Option choisie :** B (badge + bottom sheet)

## 1. _DayCell — Badge points sous le numéro

- Numéro du jour centré (existant)
- Sous le numéro : points "···" (max 3) ou "N+" en 9px
- Cas C : points orange (#FFA02A)
- Cas D : points amber + fond cellule amber[700] avec légère différence

```
┌──────────┐
│          │
│   15     │  ← TextSeed numéro
│   ···    │  ← Row de petits cercles 4px ou Text "N+"
└──────────┘
```

## 2. DemarcheursEnAttenteBottomSheet — Header coloré

- Handle bar standard
- Bande header colorée : orange (Cas C) ou amber (Cas D)
- Icône horloge + "N demandes en attente"
- Liste items : avatar initiale 44px, nom, téléphone, montant FCFA, durée nuits
- Bouton "Créer ma réservation" pleine largeur orange — visible Cas C seulement

## Contraintes Visuelles

- Surface cards : #2A2A2A (identique à DemandeEnvoyeeItem)
- Avatar : circle 44px, fond primaryColor.withOpacity(0.15), initiale orange
- TextSeed pour tous les textes
- borderRadius bottom sheet : 20px top
- Padding horizontal : 16px
- Espacement entre items : 8px
