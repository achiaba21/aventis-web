# 📄 Notes Backend — Export PDF/CSV Finances proprio

> **Date initiale :** 2026-05-12
> **Mise à jour 2026-05-12 (post-livraison Phase A modèle)** : confirmation que le backend expose bien `ReservationDemarcheur.demarcheur` et `ReservationDemarcheur.montantCommission` via l'héritage `@Inheritance(TABLE_PER_CLASS)`. Côté Flutter, le modèle a été refondu en sous-classes mirroring (`ReservationPlateforme`, `ReservationManuelle`, `ReservationDemarcheur`).

---

## 1. Démarcheur source d'une réservation — ✅ RÉSOLU CÔTÉ BACKEND

### Constat initial (obsolète)
On pensait que le modèle `Reservation` ne portait pas le démarcheur source.

### Réalité backend confirmée
Le backend utilise un **héritage Hibernate** :
```java
@Inheritance(strategy = InheritanceType.TABLE_PER_CLASS)
public abstract class Reservation { ... }

@Entity
public class ReservationDemarcheur extends Reservation {
    @ManyToOne private Demarcheur demarcheur;
    private Double montantCommission;
}
```

Donc :
- ✅ `r.demarcheur` est exposé pour les `ReservationDemarcheur`
- ✅ `r.montantCommission` est sur la sous-classe (réel, pas calculé)

### Côté Flutter (livré)
- `Reservation` est désormais une classe `abstract`
- `factory Reservation.fromJson()` polymorphique selon `json['type']`
- 3 sous-classes : `ReservationPlateforme`, `ReservationManuelle`, `ReservationDemarcheur`
- L'annexe PDF page 4 pourra afficher `r.demarcheur?.fullName` quand `r is ReservationDemarcheur`

### Vérification serveur
**Vérifier que le JSON sérialisé d'une `ReservationDemarcheur` inclut bien** :
```json
{
  "id": 102,
  "type": "DEMARCHEUR",
  "prix": 25000,
  "demarcheur": {
    "id": 12,
    "nom": "Diallo",
    "prenom": "K.",
    "telephone": "+22507991234"
  },
  "montantCommission": 2500
}
```

Côté Spring, vérifier la sérialisation Jackson polymorphique. Si nécessaire, ajouter `@JsonTypeInfo` sur la classe abstraite ou personnaliser le serializer.

---

## 2. Sémantique du champ `frais` sur Reservation

### À clarifier
- `r.frais: Double` est défini sur `Reservation` parent
- Sémantique exacte : frais Asfar (commission plateforme 6%) ? Autre type ?

### Impact
- Si frais Asfar uniquement → côté Flutter on peut retirer le calcul `_fraisAsfarRate = 0.06` et utiliser directement `sum(r.frais)`.
- Si autre chose → garder l'architecture mais documenter.

### Demande backend
Documenter dans le DTO la sémantique exacte de `frais`.

---

## 3. Champ `proprio` côté Flutter — orphelin actuel

### Constat
`Reservation` côté backend a `proprio` **commenté** (jamais peuplé). Côté Flutter, le champ existe et est utilisé par `referral_detail_screen.dart` (affichage hôte côté démarcheur).

### Workaround actuel
Le champ Flutter est gardé pour ne pas casser `referral_detail_screen` — il sera toujours `null`.

### Demande backend
Soit :
- A. Exposer `proprio: Proprietaire` sur `Reservation` (relation directe)
- B. Exposer `proprio` sur `Appartement` (chemin alternatif via `r.appart.proprio`)
- C. Créer endpoint `GET /api/appartement/{id}/proprio` (lookup séparé)

Option B serait la plus naturelle vu qu'un appart appartient à un proprio (1:N).

---

## 4. Champ `numeroCompte` côté Flutter — supprimé ✅

Le champ `numeroCompte` côté Flutter n'existait pas côté backend. Supprimé car orphelin sans usage.

---

## 5. Champ `motif` côté backend — ajouté Flutter ✅

`Reservation.motif` existe côté backend (probablement pour justifier une annulation/manuelle). Ajouté côté Flutter pour parité.

---

## 6. Récap actions

| Action | Owner | Statut |
|---|---|---|
| Confirmer sérialisation polymorphique JSON `ReservationDemarcheur.demarcheur` + `montantCommission` | Backend | À valider runtime |
| Documenter sémantique de `Reservation.frais` | Backend | En attente |
| Exposer `proprio` sur Reservation ou Appartement | Backend | En attente |
| Refactor modèle Flutter abstract + sous-classes | Flutter | ✅ Livré |
| Recalibrer commission démarcheur (vrai montant) | Flutter | ✅ Livré (extension `demarcheurCommissionAmount`) |
| Cleanup `numeroCompte` orphelin | Flutter | ✅ Livré |
| Ajouter `motif` au modèle | Flutter | ✅ Livré |
