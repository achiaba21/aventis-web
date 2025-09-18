# Classes Java pour le Serveur - Système de Filtrage

Ce dossier contient les classes Java nécessaires pour implémenter le système de filtrage côté serveur.

## Structure des fichiers

### 1. DTOs (Data Transfer Objects)
- **FilterCriteria.java** : Classe pour recevoir les critères de filtrage depuis le client Flutter
- **FilterOptions.java** : Classe pour envoyer les options de filtrage disponibles au client

### 2. Controller
- **AppartementController.java** : Contrôleur REST avec les endpoints de filtrage

### 3. Service
- **FilterService.java** : Service métier pour la logique de filtrage avec JPA Specifications

### 4. Repository
- **AppartementRepository.java** : Repository étendu avec des méthodes de filtrage personnalisées

## Endpoints implémentés

### GET `/auth/appartement/apparts`
Récupère tous les appartements

### GET `/auth/appartement/apparts/{proprietaireId}`
Récupère les appartements d'un propriétaire spécifique

### POST `/auth/appartement/filter`
Filtre les appartements selon les critères fournis
```json
{
  "prix_min": 100000,
  "prix_max": 500000,
  "date_debut": "2024-01-15",
  "date_fin": "2024-01-20",
  "nb_lits": 2,
  "nb_chambres": 1,
  "nb_douches": 1,
  "commodites": ["Wifi", "Pool"],
  "preferences": ["Entire place"],
  "regles": ["Pets"]
}
```

### GET `/auth/appartement/filter-options`
Récupère les options de filtrage disponibles
```json
{
  "commodites": ["Air conditioning", "Wifi", "Kitchen", ...],
  "preferences": ["Entire place", "Shared space", "Private room"],
  "regles": ["Pets", "Smoking", "Events", "Children"],
  "prix_min": 0,
  "prix_max": 10000000
}
```

## Configuration requise

### Dépendances Maven
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-annotations</artifactId>
</dependency>
```

### Adaptations nécessaires

1. **Modèle de données** : Adapter les champs selon votre entité `Appartement`
2. **Réservations** : Implémenter la logique de disponibilité selon votre modèle de réservation
3. **Commodités** : Adapter selon comment vous stockez les commodités (JSON, relation ManyToMany, etc.)
4. **Package names** : Remplacer `com.asfar.web` par votre package racine

### Exemple d'entité Appartement (à adapter)
```java
@Entity
public class Appartement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double prix;
    private String titre;
    private String description;
    private Boolean visible = true;
    private Integer nbLits;
    private Integer nbChambres;
    private Integer nbDouches;
    private String typeLocation; // "Entire place", "Private room", etc.

    @ManyToOne
    private Residence residence;

    // Autres champs et relations...
}
```

## Optimisations possibles

1. **Cache** : Mettre en cache les options de filtrage
2. **Indexation** : Créer des index sur les champs de filtrage
3. **Pagination** : Ajouter la pagination aux résultats
4. **Recherche full-text** : Intégrer Elasticsearch pour la recherche avancée
5. **Validation** : Ajouter la validation des critères de filtrage