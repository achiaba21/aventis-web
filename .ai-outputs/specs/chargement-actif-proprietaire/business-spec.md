# Spécification Métier : Chargement Actif du Propriétaire

## 1. Contexte

Le serveur filtre les données sensibles du propriétaire (nom, téléphone) et ne les renvoie que si le locataire a une réservation payée. Actuellement, l'app ne charge pas ces infos dynamiquement, donc même avec une réservation payée, les infos du propriétaire ne s'affichent pas.

## 2. Objectif

Charger les infos du propriétaire à la demande quand le locataire accède à la page de détail d'un appartement, avec mise en cache locale pour éviter les appels répétés.

## 3. Acteurs

- **Locataire** avec réservation payée → voit les infos du propriétaire
- **Locataire** sans réservation payée → la zone propriétaire est masquée

## 4. Règles Métier

- Le chargement se déclenche à l'ouverture de la page détail appartement
- Le serveur vérifie le statut de paiement avant de renvoyer les infos
- Les infos sont mises en cache localement (persiste entre sessions)
- Si le cache contient déjà les infos, pas de nouvel appel serveur
- Si le serveur refuse l'accès, la zone propriétaire disparaît complètement

## 5. Cas d'Usage Principal

1. Locataire ouvre la page détail d'un appartement
2. L'app vérifie si les infos du propriétaire sont en cache local
3. Si non en cache → appel serveur pour récupérer les infos
4. Serveur vérifie si réservation payée existe
5. Si oui → renvoie les infos, stockées en cache, affichées
6. Si non → renvoie erreur/vide, zone propriétaire masquée

## 6. Cas Alternatifs / Limites

- **Cache présent** : Affichage immédiat, pas d'appel serveur
- **Erreur réseau** : Zone propriétaire masquée
- **Serveur refuse** : Zone propriétaire masquée (pas de placeholder)

## 7. Contraintes

- Cache persistant (stockage local type Hive)
- Clé de cache : combinaison `appartementId` ou `residenceId`
- Ne pas bloquer l'affichage de la page pendant le chargement

## 8. Critères d'Acceptation

- [ ] Locataire avec réservation payée voit les infos du propriétaire
- [ ] Locataire sans réservation payée ne voit pas la zone propriétaire
- [ ] Les infos sont mises en cache localement
- [ ] Pas de rechargement si déjà en cache
- [ ] L'affichage de la page n'est pas bloqué pendant le chargement

## 9. Exigences Serveur

Le serveur doit exposer un endpoint qui :
- Reçoit l'ID de l'appartement (ou résidence)
- Vérifie si l'utilisateur connecté a une réservation PAYÉE pour cet appartement
- Si oui : renvoie les infos du propriétaire (nom, prénom, téléphone, photo)
- Si non : renvoie une erreur 403 ou un objet vide
