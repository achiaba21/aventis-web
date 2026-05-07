# 📋 Spécification Métier - Système de Compte Propriétaire

## 1. Contexte

Les propriétaires de biens sur la plateforme Asfar reçoivent des paiements via les réservations. Ils ont besoin de visualiser et gérer leurs fonds directement depuis l'application mobile.

## 2. Objectif

Permettre au propriétaire de consulter son compte, suivre ses transactions et effectuer des demandes de retrait depuis l'application mobile.

## 3. Acteurs

- **Propriétaire** : Utilisateur principal qui gère son compte

## 4. Règles Métier

- Le compte possède deux soldes : **solde disponible** et **montant verrouillé** (avances en attente)
- Le déverrouillage des fonds est géré automatiquement par le serveur
- Les notifications sont gérées par le serveur
- Aucune contrainte de montant minimum/maximum pour les retraits
- Le compte peut être actif ou suspendu (géré par le serveur)

## 5. Cas d'Usage Principal

1. Le propriétaire accède à son espace compte
2. Il visualise son solde disponible et le montant en attente
3. Il consulte l'historique de ses transactions
4. Il peut demander un retrait de ses fonds disponibles

## 6. Cas Alternatifs / Limites

- **Compte suspendu** : Afficher un message, bloquer les actions
- **Solde insuffisant** : Empêcher la demande de retrait
- **Erreur réseau** : Afficher un message et permettre de réessayer

## 7. Contraintes

- L'application consomme les API serveur existantes
- Toute la logique métier complexe reste côté serveur

## 8. Critères d'Acceptation

- [ ] Le propriétaire peut voir son solde disponible
- [ ] Le propriétaire peut voir son montant verrouillé (en attente)
- [ ] Le propriétaire peut consulter l'historique des transactions
- [ ] Le propriétaire peut demander un retrait
- [ ] Les erreurs sont gérées avec des messages clairs

## 9. Données Serveur (référence)

### CompteProprietaire
| Champ         | Type          | Description                                |
|---------------|---------------|--------------------------------------------|
| id            | Integer       | Identifiant auto-généré                    |
| numero        | String        | Numéro unique (ex: PRO-[timestamp]-[uuid]) |
| solde         | Double        | Solde du compte principal                  |
| actif         | Boolean       | Statut actif/suspendu                      |
| compteAttente | CompteAttente | Sous-compte pour fonds bloqués             |
| proprietaire  | Proprietaire  | Lien vers le propriétaire                  |

### CompteAttente
| Champ            | Type   | Description                              |
|------------------|--------|------------------------------------------|
| solde            | Double | Solde disponible                         |
| montantVerrouille| Double | Fonds bloqués (avances de réservation)   |

---

*Spécification validée par l'utilisateur le 2025-12-24*
