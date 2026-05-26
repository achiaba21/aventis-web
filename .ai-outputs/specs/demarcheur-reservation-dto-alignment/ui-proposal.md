# 🎨 Design UI Validé — Alignement Démarcheur (R4)

**Feature** : `demarcheur-reservation-dto-alignment`
**Date** : 2026-05-21
**Validée par** : utilisateur

---

## Option choisie : A — Masquage complet

Pour les réservations de type `MANUELLE` (client externe passé par le proprio), la section « Client » de `ReferralDetailScreen` est **entièrement masquée**. Le scroll passe directement de la section « Logement » à la section « Propriétaire ».

### Justification

Cohérent avec la directive métier R4 : *« seuls l'appartement, les dates, le statut et la commission sont visibles »*. C'est l'implémentation la plus simple, la plus lisible et qui n'introduit aucun nouveau pattern visuel.

---

## Placement

```
Statut
[ ✓ Acceptée ]

Timeline ...

Logement
┌──────────────────────────┐
│ Appart A-102             │
│ Plateau, Abidjan         │
│ 35 000 F / nuit          │
└──────────────────────────┘

Propriétaire              ← saut direct, pas de section Client
┌──────────────────────────┐
│ 👤  John Doe             │
│     Membre depuis 2024   │
│         [📞 Contacter]   │
└──────────────────────────┘

Commission
┌──────────────────────────┐
│ Sous-total : 140 000 F   │
│ Commission :  10 000 F   │
└──────────────────────────┘
```

---

## Composants à Créer

Aucun.

## Composants à Réutiliser

- `HostCard` (lib/screen/client/locataire/booking/widget/host_card.dart) — inchangé
- `ListingSummaryCard` (lib/screen/client/locataire/booking/widget/listing_summary_card.dart) — inchangé
- `CommissionCard` (lib/screen/client/demarcheur/referrals/widget/commission_card.dart) — inchangée
- `ReferralTimeline`, `BadgeStatus` — inchangés
- `ReferralClientCard` — **conservée** pour les autres types (DEMARCHEUR, PLATEFORME), simplement non affichée pour MANUELLE

## Contraintes Visuelles

- Aucun nouveau token, aucune nouvelle couleur, aucune nouvelle icône
- Pas de divider supplémentaire entre Logement et Propriétaire (l'espacement existant `SizedBox(height: 22)` est conservé via les `...[]` spread conditionnel)
- Le `SizedBox(height: 22)` qui suit la section Client doit aussi être conditionné, sinon double espacement vide

---

## Logique d'implémentation côté code

Dans `ReferralDetailScreen.build()`, autour de la section « Client » :

```dart
if (!reservation.isClientConfidential) ...[
  const Text('Client', style: AppTextStyles.h3),
  const SizedBox(height: 10),
  ReferralClientCard(
    name: reservation.referralClientName,
    phone: reservation.referralClientPhone,
  ),
  const SizedBox(height: 22),
],
```

Le getter `isClientConfidential` est défini dans l'extension `ReferralDisplay` (cf. architecture.md §5.2).
