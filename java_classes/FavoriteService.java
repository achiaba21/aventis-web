package com.asfar.web.service;

import com.asfar.web.entity.Appartement;
import com.asfar.web.entity.User;
import com.asfar.web.entity.UserFavorite;
import com.asfar.web.repository.AppartementRepository;
import com.asfar.web.repository.UserFavoriteRepository;
import com.asfar.web.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service pour la gestion des favoris utilisateur
 */
@Service
@Transactional
public class FavoriteService {

    @Autowired
    private UserFavoriteRepository userFavoriteRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AppartementRepository appartementRepository;

    /**
     * Récupère les IDs des appartements favoris d'un utilisateur
     */
    public List<Long> getUserFavoriteIds(Long userId) {
        return userFavoriteRepository.findApartmentIdsByUserId(userId);
    }

    /**
     * Récupère les appartements favoris complets d'un utilisateur
     */
    public List<Appartement> getUserFavoriteAppartements(Long userId) {
        return userFavoriteRepository.findFavoriteAppartementsByUserId(userId);
    }

    /**
     * Ajoute un appartement aux favoris d'un utilisateur
     */
    public boolean addToFavorites(Long userId, Long apartmentId) {
        // Vérifier si déjà en favoris
        if (userFavoriteRepository.existsByUserIdAndAppartementId(userId, apartmentId)) {
            return false; // Déjà dans les favoris
        }

        // Récupérer les entités
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<Appartement> appartOpt = appartementRepository.findById(apartmentId);

        if (userOpt.isEmpty() || appartOpt.isEmpty()) {
            throw new RuntimeException("Utilisateur ou appartement introuvable");
        }

        // Créer et sauvegarder le favori
        UserFavorite favorite = new UserFavorite(userOpt.get(), appartOpt.get());
        userFavoriteRepository.save(favorite);

        return true;
    }

    /**
     * Retire un appartement des favoris d'un utilisateur
     */
    public boolean removeFromFavorites(Long userId, Long apartmentId) {
        Optional<UserFavorite> favoriteOpt =
            userFavoriteRepository.findByUserIdAndAppartementId(userId, apartmentId);

        if (favoriteOpt.isPresent()) {
            userFavoriteRepository.delete(favoriteOpt.get());
            return true;
        }

        return false; // N'était pas dans les favoris
    }

    /**
     * Vérifie si un appartement est dans les favoris d'un utilisateur
     */
    public boolean isFavorite(Long userId, Long apartmentId) {
        return userFavoriteRepository.existsByUserIdAndAppartementId(userId, apartmentId);
    }

    /**
     * Synchronise les favoris client/serveur
     */
    public List<Long> syncFavorites(Long userId, List<Long> clientFavoriteIds) {
        // Récupérer les favoris actuels du serveur
        List<Long> serverFavoriteIds = getUserFavoriteIds(userId);

        // Trouver les différences
        List<Long> toAdd = clientFavoriteIds.stream()
            .filter(id -> !serverFavoriteIds.contains(id))
            .collect(Collectors.toList());

        List<Long> toRemove = serverFavoriteIds.stream()
            .filter(id -> !clientFavoriteIds.contains(id))
            .collect(Collectors.toList());

        // Ajouter les nouveaux favoris
        for (Long apartmentId : toAdd) {
            try {
                addToFavorites(userId, apartmentId);
            } catch (Exception e) {
                // Log l'erreur mais continue la sync
                System.err.println("Erreur lors de l'ajout du favori " + apartmentId + ": " + e.getMessage());
            }
        }

        // Supprimer les favoris obsolètes
        for (Long apartmentId : toRemove) {
            try {
                removeFromFavorites(userId, apartmentId);
            } catch (Exception e) {
                // Log l'erreur mais continue la sync
                System.err.println("Erreur lors de la suppression du favori " + apartmentId + ": " + e.getMessage());
            }
        }

        // Retourner l'état final du serveur
        return getUserFavoriteIds(userId);
    }

    /**
     * Récupère le nombre de favoris d'un utilisateur
     */
    public long getFavoritesCount(Long userId) {
        return userFavoriteRepository.countByUserId(userId);
    }

    /**
     * Supprime tous les favoris d'un utilisateur
     */
    public long clearAllFavorites(Long userId) {
        return userFavoriteRepository.deleteAllByUserId(userId);
    }

    /**
     * Récupère les utilisateurs qui ont mis un appartement en favori
     */
    public List<User> getUsersWhoFavorited(Long apartmentId) {
        return userFavoriteRepository.findUsersByAppartementId(apartmentId);
    }

    /**
     * Récupère les appartements les plus populaires (plus de favoris)
     */
    public List<Object[]> getMostPopularAppartements(int limit) {
        return userFavoriteRepository.findMostPopularAppartements(limit);
    }

    /**
     * Récupère les statistiques des favoris
     */
    public FavoriteStats getFavoriteStats() {
        long totalFavorites = userFavoriteRepository.count();
        long totalUsers = userRepository.count();
        long totalAppartements = appartementRepository.count();

        return new FavoriteStats(totalFavorites, totalUsers, totalAppartements);
    }

    /**
     * Classe pour les statistiques des favoris
     */
    public static class FavoriteStats {
        private final long totalFavorites;
        private final long totalUsers;
        private final long totalAppartements;

        public FavoriteStats(long totalFavorites, long totalUsers, long totalAppartements) {
            this.totalFavorites = totalFavorites;
            this.totalUsers = totalUsers;
            this.totalAppartements = totalAppartements;
        }

        // Getters
        public long getTotalFavorites() { return totalFavorites; }
        public long getTotalUsers() { return totalUsers; }
        public long getTotalAppartements() { return totalAppartements; }
        public double getAverageFavoritesPerUser() {
            return totalUsers > 0 ? (double) totalFavorites / totalUsers : 0;
        }
        public double getAverageFavoritesPerAppartement() {
            return totalAppartements > 0 ? (double) totalFavorites / totalAppartements : 0;
        }
    }
}