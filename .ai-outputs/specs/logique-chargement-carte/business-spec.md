# Spécification Métier - Logique de Chargement Carte

## 1. Contexte

L'écran carte affiche actuellement des données qui ne correspondent pas à la logique métier attendue. Les résidences (et non les appartements individuels) doivent être affichées sur la carte, en utilisant les données déjà disponibles dans le cache de l'explore.

## 2. Objectif

Afficher sur la carte les **résidences** géolocalisées provenant de l'explore, avec possibilité de centrer la carte sur une position choisie par l'utilisateur.

## 3. Acteurs

- **Locataire** : consulte la carte pour visualiser les résidences disponibles

## 4. Règles Métier

- Afficher les **résidences** (pas les appartements) sur la carte
- Utiliser les données du cache de l'explore comme source
- **Filtrer** les résidences sans coordonnées GPS (ne pas les afficher)
- Une résidence = un marker (même si elle contient plusieurs appartements)
- Le prix affiché sur le marker = prix minimum de la résidence

## 5. Cas d'Usage Principal

1. L'utilisateur ouvre l'écran carte
2. Le système charge les résidences depuis le cache explore
3. Le système filtre les résidences sans coordonnées
4. Les résidences géolocalisées s'affichent comme markers
5. L'utilisateur peut centrer sur sa géolocalisation OU choisir un point manuellement

## 6. Cas Alternatifs / Limites

- **Aucune résidence géolocalisée** : afficher un message "Aucune résidence disponible dans cette zone"
- **Cache explore vide** : charger les données depuis l'API
- **Pas de coordonnées** : la résidence n'apparaît simplement pas sur la carte

## 7. Contraintes

- Réutiliser le cache existant de l'explore (pas de double appel API)
- Le rechargement au déplacement de carte = future mise à jour (hors scope)

## 8. Critères d'Acceptation

- [ ] Les résidences s'affichent (pas les appartements)
- [ ] Seules les résidences avec coordonnées GPS sont visibles
- [ ] Les données proviennent du cache explore
- [ ] L'utilisateur peut centrer sur sa position GPS
- [ ] L'utilisateur peut choisir manuellement un point sur la carte
- [ ] Le marker affiche le prix minimum de la résidence

---

*Validé par l'utilisateur le 25/12/2024*
