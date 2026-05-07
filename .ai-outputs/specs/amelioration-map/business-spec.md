# Spécification Métier : Amélioration de la Map

## 1. Contexte

La map actuelle souffre d'un design daté avec trop de couleurs, ce qui la rend difficile à utiliser. L'expérience utilisateur doit être améliorée tant visuellement que fonctionnellement.

## 2. Objectif

Moderniser les deux maps de l'application (détail appartement + exploration) avec un design épuré et des fonctionnalités de géolocalisation et recherche par zone.

## 3. Acteurs

- **Locataire** : Recherche et visualise les appartements sur la carte
- **Propriétaire** : Visualise la localisation de ses biens

## 4. Règles Métier

- La carte doit avoir un style visuel cohérent avec le reste de l'app
- Les markers doivent être distinctifs et lisibles
- La géolocalisation nécessite l'autorisation de l'utilisateur
- La recherche par zone doit filtrer les appartements visibles

## 5. Cas d'Usage Principal

1. L'utilisateur ouvre la map d'exploration
2. Il autorise la géolocalisation (optionnel)
3. La carte se centre sur sa position ou sur une zone par défaut
4. Il peut dessiner/sélectionner une zone pour filtrer les appartements
5. Les markers affichent les appartements disponibles avec un design moderne
6. Il clique sur un marker pour voir les détails

## 6. Cas Alternatifs / Limites

- **Géolocalisation refusée** : Utiliser une position par défaut (centre-ville)
- **Aucun appartement dans la zone** : Afficher un message informatif
- **Erreur de chargement carte** : Afficher un placeholder avec retry

## 7. Contraintes

- Performance : La carte doit rester fluide même avec beaucoup de markers
- Compatibilité : Fonctionne sur iOS et Android
- Cohérence : Même style de markers sur les deux maps

## 8. Critères d'Acceptation

- [ ] Style de carte modernisé (couleurs épurées)
- [ ] Markers personnalisés avec design cohérent
- [ ] Géolocalisation fonctionnelle avec permission
- [ ] Recherche par zone (dessiner ou sélectionner)
- [ ] Performance maintenue (pas de lag)
- [ ] Les deux maps (détail + exploration) sont mises à jour
