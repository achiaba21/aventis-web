# 📋 Spécification Métier - Cache des Favoris

## 1. Contexte

Actuellement, la page favoris affiche un skeleton/loader à chaque ouverture car seuls les **IDs** des favoris sont cachés localement. Les **détails des appartements** sont rechargés depuis l'API à chaque fois, créant une latence perceptible.

## 2. Objectif

Permettre un affichage **instantané** de la page favoris en cachant localement les objets `Appartement` complets, puis synchroniser en arrière-plan avec le serveur.

## 3. Acteurs

- **Utilisateur** (locataire) : consulte ses appartements favoris

## 4. Règles Métier

- Un appartement est **favori** si son ID est présent dans la liste des IDs favoris
- Les appartements favoris complets sont stockés dans le cache local (Hive/StorageService existant)
- Le cache est mis à jour **en arrière-plan** sans bloquer l'affichage
- L'utilisateur peut voir des données légèrement obsolètes avant la synchronisation

## 5. Cas d'Usage Principal

1. L'utilisateur ouvre la page favoris
2. Si le cache contient des appartements favoris → **affichage instantané**
3. En parallèle, synchronisation avec le serveur en arrière-plan
4. Si nouvelles données → mise à jour de l'affichage et du cache

## 6. Cas Alternatifs / Limites

- **Cache vide** (première utilisation) : afficher un loader, charger depuis le serveur, puis cacher
- **Mode hors-ligne** : afficher les données du cache sans erreur
- **Toggle favori** : mettre à jour le cache immédiatement (ajouter/retirer l'appartement)

## 7. Contraintes

- Utiliser le système de stockage existant (Hive/StorageService)
- Conserver la compatibilité avec le pattern optimistic update existant
- Ne pas bloquer l'UI pendant la synchronisation

## 8. Critères d'Acceptation

- [ ] La page favoris affiche instantanément les données cachées (si disponibles)
- [ ] La synchronisation serveur se fait en arrière-plan
- [ ] Le cache est mis à jour lors d'un toggle favori
- [ ] Le mode hors-ligne fonctionne (affiche le cache)
- [ ] Première utilisation : loader puis chargement serveur

---

*Validé par l'utilisateur le 2026-01-19*
