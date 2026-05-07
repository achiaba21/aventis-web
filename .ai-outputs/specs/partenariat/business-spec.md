# Spécification Métier — Système de Partenariat Démarcheur / Propriétaire

## 1. Contexte

Les démarcheurs travaillent pour des propriétaires partenaires. Actuellement, il n'existe pas de mécanisme dans l'app pour établir ce lien. Cette fonctionnalité permet au démarcheur d'initier une relation de partenariat avec un propriétaire via son numéro de téléphone, et au propriétaire d'accepter ou refuser la demande.

## 2. Objectif

Permettre à un démarcheur d'envoyer une demande de partenariat à un propriétaire. Le propriétaire peut accepter ou refuser. Une fois accepté, le serveur gère les accès (appartements visibles, etc.). Chaque acteur dispose d'un onglet dédié dans sa barre de navigation pour gérer ses demandes.

## 3. Acteurs

- **Démarcheur** : envoie des demandes, consulte l'historique de ses demandes envoyées.
- **Propriétaire** : consulte les demandes reçues, accepte ou refuse chaque demande.

## 4. Règles Métier

- Le démarcheur envoie une demande en saisissant le numéro de téléphone du propriétaire.
- Si le numéro ne correspond à aucun propriétaire → erreur affichée.
- Si un partenariat existe déjà → erreur affichée.
- Si une demande est déjà EN_ATTENTE → erreur affichée.
- Si la dernière demande a été REFUSEE → délai d'1h avant renvoi. Le serveur retourne un message indiquant le temps restant.
- Le démarcheur ne peut pas annuler une demande envoyée.
- Le propriétaire peut Accepter ou Refuser chaque demande EN_ATTENTE.
- Les statuts possibles : EN_ATTENTE, ACCEPTEE, REFUSEE.
- Toutes les erreurs serveur sont affichées telles quelles à l'utilisateur.

## 5. API Serveur

### Endpoints Démarcheur
- POST /api/demarcheur/partenariat/demande — { "telephone": "string" }
- GET /api/demarcheur/partenariat/demandes

### Endpoints Propriétaire
- GET /api/proprietaire/partenariat/demandes
- POST /api/proprietaire/partenariat/demandes/{id}/accepter
- POST /api/proprietaire/partenariat/demandes/{id}/refuser

### Modèle DemandePartenariat
```json
{
  "id": 1,
  "createdAt": "2026-03-07T08:00:00",
  "updatedAt": "2026-03-07T08:00:00",
  "demarcheur": { "id": 5, "nom": "...", "telephone": "...", "type": "Demarcheur" },
  "proprietaire": { "id": 3, "nom": "...", "telephone": "...", "type": "Proprietaire" },
  "statut": "EN_ATTENTE",
  "repondueAt": null
}
```

### Erreurs (400)
- "Aucun propriétaire avec ce numéro"
- "Vous êtes déjà partenaire avec ce propriétaire"
- "Une demande est déjà en cours"
- "Vous devez attendre X minute(s) avant de renvoyer une demande"
- "Demande non trouvée"
- "Cette demande ne vous appartient pas"
- "Cette demande a déjà été traitée"

## 6. Cas d'Usage — Démarcheur

1. Ouvre l'onglet "Partenariats" dans sa barre de navigation.
2. Voit la liste de ses demandes envoyées avec leur statut.
3. Saisit le numéro de téléphone d'un propriétaire et envoie une demande.
4. En cas d'erreur, le message serveur est affiché.
5. La nouvelle demande apparaît dans la liste avec le statut EN_ATTENTE.

## 7. Cas d'Usage — Propriétaire

1. Ouvre l'onglet "Partenariats" dans sa barre de navigation.
2. Voit la liste des demandes reçues avec le nom du démarcheur et le statut.
3. Sur une demande EN_ATTENTE, peut Accepter ou Refuser.
4. Le statut se met à jour en conséquence.

## 8. Cas Alternatifs / Limites

- Erreur réseau → message générique, liste conservée.
- Demande déjà traitée (ACCEPTEE/REFUSEE) → boutons Accepter/Refuser non visibles.
- Liste vide → état vide affiché avec message explicatif.

## 9. Contraintes

- Affichage des messages d'erreur serveur tels quels.
- Le délai de renvoi (1h) est géré et communiqué par le serveur.
- L'impact du partenariat accepté est géré côté serveur uniquement.

## 10. Critères d'Acceptation

- [ ] Le démarcheur peut envoyer une demande via un numéro de téléphone.
- [ ] Les erreurs serveur sont affichées correctement.
- [ ] Le démarcheur voit l'historique de ses demandes avec leur statut.
- [ ] Le propriétaire voit les demandes reçues avec nom du démarcheur et statut.
- [ ] Le propriétaire peut accepter une demande EN_ATTENTE.
- [ ] Le propriétaire peut refuser une demande EN_ATTENTE.
- [ ] Les demandes déjà traitées n'affichent pas les boutons d'action.
- [ ] Un onglet dédié est présent dans la nav bar de chaque acteur.
