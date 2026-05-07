# Specification Metier : Restructuration Chargement Donnees

## 1. Contexte

Actuellement, l'ecran Explore charge les appartements directement via un endpoint dedie (`auth/appartement/apparts`). La carte utilise ResidenceBloc qui appelle un endpoint reserve aux proprietaires, causant une erreur "acces reserve" pour les locataires.

La nouvelle architecture unifie le chargement : les residences (contenant les appartements) deviennent la source unique de donnees.

## 2. Objectif

Charger les residences avec leurs appartements depuis ResidenceBloc, puis alimenter AppartementBloc pour l'affichage dans Explore et la carte.

## 3. Acteurs

| Acteur | Role |
|--------|------|
| **Locataire** | Consulte les appartements dans Explore et sur la carte |
| **Proprietaire** | Gere ses propres residences (endpoint et stockage separes) |

## 4. Regles Metier

| ID | Regle | Description |
|----|-------|-------------|
| RM1 | Source unique | ResidenceBloc est la source de donnees pour les locataires |
| RM2 | Cascade | Les appartements sont extraits des residences et alimentent AppartementBloc |
| RM3 | Masquage GPS | Les residences sans coordonnees (lat/longi null) ne s'affichent pas sur la carte |
| RM4 | Donnees sensibles | lat, longi, nom proprio, telephone masques si pas de reservation payee |
| RM5 | Filtres preserves | Les filtres existants (prix, commune, etc.) continuent de fonctionner |

## 5. Cas d'Usage Principal

**Preconditions :** Utilisateur connecte en tant que locataire

**Scenario :**
1. L'application charge les residences via `/proprietaire/residence/all-client`
2. ResidenceBloc stocke les residences avec leurs appartements
3. Les appartements sont extraits et injectes dans AppartementBloc
4. L'ecran Explore affiche les appartements
5. La carte affiche les residences ayant des coordonnees GPS valides

**Postconditions :** Appartements visibles dans Explore, residences geolocalisees sur la carte

## 6. Cas Alternatifs

| Cas | Condition | Comportement |
|-----|-----------|--------------|
| CA1 | Utilisateur proprietaire | Utilise son endpoint dedie avec stockage local |
| CA2 | Coordonnees GPS masquees | Residence non affichee sur la carte |
| CA3 | Aucune residence | Message "Aucun appartement disponible" |

## 7. Gestion des Erreurs

| Erreur | Condition | Comportement |
|--------|-----------|--------------|
| E1 | Erreur reseau | Afficher message d'erreur + bouton reessayer |
| E2 | Token invalide | Rediriger vers connexion |

## 8. Contraintes

- **Retrocompatibilite :** Les filtres doivent fonctionner identiquement
- **Suppression :** L'ancien code de chargement direct des appartements doit etre supprime

## 9. Criteres d'Acceptation

- [ ] Les residences sont chargees via `/proprietaire/residence/all-client` pour les locataires
- [ ] AppartementBloc est alimente par les appartements des residences
- [ ] L'ecran Explore affiche les appartements correctement
- [ ] Les filtres (prix, commune, etc.) fonctionnent
- [ ] La carte affiche uniquement les residences avec coordonnees GPS
- [ ] L'ancien endpoint `auth/appartement/apparts` n'est plus utilise pour l'explore
- [ ] Les proprietaires utilisent leur propre endpoint avec stockage local

## 10. Hors Perimetre

- Modification de l'endpoint proprietaire existant
- Rechargement dynamique lors du deplacement de la carte (future mise a jour)

## 11. Endpoint API

```
GET /proprietaire/residence/all-client

Headers : Authorization: Bearer {token}

Reponse :
{
  "body": [
    {
      "id": 1,
      "nom": "Residence Les Palmiers",
      "reference": "RES-001",
      "address": {
        "lat": null,        // masque si pas de reservation payee
        "longi": null,      // masque si pas de reservation payee
        "ville": "Abidjan",
        "quartier": "Cocody"
      },
      "proprietaire": {
        "id": 15,
        "nom": null,        // masque si pas de reservation payee
        "telephone": null,  // masque si pas de reservation payee
        "email": "proprio@email.com"
      },
      "appartements": [...]
    }
  ],
  "message": "success"
}
```

---

*Valide par l'utilisateur le 26/12/2024*
