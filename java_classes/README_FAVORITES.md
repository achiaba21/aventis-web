# Système de Favoris - Classes Java pour le Serveur

Ce dossier contient les classes Java pour implémenter un système complet de gestion des favoris utilisateur.

## Structure des fichiers

### 1. Entités
- **UserFavorite.java** : Entité JPA pour la relation utilisateur-appartement favori

### 2. Repository
- **UserFavoriteRepository.java** : Repository avec requêtes complexes pour les favoris

### 3. Service
- **FavoriteService.java** : Service métier pour la logique des favoris

### 4. Controller
- **FavoriteController.java** : Contrôleur REST avec endpoints complets

## Endpoints implémentés

### Endpoints principaux

#### GET `/auth/user/favorites`
Récupère les IDs des appartements favoris de l'utilisateur
```json
[1, 5, 12, 25]
```

#### GET `/auth/user/favorites/apartments`
Récupère les appartements favoris complets
```json
[
  {
    "id": 1,
    "titre": "Studio moderne",
    "prix": 250000,
    // ... autres propriétés
  }
]
```

#### POST `/auth/user/favorites/{apartmentId}`
Ajoute un appartement aux favoris
```json
{
  "success": true,
  "message": "Ajouté aux favoris",
  "apartmentId": 123
}
```

#### DELETE `/auth/user/favorites/{apartmentId}`
Retire un appartement des favoris
```json
{
  "success": true,
  "message": "Retiré des favoris",
  "apartmentId": 123
}
```

### Endpoints avancés

#### GET `/auth/user/favorites/{apartmentId}/check`
Vérifie si un appartement est favori
```json
{
  "isFavorite": true,
  "apartmentId": 123
}
```

#### POST `/auth/user/favorites/sync`
Synchronise les favoris client/serveur
```json
// Body: [1, 2, 3]
// Response: [1, 2, 3, 4, 5]
```

#### GET `/auth/user/favorites/count`
Récupère le nombre de favoris
```json
{
  "count": 15,
  "userId": 1
}
```

#### DELETE `/auth/user/favorites`
Supprime tous les favoris
```json
{
  "success": true,
  "deletedCount": 15,
  "message": "Tous les favoris ont été supprimés"
}
```

## Configuration de la base de données

### Table `user_favorites`
```sql
CREATE TABLE user_favorites (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    appartement_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY unique_user_apartment (user_id, appartement_id),

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (appartement_id) REFERENCES appartements(id) ON DELETE CASCADE,

    INDEX idx_user_favorites_user (user_id),
    INDEX idx_user_favorites_apartment (appartement_id),
    INDEX idx_user_favorites_created (created_at)
);
```

## Fonctionnalités avancées

### 1. Synchronisation client/serveur
- Réconciliation automatique des favoris
- Gestion des conflits
- Retry en cas d'erreur

### 2. Statistiques et analytics
- Appartements les plus populaires
- Utilisateurs les plus actifs
- Statistiques par période

### 3. Recommandations
- Favoris communs entre utilisateurs
- Appartements similaires basés sur les favoris
- Suggestions personnalisées

### 4. Performance
- Index optimisés pour les requêtes fréquentes
- Requêtes batch pour les opérations multiples
- Cache des favoris populaires

## Dépendances Maven

```xml
<!-- Spring Boot Data JPA -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<!-- Spring Boot Web -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Spring Boot Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- Jackson pour JSON -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-annotations</artifactId>
</dependency>
```

## Configuration Spring

### application.yml
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/asfar_db
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:password}

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect
        format_sql: true
```

## Adaptations nécessaires

### 1. Authentification
Modifier la méthode `getUserIdFromAuth()` dans `FavoriteController` selon votre système d'auth :

```java
private Long getUserIdFromAuth(Authentication authentication) {
    UserDetails userDetails = (UserDetails) authentication.getPrincipal();
    User user = userService.findByUsername(userDetails.getUsername());
    return user.getId();
}
```

### 2. Validation
Ajouter la validation des paramètres :

```java
@PostMapping("/favorites/{apartmentId}")
public ResponseEntity<?> addToFavorites(
        @PathVariable @Valid @Positive Long apartmentId,
        Authentication authentication) {
    // ...
}
```

### 3. Gestion d'erreurs
Implémenter un gestionnaire d'exceptions global :

```java
@ControllerAdvice
public class FavoriteExceptionHandler {
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<?> handleNotFound(EntityNotFoundException e) {
        return ResponseEntity.notFound().build();
    }
}
```

## Tests unitaires

### Exemple de test pour FavoriteService
```java
@ExtendWith(MockitoExtension.class)
class FavoriteServiceTest {

    @Mock
    private UserFavoriteRepository favoriteRepository;

    @InjectMocks
    private FavoriteService favoriteService;

    @Test
    void addToFavorites_ShouldReturnTrue_WhenNotAlreadyFavorite() {
        // Given
        Long userId = 1L;
        Long apartmentId = 2L;
        when(favoriteRepository.existsByUserIdAndAppartementId(userId, apartmentId))
            .thenReturn(false);

        // When
        boolean result = favoriteService.addToFavorites(userId, apartmentId);

        // Then
        assertTrue(result);
        verify(favoriteRepository).save(any(UserFavorite.class));
    }
}
```

## Monitoring et métriques

### Endpoints de santé
```java
@GetMapping("/favorites/health")
public ResponseEntity<Map<String, Object>> healthCheck() {
    long totalFavorites = favoriteService.getFavoritesCount();
    return ResponseEntity.ok(Map.of(
        "status", "UP",
        "totalFavorites", totalFavorites,
        "timestamp", LocalDateTime.now()
    ));
}
```

Ce système de favoris est maintenant prêt pour la production avec toutes les fonctionnalités avancées ! 🚀