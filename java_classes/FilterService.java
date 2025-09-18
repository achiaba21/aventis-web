package com.asfar.web.service;

import com.asfar.web.dto.filter.FilterCriteria;
import com.asfar.web.dto.filter.FilterOptions;
import com.asfar.web.entity.Appartement;
import com.asfar.web.repository.AppartementRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import javax.persistence.criteria.Predicate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Service pour la gestion des filtres d'appartements
 */
@Service
public class FilterService {

    @Autowired
    private AppartementRepository appartementRepository;

    /**
     * Filtre les appartements selon les critères fournis
     */
    public List<Appartement> filterAppartements(FilterCriteria criteria) {
        if (!criteria.hasFilters()) {
            return appartementRepository.findAll();
        }

        Specification<Appartement> specification = buildSpecification(criteria);
        return appartementRepository.findAll(specification);
    }

    /**
     * Récupère les options de filtrage disponibles
     */
    public FilterOptions getAvailableFilterOptions() {
        // Récupérer les prix min/max depuis la base de données
        Double prixMin = appartementRepository.findMinPrix();
        Double prixMax = appartementRepository.findMaxPrix();

        // Options statiques (peuvent être récupérées depuis la DB si nécessaire)
        List<String> commodites = Arrays.asList(
            "Air conditioning",
            "Wifi",
            "Kitchen",
            "TV",
            "Water heater",
            "Gym",
            "Pool",
            "Parking",
            "Balcony",
            "Terrace"
        );

        List<String> preferences = Arrays.asList(
            "Entire place",
            "Shared space",
            "Private room"
        );

        List<String> regles = Arrays.asList(
            "Pets",
            "Smoking",
            "Events",
            "Children"
        );

        return new FilterOptions(commodites, preferences, regles,
                               prixMin != null ? prixMin : 0.0,
                               prixMax != null ? prixMax : 10000000.0);
    }

    /**
     * Construit la spécification JPA pour le filtrage
     */
    private Specification<Appartement> buildSpecification(FilterCriteria criteria) {
        return (root, query, criteriaBuilder) -> {
            List<Predicate> predicates = new ArrayList<>();

            // Filtre par prix
            if (criteria.getPrixMin() != null) {
                predicates.add(criteriaBuilder.greaterThanOrEqualTo(root.get("prix"), criteria.getPrixMin()));
            }
            if (criteria.getPrixMax() != null) {
                predicates.add(criteriaBuilder.lessThanOrEqualTo(root.get("prix"), criteria.getPrixMax()));
            }

            // Filtre par dates (disponibilité)
            if (criteria.getDateDebut() != null && criteria.getDateFin() != null) {
                // Vérifier que l'appartement n'a pas de réservation sur cette période
                // Cette logique dépend de votre modèle de données de réservation
                // Exemple simplifié:
                // predicates.add(criteriaBuilder.not(
                //     criteriaBuilder.exists(
                //         query.subquery(Reservation.class)
                //             .where(/* conditions de chevauchement de dates */)
                //     )
                // ));
            }

            // Filtre par nombre de lits
            if (criteria.getNbLits() != null && criteria.getNbLits() > 0) {
                predicates.add(criteriaBuilder.greaterThanOrEqualTo(root.get("nbLits"), criteria.getNbLits()));
            }

            // Filtre par nombre de chambres
            if (criteria.getNbChambres() != null && criteria.getNbChambres() > 0) {
                predicates.add(criteriaBuilder.greaterThanOrEqualTo(root.get("nbChambres"), criteria.getNbChambres()));
            }

            // Filtre par nombre de douches
            if (criteria.getNbDouches() != null && criteria.getNbDouches() > 0) {
                predicates.add(criteriaBuilder.greaterThanOrEqualTo(root.get("nbDouches"), criteria.getNbDouches()));
            }

            // Filtre par commodités
            if (criteria.getCommodites() != null && !criteria.getCommodites().isEmpty()) {
                for (String commodite : criteria.getCommodites()) {
                    // Supposons que les commodités sont stockées dans une relation ManyToMany ou JSON
                    // Adapter selon votre modèle de données
                    predicates.add(criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("commodites")),
                        "%" + commodite.toLowerCase() + "%"
                    ));
                }
            }

            // Filtre par préférences
            if (criteria.getPreferences() != null && !criteria.getPreferences().isEmpty()) {
                predicates.add(root.get("typeLocation").in(criteria.getPreferences()));
            }

            // Filtre par règles
            if (criteria.getRegles() != null && !criteria.getRegles().isEmpty()) {
                for (String regle : criteria.getRegles()) {
                    // Adapter selon comment les règles sont stockées
                    predicates.add(criteriaBuilder.like(
                        criteriaBuilder.lower(root.get("regles")),
                        "%" + regle.toLowerCase() + "%"
                    ));
                }
            }

            // Filtrer seulement les appartements visibles
            predicates.add(criteriaBuilder.isTrue(root.get("visible")));

            return criteriaBuilder.and(predicates.toArray(new Predicate[0]));
        };
    }
}