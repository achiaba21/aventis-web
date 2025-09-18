package com.asfar.web.controller;

import com.asfar.web.dto.filter.FilterCriteria;
import com.asfar.web.dto.filter.FilterOptions;
import com.asfar.web.entity.Appartement;
import com.asfar.web.service.AppartementService;
import com.asfar.web.service.FilterService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Contrôleur REST pour la gestion des appartements avec filtrage
 */
@RestController
@RequestMapping("/auth/appartement")
@CrossOrigin(origins = "*")
public class AppartementController {

    @Autowired
    private AppartementService appartementService;

    @Autowired
    private FilterService filterService;

    /**
     * Récupère tous les appartements
     */
    @GetMapping("/apparts")
    public ResponseEntity<List<Appartement>> getAllAppartements() {
        List<Appartement> appartements = appartementService.findAll();
        return ResponseEntity.ok(appartements);
    }

    /**
     * Récupère les appartements d'un propriétaire spécifique
     */
    @GetMapping("/apparts/{proprietaireId}")
    public ResponseEntity<List<Appartement>> getAppartementsByOwner(@PathVariable Long proprietaireId) {
        List<Appartement> appartements = appartementService.findByProprietaireId(proprietaireId);
        return ResponseEntity.ok(appartements);
    }

    /**
     * Filtre les appartements selon les critères fournis
     */
    @PostMapping("/filter")
    public ResponseEntity<List<Appartement>> filterAppartements(@RequestBody FilterCriteria criteria) {
        List<Appartement> appartements = filterService.filterAppartements(criteria);
        return ResponseEntity.ok(appartements);
    }

    /**
     * Récupère les options de filtrage disponibles
     */
    @GetMapping("/filter-options")
    public ResponseEntity<FilterOptions> getFilterOptions() {
        FilterOptions options = filterService.getAvailableFilterOptions();
        return ResponseEntity.ok(options);
    }

    /**
     * Récupère un appartement par ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<Appartement> getAppartementById(@PathVariable Long id) {
        Appartement appartement = appartementService.findById(id);
        return ResponseEntity.ok(appartement);
    }

    /**
     * Crée un nouvel appartement
     */
    @PostMapping("/create")
    public ResponseEntity<Appartement> createAppartement(@RequestBody Appartement appartement) {
        Appartement created = appartementService.save(appartement);
        return ResponseEntity.ok(created);
    }

    /**
     * Met à jour un appartement existant
     */
    @PutMapping("/{id}")
    public ResponseEntity<Appartement> updateAppartement(@PathVariable Long id, @RequestBody Appartement appartement) {
        appartement.setId(id);
        Appartement updated = appartementService.save(appartement);
        return ResponseEntity.ok(updated);
    }

    /**
     * Supprime un appartement
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAppartement(@PathVariable Long id) {
        appartementService.deleteById(id);
        return ResponseEntity.ok().build();
    }
}