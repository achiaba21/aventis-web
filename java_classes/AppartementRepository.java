package com.asfar.web.repository;

import com.asfar.web.entity.Appartement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository pour la gestion des appartements avec support de filtrage
 */
@Repository
public interface AppartementRepository extends JpaRepository<Appartement, Long>, JpaSpecificationExecutor<Appartement> {

    /**
     * Trouve tous les appartements visibles
     */
    List<Appartement> findByVisibleTrue();

    /**
     * Trouve les appartements par propriétaire
     */
    @Query("SELECT a FROM Appartement a WHERE a.residence.proprietaire.id = :proprietaireId AND a.visible = true")
    List<Appartement> findByProprietaireId(@Param("proprietaireId") Long proprietaireId);

    /**
     * Récupère le prix minimum des appartements
     */
    @Query("SELECT MIN(a.prix) FROM Appartement a WHERE a.visible = true")
    Double findMinPrix();

    /**
     * Récupère le prix maximum des appartements
     */
    @Query("SELECT MAX(a.prix) FROM Appartement a WHERE a.visible = true")
    Double findMaxPrix();

    /**
     * Trouve les appartements par gamme de prix
     */
    @Query("SELECT a FROM Appartement a WHERE a.prix BETWEEN :prixMin AND :prixMax AND a.visible = true")
    List<Appartement> findByPrixBetween(@Param("prixMin") Double prixMin, @Param("prixMax") Double prixMax);

    /**
     * Trouve les appartements par nombre minimum de lits
     */
    @Query("SELECT a FROM Appartement a WHERE a.nbLits >= :nbLits AND a.visible = true")
    List<Appartement> findByNbLitsGreaterThanEqual(@Param("nbLits") Integer nbLits);

    /**
     * Trouve les appartements par nombre minimum de chambres
     */
    @Query("SELECT a FROM Appartement a WHERE a.nbChambres >= :nbChambres AND a.visible = true")
    List<Appartement> findByNbChambresGreaterThanEqual(@Param("nbChambres") Integer nbChambres);

    /**
     * Trouve les appartements par nombre minimum de douches
     */
    @Query("SELECT a FROM Appartement a WHERE a.nbDouches >= :nbDouches AND a.visible = true")
    List<Appartement> findByNbDouchesGreaterThanEqual(@Param("nbDouches") Integer nbDouches);

    /**
     * Trouve les appartements par type de location
     */
    @Query("SELECT a FROM Appartement a WHERE a.typeLocation IN :types AND a.visible = true")
    List<Appartement> findByTypeLocationIn(@Param("types") List<String> types);

    /**
     * Recherche textuelle dans le titre et la description
     */
    @Query("SELECT a FROM Appartement a WHERE " +
           "(LOWER(a.titre) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(a.description) LIKE LOWER(CONCAT('%', :searchTerm, '%'))) AND " +
           "a.visible = true")
    List<Appartement> findByTitreOrDescriptionContainingIgnoreCase(@Param("searchTerm") String searchTerm);

    /**
     * Compte le nombre d'appartements visibles
     */
    @Query("SELECT COUNT(a) FROM Appartement a WHERE a.visible = true")
    Long countVisibleAppartements();

    /**
     * Trouve les appartements par ville
     */
    @Query("SELECT a FROM Appartement a WHERE LOWER(a.residence.address.ville) = LOWER(:ville) AND a.visible = true")
    List<Appartement> findByVille(@Param("ville") String ville);

    /**
     * Trouve les appartements disponibles pour une période donnée
     * Note: Cette requête dépend de votre modèle de réservation
     */
    @Query("SELECT DISTINCT a FROM Appartement a WHERE a.visible = true AND " +
           "NOT EXISTS (SELECT r FROM Reservation r WHERE r.appartement = a AND " +
           "((r.dateDebut <= :dateDebut AND r.dateFin >= :dateDebut) OR " +
           "(r.dateDebut <= :dateFin AND r.dateFin >= :dateFin) OR " +
           "(r.dateDebut >= :dateDebut AND r.dateFin <= :dateFin)))")
    List<Appartement> findAvailableAppartements(@Param("dateDebut") java.time.LocalDate dateDebut,
                                               @Param("dateFin") java.time.LocalDate dateFin);
}