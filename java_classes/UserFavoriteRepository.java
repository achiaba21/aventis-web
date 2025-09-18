package com.asfar.web.repository;

import com.asfar.web.entity.Appartement;
import com.asfar.web.entity.User;
import com.asfar.web.entity.UserFavorite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository pour la gestion des favoris utilisateur
 */
@Repository
public interface UserFavoriteRepository extends JpaRepository<UserFavorite, Long> {

    /**
     * Trouve un favori par utilisateur et appartement
     */
    Optional<UserFavorite> findByUserIdAndAppartementId(Long userId, Long appartementId);

    /**
     * Vérifie si un favori existe
     */
    boolean existsByUserIdAndAppartementId(Long userId, Long appartementId);

    /**
     * Récupère tous les favoris d'un utilisateur
     */
    List<UserFavorite> findByUserIdOrderByCreatedAtDesc(Long userId);

    /**
     * Récupère les IDs des appartements favoris d'un utilisateur
     */
    @Query("SELECT uf.appartement.id FROM UserFavorite uf WHERE uf.user.id = :userId ORDER BY uf.createdAt DESC")
    List<Long> findApartmentIdsByUserId(@Param("userId") Long userId);

    /**
     * Récupère les appartements favoris complets d'un utilisateur
     */
    @Query("SELECT uf.appartement FROM UserFavorite uf WHERE uf.user.id = :userId ORDER BY uf.createdAt DESC")
    List<Appartement> findFavoriteAppartementsByUserId(@Param("userId") Long userId);

    /**
     * Récupère tous les favoris d'un appartement
     */
    List<UserFavorite> findByAppartementIdOrderByCreatedAtDesc(Long appartementId);

    /**
     * Récupère les utilisateurs qui ont mis un appartement en favori
     */
    @Query("SELECT uf.user FROM UserFavorite uf WHERE uf.appartement.id = :appartementId ORDER BY uf.createdAt DESC")
    List<User> findUsersByAppartementId(@Param("appartementId") Long appartementId);

    /**
     * Compte le nombre de favoris d'un utilisateur
     */
    long countByUserId(Long userId);

    /**
     * Compte le nombre de favoris d'un appartement
     */
    long countByAppartementId(Long appartementId);

    /**
     * Supprime tous les favoris d'un utilisateur
     */
    @Modifying
    @Query("DELETE FROM UserFavorite uf WHERE uf.user.id = :userId")
    long deleteAllByUserId(@Param("userId") Long userId);

    /**
     * Supprime tous les favoris d'un appartement
     */
    @Modifying
    @Query("DELETE FROM UserFavorite uf WHERE uf.appartement.id = :appartementId")
    long deleteAllByAppartementId(@Param("appartementId") Long appartementId);

    /**
     * Trouve les favoris créés dans une période donnée
     */
    @Query("SELECT uf FROM UserFavorite uf WHERE uf.createdAt BETWEEN :startDate AND :endDate ORDER BY uf.createdAt DESC")
    List<UserFavorite> findByCreatedAtBetween(@Param("startDate") LocalDateTime startDate,
                                              @Param("endDate") LocalDateTime endDate);

    /**
     * Trouve les appartements les plus populaires (plus de favoris)
     */
    @Query("SELECT uf.appartement.id, COUNT(uf) as favoriteCount " +
           "FROM UserFavorite uf " +
           "GROUP BY uf.appartement.id " +
           "ORDER BY COUNT(uf) DESC")
    List<Object[]> findMostPopularAppartements(@Param("limit") int limit);

    /**
     * Trouve les utilisateurs les plus actifs (plus de favoris)
     */
    @Query("SELECT uf.user.id, COUNT(uf) as favoriteCount " +
           "FROM UserFavorite uf " +
           "GROUP BY uf.user.id " +
           "ORDER BY COUNT(uf) DESC")
    List<Object[]> findMostActiveUsers(@Param("limit") int limit);

    /**
     * Trouve les favoris récents d'un utilisateur
     */
    @Query("SELECT uf FROM UserFavorite uf WHERE uf.user.id = :userId AND uf.createdAt >= :since ORDER BY uf.createdAt DESC")
    List<UserFavorite> findRecentFavoritesByUserId(@Param("userId") Long userId,
                                                   @Param("since") LocalDateTime since);

    /**
     * Statistiques des favoris par mois
     */
    @Query("SELECT FUNCTION('YEAR', uf.createdAt) as year, " +
           "FUNCTION('MONTH', uf.createdAt) as month, " +
           "COUNT(uf) as count " +
           "FROM UserFavorite uf " +
           "GROUP BY FUNCTION('YEAR', uf.createdAt), FUNCTION('MONTH', uf.createdAt) " +
           "ORDER BY year DESC, month DESC")
    List<Object[]> getFavoriteStatsByMonth();

    /**
     * Trouve les favoris communs entre deux utilisateurs
     */
    @Query("SELECT uf1.appartement FROM UserFavorite uf1, UserFavorite uf2 " +
           "WHERE uf1.user.id = :userId1 AND uf2.user.id = :userId2 " +
           "AND uf1.appartement.id = uf2.appartement.id")
    List<Appartement> findCommonFavorites(@Param("userId1") Long userId1,
                                          @Param("userId2") Long userId2);

    /**
     * Trouve les appartements similaires basés sur les favoris d'autres utilisateurs
     */
    @Query("SELECT DISTINCT uf2.appartement FROM UserFavorite uf1, UserFavorite uf2 " +
           "WHERE uf1.appartement.id = :appartementId " +
           "AND uf1.user.id = uf2.user.id " +
           "AND uf2.appartement.id != :appartementId " +
           "GROUP BY uf2.appartement.id " +
           "ORDER BY COUNT(uf2.appartement.id) DESC")
    List<Appartement> findSimilarAppartements(@Param("appartementId") Long appartementId);

    /**
     * Nettoie les favoris d'appartements supprimés (orphelins)
     */
    @Modifying
    @Query("DELETE FROM UserFavorite uf WHERE uf.appartement.id NOT IN (SELECT a.id FROM Appartement a)")
    int cleanupOrphanedFavorites();
}