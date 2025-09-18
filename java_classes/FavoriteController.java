package com.asfar.web.controller;

import com.asfar.web.entity.Appartement;
import com.asfar.web.service.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Contrôleur REST pour la gestion des favoris
 */
@RestController
@RequestMapping("/auth/user")
@CrossOrigin(origins = "*")
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

    /**
     * Récupère les IDs des appartements favoris de l'utilisateur connecté
     */
    @GetMapping("/favorites")
    public ResponseEntity<List<Long>> getUserFavoriteIds(Authentication authentication) {
        Long userId = getUserIdFromAuth(authentication);
        List<Long> favoriteIds = favoriteService.getUserFavoriteIds(userId);
        return ResponseEntity.ok(favoriteIds);
    }

    /**
     * Récupère les appartements favoris complets de l'utilisateur
     */
    @GetMapping("/favorites/apartments")
    public ResponseEntity<List<Appartement>> getUserFavoriteAppartements(Authentication authentication) {
        Long userId = getUserIdFromAuth(authentication);
        List<Appartement> favorites = favoriteService.getUserFavoriteAppartements(userId);
        return ResponseEntity.ok(favorites);
    }

    /**
     * Ajoute un appartement aux favoris
     */
    @PostMapping("/favorites/{apartmentId}")
    public ResponseEntity<Map<String, Object>> addToFavorites(
            @PathVariable Long apartmentId,
            Authentication authentication) {

        Long userId = getUserIdFromAuth(authentication);
        boolean added = favoriteService.addToFavorites(userId, apartmentId);

        return ResponseEntity.ok(Map.of(
            "success", added,
            "message", added ? "Ajouté aux favoris" : "Déjà dans les favoris",
            "apartmentId", apartmentId
        ));
    }

    /**
     * Retire un appartement des favoris
     */
    @DeleteMapping("/favorites/{apartmentId}")
    public ResponseEntity<Map<String, Object>> removeFromFavorites(
            @PathVariable Long apartmentId,
            Authentication authentication) {

        Long userId = getUserIdFromAuth(authentication);
        boolean removed = favoriteService.removeFromFavorites(userId, apartmentId);

        return ResponseEntity.ok(Map.of(
            "success", removed,
            "message", removed ? "Retiré des favoris" : "N'était pas dans les favoris",
            "apartmentId", apartmentId
        ));
    }

    /**
     * Vérifie si un appartement est dans les favoris
     */
    @GetMapping("/favorites/{apartmentId}/check")
    public ResponseEntity<Map<String, Object>> checkIsFavorite(
            @PathVariable Long apartmentId,
            Authentication authentication) {

        Long userId = getUserIdFromAuth(authentication);
        boolean isFavorite = favoriteService.isFavorite(userId, apartmentId);

        return ResponseEntity.ok(Map.of(
            "isFavorite", isFavorite,
            "apartmentId", apartmentId
        ));
    }

    /**
     * Synchronise les favoris - pour réconcilier l'état client/serveur
     */
    @PostMapping("/favorites/sync")
    public ResponseEntity<List<Long>> syncFavorites(
            @RequestBody List<Long> clientFavoriteIds,
            Authentication authentication) {

        Long userId = getUserIdFromAuth(authentication);
        List<Long> serverFavoriteIds = favoriteService.syncFavorites(userId, clientFavoriteIds);

        return ResponseEntity.ok(serverFavoriteIds);
    }

    /**
     * Récupère le nombre total de favoris de l'utilisateur
     */
    @GetMapping("/favorites/count")
    public ResponseEntity<Map<String, Object>> getFavoritesCount(Authentication authentication) {
        Long userId = getUserIdFromAuth(authentication);
        long count = favoriteService.getFavoritesCount(userId);

        return ResponseEntity.ok(Map.of(
            "count", count,
            "userId", userId
        ));
    }

    /**
     * Supprime tous les favoris de l'utilisateur
     */
    @DeleteMapping("/favorites")
    public ResponseEntity<Map<String, Object>> clearAllFavorites(Authentication authentication) {
        Long userId = getUserIdFromAuth(authentication);
        long deletedCount = favoriteService.clearAllFavorites(userId);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "deletedCount", deletedCount,
            "message", "Tous les favoris ont été supprimés"
        ));
    }

    /**
     * Extrait l'ID utilisateur depuis l'authentication
     */
    private Long getUserIdFromAuth(Authentication authentication) {
        // Adapter selon votre système d'authentification
        // Exemple si vous stockez un objet User dans le principal:
        // User user = (User) authentication.getPrincipal();
        // return user.getId();

        // Exemple si vous stockez l'ID directement:
        // return Long.parseLong(authentication.getName());

        // Pour les tests, retourner un ID fixe:
        return 1L; // À REMPLACER par votre logique d'auth
    }
}