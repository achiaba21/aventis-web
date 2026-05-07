# Spécification Métier - Amélioration Interface Détail & Réservation

## 1. Contexte

L'application Asfar permet aux locataires de réserver des appartements et aux propriétaires de gérer leurs biens. Les interfaces actuelles de détail appartement et de réservation présentent des problèmes de **lisibilité** (trop de couleurs, informations mal organisées) qui nuisent à l'expérience utilisateur. De plus, le système de réduction existant n'est pas suffisamment mis en valeur.

## 2. Objectif

Améliorer l'interface de détail des appartements et de réservation pour :
- Offrir une **meilleure lisibilité** (réduction des couleurs, hiérarchie visuelle claire)
- **Réorganiser les informations** de manière logique et intuitive
- **Mettre en valeur les réductions** disponibles selon la durée du séjour
- Ajouter des fonctionnalités manquantes (carte, gestion calendrier)
- Maintenir la **cohérence** avec le design system existant (dark theme, couleur primaire orange)

## 3. Acteurs

| Acteur | Besoins |
|--------|---------|
| **Locataire** | Consulter les détails d'un appartement, voir les réductions disponibles, voir la localisation approximative, réserver facilement, suivre sa réservation |
| **Propriétaire** | Consulter ses appartements, gérer le calendrier (bloquer des dates), suivre les réservations |

## 4. Règles Métier

- **R1** : L'adresse exacte de l'appartement n'est visible qu'après confirmation de la réservation
- **R2** : Avant réservation, seule une zone approximative (quartier) est affichée sur la carte
- **R3** : Le propriétaire peut bloquer des dates pour rendre son appartement indisponible
- **R4** : Les dates bloquées ne peuvent pas être réservées par les locataires
- **R5** : Le design doit utiliser moins de couleurs vives et privilégier la lisibilité
- **R6** : Chaque appartement peut avoir des paliers de réduction (ex: -10% dès 7 nuits, -20% dès 30 nuits)
- **R7** : Les réductions s'appliquent automatiquement selon la durée du séjour sélectionné
- **R8** : L'utilisateur doit voir clairement l'économie réalisée (prix barré + nouveau prix)

## 5. Cas d'Usage Principaux

### Locataire - Consulter un appartement
1. L'utilisateur accède au détail d'un appartement
2. Il voit les photos en premier (carousel)
3. Il consulte les informations essentielles (prix, capacité, commodités)
4. Il voit le **tableau des paliers de réduction** disponibles
5. Il visualise la localisation approximative sur une carte
6. Il sélectionne ses dates de séjour
7. Il voit le récapitulatif du prix avec **comparaison avant/après** si réduction applicable
8. Il peut réserver ou contacter le propriétaire

### Locataire - Voir les réductions
1. Sur la fiche appartement, un encart montre les paliers de réduction
2. Quand il sélectionne des dates, le calcul se fait automatiquement
3. Si une réduction s'applique : prix original barré + nouveau prix + économie réalisée
4. Si proche d'un palier : indication "Ajoutez X nuits pour bénéficier de -Y%"

### Propriétaire - Gérer le calendrier
1. Le propriétaire accède au détail de son appartement
2. Il accède au calendrier de disponibilité
3. Il sélectionne les dates à bloquer
4. Il confirme le blocage
5. Les dates sont marquées comme indisponibles

## 6. Cas Alternatifs / Limites

- **Dates déjà réservées** : Le locataire ne peut pas sélectionner des dates occupées
- **Dates bloquées par le propriétaire** : Affichées comme indisponibles
- **Pas de réduction configurée** : Ne pas afficher l'encart des paliers
- **Séjour trop court pour réduction** : Montrer les paliers disponibles pour inciter à prolonger
- **Paiement échoué** : Message d'erreur clair avec option de réessayer
- **Carte non disponible** : Afficher l'adresse textuelle du quartier

## 7. Contraintes

- **Design** : Cohérence avec le thème existant (dark theme, orange #FFA02A)
- **Lisibilité** : Réduire l'utilisation des couleurs vives, privilégier le contraste
- **Performance** : La carte doit se charger rapidement
- **Existant** : Réutiliser le modèle `Remise` et `Condition` existants
- **Données** : Les réductions sont fournies par le serveur (déjà en place)

## 8. Critères d'Acceptation

- [ ] Les informations du détail appartement sont organisées en sections claires
- [ ] La lisibilité est améliorée (moins de couleurs, hiérarchie visuelle)
- [ ] Un tableau affiche les paliers de réduction disponibles
- [ ] Le prix affiche la comparaison avant/après si réduction applicable
- [ ] L'économie réalisée est clairement visible
- [ ] Une carte affiche la zone approximative de l'appartement
- [ ] Le locataire peut réserver de manière fluide
- [ ] Le propriétaire peut bloquer des dates via un calendrier
- [ ] L'interface reste cohérente avec le reste de l'application
- [ ] Le paiement intégré fonctionne correctement

---

**Validé par l'utilisateur le** : $(date)
**Statut** : ✅ Approuvé - Prêt pour l'architecture
