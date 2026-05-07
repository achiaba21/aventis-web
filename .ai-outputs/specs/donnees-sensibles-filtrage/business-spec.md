# 📋 Spécification Métier - Gestion des Données Sensibles Filtrées

## 1. Contexte

Le serveur filtre automatiquement les données sensibles (GPS, coordonnées personnelles) selon le statut de l'utilisateur et de sa réservation. L'application mobile doit gérer ces valeurs `null` et offrir une expérience utilisateur cohérente avec des placeholders appropriés et des incitations à réserver/payer.

## 2. Objectif

Afficher des alternatives visuelles et textuelles lorsque les données sensibles sont masquées, tout en guidant l'utilisateur vers l'action requise (réservation/paiement) pour débloquer ces informations.

## 3. Acteurs

- **Visiteur / Client non connecté** : voit les données masquées
- **Client connecté sans réservation** : voit les données masquées
- **Client avec réservation non payée** : voit les données masquées
- **Client avec réservation payée (dans les dates)** : voit toutes les données
- **Propriétaire** : voit tout sur ses biens, données locataire selon statut réservation
- **Admin** : voit tout

## 4. Règles Métier

| Donnée | Masquée si | Visible si |
|--------|------------|------------|
| `lat`, `longi` | Pas de réservation payée active | Réservation PAYER/FINALISER dans les dates |
| `proprietaire.nom`, `proprietaire.telephone` | Pas de réservation payée active | Réservation PAYER/FINALISER dans les dates |
| `locataire.nom`, `locataire.telephone` | Réservation EN_ATTENTE | Réservation PAYER/FINALISER |

## 5. Cas d'Usage Principal

### Scénario : Client consulte une résidence
1. Client ouvre la fiche d'une résidence/appartement
2. Le serveur retourne les données avec `lat: null`, `proprietaire.nom: null`
3. L'app affiche :
   - Carte centrée sur le quartier (sans marker précis)
   - Message cliquable "Informations disponibles après paiement"
4. Client clique sur le message → redirigé vers sa réservation (ou création)
5. Après paiement, les données complètes s'affichent

### Scénario : Propriétaire consulte une réservation
1. Propriétaire ouvre une réservation EN_ATTENTE
2. Le serveur retourne `locataire.nom: null`, `locataire.telephone: null`
3. L'app affiche "En attente de paiement" pour les infos locataire
4. Après paiement du locataire, les coordonnées s'affichent

## 6. Cas Alternatifs / Limites

- **Réservation expirée** : Même si payée, si `date > dateFin`, les données redeviennent masquées
- **Propriétaire sur son bien** : Toujours tout visible (pas de masquage)
- **Admin** : Toujours tout visible

## 7. Contraintes

- Aucune modification des appels API existants
- Le token JWT doit être présent pour l'identification
- La carte doit rester fonctionnelle (zoom sur quartier/ville)

## 8. Critères d'Acceptation

- [ ] Carte affiche le quartier/ville sans marker quand GPS est `null`
- [ ] Message "Informations disponibles après paiement" affiché quand nom/téléphone `null`
- [ ] Clic sur le message redirige vers la réservation
- [ ] Propriétaire voit "En attente de paiement" pour locataire non payé
- [ ] Données complètes affichées quand non-null
- [ ] Aucun crash si valeurs `null`

## 9. Comportement par Utilisateur (Référence Serveur)

| Utilisateur | Réservation | Réponse JSON |
|-------------|-------------|--------------|
| Visiteur (non connecté) | - | lat: null, longi: null, proprietaire.nom: null, proprietaire.telephone: null |
| Client sans réservation | - | lat: null, longi: null, proprietaire.nom: null, proprietaire.telephone: null |
| Client avec résa EN_ATTENTE | non payée | lat: null, longi: null, proprietaire.nom: null, proprietaire.telephone: null |
| Client avec résa PAYER | payée, date OK | Tout visible |
| Client avec résa FINALISER | payée, date OK | Tout visible |
| Client avec résa PAYER | date > fin | lat: null, longi: null, proprietaire.nom: null, proprietaire.telephone: null |
| Propriétaire | sa résidence | Tout visible |
| Admin | - | Tout visible |

---

*Validé le 25 décembre 2024*
