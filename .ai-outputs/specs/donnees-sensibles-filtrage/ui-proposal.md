# UI/UX Proposal - Données Sensibles Filtrées

## Option Choisie : B - Call-to-Action

### Design du SensitiveDataPlaceholder

```
┌─────────────────────────────────────────────┐
│  ┌────┐                                     │
│  │ 🔒 │  Localisation masquée               │
│  └────┘  ──────────────────────────────     │
│          📍 Réserver pour voir l'adresse    │
│                                          →  │
└─────────────────────────────────────────────┘
```

### Spécifications

- **Fond** : `#2A2A2A`
- **Bordure** : `primaryColor.withOpacity(0.3)`
- **Icône principale** : Container avec fond `primaryColor.withOpacity(0.1)`
- **Message** : Blanc, fontSize 14
- **Action label** : `primaryColor`, fontWeight bold, fontSize 13
- **Flèche** : `Icons.arrow_forward_ios`, `primaryColor`, size 16
- **Padding** : `Espacement.paddingBloc` (16)
- **Border radius** : 12

### Variantes

1. **GPS masqué** : icône `Icons.location_off`, message "Localisation masquée"
2. **Proprio masqué** : icône `Icons.person_off`, message "Informations du propriétaire"
3. **Locataire attente** : icône `Icons.hourglass_empty`, couleur orange, message "En attente de paiement"

---

*Validé le 25 décembre 2024*
