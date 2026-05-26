# 📄 Notes Backend — Page Détail Réservation

> **Date initiale :** 2026-05-12 (extension réservation manuelle 2026-05-15)
> **Feature liée :** `reservation-detail-screen` + `calendrier-bookings-proprio`
> **Statut V1 Flutter :** ✅ livré sans dépendance backend bloquante

---

## 0. Création réservation manuelle — payload étendu — 💡 COORDINATION REQUISE

### Contexte

Depuis la feature `calendrier-bookings-proprio` (2026-05-15), le wizard de création de réservation manuelle envoie 3 champs supplémentaires sur l'endpoint existant `createManualReservation` :

- `source: string` (enum `CLIENT_DIRECT` ou `DEMARCHEUR_PARTENAIRE`)
- `moyenPaiement: string` (enum `ESPECES` / `WAVE` / `OM` / `VIREMENT` — tracking proprio)
- `demarcheurId: int?` (requis uniquement si `source == DEMARCHEUR_PARTENAIRE`)

### Comportement actuel (V1)

Si le backend ignore silencieusement ces champs (parser tolérant), tout fonctionne :
- La réservation est créée comme avant côté serveur.
- Côté Flutter, les champs `source` et `moyenPaiement` ne sont pour l'instant pas relus depuis le DTO retourné. Le proprio voit la réservation comme avant. Aucune dégradation.

### Demande backend

1. **Accepter ces 3 nouveaux champs** dans le payload `POST /api/user/reservations/owner/manual/create` (ou équivalent) sans erreur.
2. **Persister `source` et `moyenPaiement`** sur `ReservationManuelle` côté base (colonnes `source: enum`, `moyen_paiement: enum`).
3. **Si `source == DEMARCHEUR_PARTENAIRE`** :
   - Persister `demarcheur_id` (FK Démarcheur)
   - Calculer `montantCommission = montant × 0.10` côté serveur (vérification du taux à confirmer)
   - Émettre la résa avec `type = DEMARCHEUR` au lieu de `MANUELLE` ? À discuter avec l'équipe métier.
4. **Si `source == CLIENT_DIRECT`** : aucune commission, type `MANUELLE` actuel.

### Format JSON envoyé par Flutter

```json
{
  "appartId": 12,
  "debut": "2026-11-16T00:00:00.000",
  "dure": 1,
  "clientNom": "Madame Touré",
  "clientTelephone": "+225 07 12 34 56",
  "montant": 68000,
  "source": "CLIENT_DIRECT",
  "moyenPaiement": "WAVE",
  "demarcheurId": null
}
```

### Priorité

**Moyenne** — la livraison Flutter fonctionne d'ores et déjà (champs supplémentaires ignorés tant que non implémentés). Devient nécessaire dès que la commission démarcheur sur résa manuelle devient un cas réel.

---

## 1. Édition d'une réservation manuelle — ⚠️ NOUVEL ENDPOINT REQUIS

### Besoin
Le propriétaire peut modifier les dates et les coordonnées du client externe d'une `ReservationManuelle` tant que le statut est `EN_ATTENTE` ou `CONFIRMER`. Dès le passage à `PAYER`, l'édition doit être verrouillée.

### Spec endpoint attendue
```
PUT /api/user/reservations/owner/manual/{reference}
Authorization: Bearer <proprio token>
Content-Type: application/json

Body :
{
  "appartId": 12,
  "debut": "2026-06-12T00:00:00Z",
  "dure": 3,
  "clientNom": "Aya Konan",
  "clientTelephone": "+22507991234",
  "clientEmail": "aya@example.com",
  "montant": 65000
}
```

### Règles backend
- ✅ Seul le propriétaire de l'appartement lié peut éditer.
- ✅ Refuser avec `409 Conflict` si `reservation.statut ∉ {EN_ATTENTE, CONFIRMER}` — body : `{"message": "Édition impossible pour ce statut"}`.
- ✅ Refuser avec `400` si dates incohérentes (fin ≤ début).
- ✅ La référence (`reference`) reste **inchangée** après update (préserve la cohérence des cards chat et notifications).
- ✅ Retourne la `Reservation` mise à jour (même format que les autres endpoints, body wrapping `{body: {...}, message}`).

### Côté Flutter (déjà livré)
- `ReservationService.updateManualReservation(reference, ReservationManuelleReq)`
- Le bouton « Modifier » de l'action bar pousse `ReservationEditManuelleScreen`
- L'action est exclue de la matrice dès le statut `payée` (`ReservationActionsResolver`)

---

## 2. Champs timestamp par transition — 💡 SOUHAITABLE POUR V2

### Besoin
La timeline d'historique de la page détail (section `HISTORIQUE`) reconstruit aujourd'hui l'ordre des transitions à partir du statut courant **sans dates précises** (sauf `createdAt`). Les dates précises permettraient un affichage type « Confirmée le 5 mai 2026 ».

### Champs proposés sur l'entité `Reservation`
```java
// Tous nullable — déclenchés par les méthodes de transition côté service
private Instant confirmedAt;
private Instant paidAt;
private Instant finalizedAt;
private Instant terminatedAt;
private Instant refusedAt;
private Instant cancelledAt;
```

### Sérialisation JSON attendue
```json
{
  "id": 102,
  "reference": "ASF-7K2N9",
  "statut": "PAYER",
  "createdAt": "2026-05-03T10:14:00Z",
  "confirmedAt": "2026-05-05T15:22:00Z",
  "paidAt": "2026-05-07T09:01:00Z",
  ...
}
```

### Impact Flutter (V2 sans rupture)
- Mise à jour de `Reservation.fromJsonCommon` pour parser les nouveaux champs.
- Mise à jour de `ReservationTimelineBuilder` pour utiliser ces dates au lieu de `null`.
- Aucune modification de l'UI nécessaire (juste la date passe de masquée à visible).

### Priorité
**Non bloquant V1** — la timeline fonctionne aujourd'hui avec `createdAt` + ordre logique + motif pour refus/annulation. À planifier en V2 ou quand un sprint backend touche aux services de réservation.

---

## 3. Contrôle d'accès `GET /api/user/reservations/{ref}` — 🔒 À RECONFIRMER

### Contexte
La page détail s'ouvre désormais aussi via deep-link push notif (référence seule). Il faut s'assurer que l'endpoint `getByReference` (déjà existant V9.2) :

- ✅ Autorise le **locataire** lié à la résa.
- ✅ Autorise le **propriétaire** de l'appartement.
- ✅ Autorise le **démarcheur source** (`ReservationDemarcheur.demarcheur`).
- ❌ Refuse avec `403` tout autre user authentifié.

### Côté Flutter
La page affiche un `ReservationDetailErrorView` (« Réservation introuvable ») si le backend retourne 403/404. Pas d'action requise Flutter si la règle est en place.

---

## 4. Sérialisation polymorphique `ReservationDemarcheur` — ✅ DÉJÀ TRAITÉ V9.2

Rappel : pour que la card « Démarcheur source » affiche correctement nom + commission côté proprio, le payload JSON doit inclure :

```json
{
  "type": "DEMARCHEUR",
  "demarcheur": {
    "id": 12,
    "prenom": "K.",
    "nom": "Diallo",
    "telephone": "+22507991234"
  },
  "montantCommission": 2500
}
```

Voir `BACKEND_NOTES_FINANCES_PDF.md` §1 pour les détails Hibernate `@Inheritance(TABLE_PER_CLASS)` + `@JsonTypeInfo`.

---

## 5. Récapitulatif

| Besoin | Priorité | État |
|--------|----------|------|
| `PUT /owner/manual/{ref}` | Haute | ⏳ À implémenter backend |
| Champs timestamps timeline | Basse (V2) | 📝 À planifier |
| Contrôle d'accès `GET /{ref}` | Critique | 🔍 À vérifier (existant V9.2) |
| Sérialisation polymorphique | Haute | ✅ Spec déjà documentée |
