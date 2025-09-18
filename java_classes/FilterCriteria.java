package com.asfar.web.dto.filter;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDate;
import java.util.List;

/**
 * DTO pour les critères de filtrage des appartements
 */
public class FilterCriteria {

    @JsonProperty("prix_min")
    private Double prixMin;

    @JsonProperty("prix_max")
    private Double prixMax;

    @JsonProperty("date_debut")
    private LocalDate dateDebut;

    @JsonProperty("date_fin")
    private LocalDate dateFin;

    @JsonProperty("nb_lits")
    private Integer nbLits;

    @JsonProperty("nb_chambres")
    private Integer nbChambres;

    @JsonProperty("nb_douches")
    private Integer nbDouches;

    @JsonProperty("commodites")
    private List<String> commodites;

    @JsonProperty("preferences")
    private List<String> preferences;

    @JsonProperty("regles")
    private List<String> regles;

    // Constructeurs
    public FilterCriteria() {}

    public FilterCriteria(Double prixMin, Double prixMax, LocalDate dateDebut, LocalDate dateFin,
                         Integer nbLits, Integer nbChambres, Integer nbDouches,
                         List<String> commodites, List<String> preferences, List<String> regles) {
        this.prixMin = prixMin;
        this.prixMax = prixMax;
        this.dateDebut = dateDebut;
        this.dateFin = dateFin;
        this.nbLits = nbLits;
        this.nbChambres = nbChambres;
        this.nbDouches = nbDouches;
        this.commodites = commodites;
        this.preferences = preferences;
        this.regles = regles;
    }

    // Getters et Setters
    public Double getPrixMin() {
        return prixMin;
    }

    public void setPrixMin(Double prixMin) {
        this.prixMin = prixMin;
    }

    public Double getPrixMax() {
        return prixMax;
    }

    public void setPrixMax(Double prixMax) {
        this.prixMax = prixMax;
    }

    public LocalDate getDateDebut() {
        return dateDebut;
    }

    public void setDateDebut(LocalDate dateDebut) {
        this.dateDebut = dateDebut;
    }

    public LocalDate getDateFin() {
        return dateFin;
    }

    public void setDateFin(LocalDate dateFin) {
        this.dateFin = dateFin;
    }

    public Integer getNbLits() {
        return nbLits;
    }

    public void setNbLits(Integer nbLits) {
        this.nbLits = nbLits;
    }

    public Integer getNbChambres() {
        return nbChambres;
    }

    public void setNbChambres(Integer nbChambres) {
        this.nbChambres = nbChambres;
    }

    public Integer getNbDouches() {
        return nbDouches;
    }

    public void setNbDouches(Integer nbDouches) {
        this.nbDouches = nbDouches;
    }

    public List<String> getCommodites() {
        return commodites;
    }

    public void setCommodites(List<String> commodites) {
        this.commodites = commodites;
    }

    public List<String> getPreferences() {
        return preferences;
    }

    public void setPreferences(List<String> preferences) {
        this.preferences = preferences;
    }

    public List<String> getRegles() {
        return regles;
    }

    public void setRegles(List<String> regles) {
        this.regles = regles;
    }

    // Méthodes utilitaires
    public boolean hasFilters() {
        return prixMin != null || prixMax != null ||
               dateDebut != null || dateFin != null ||
               (nbLits != null && nbLits > 0) ||
               (nbChambres != null && nbChambres > 0) ||
               (nbDouches != null && nbDouches > 0) ||
               (commodites != null && !commodites.isEmpty()) ||
               (preferences != null && !preferences.isEmpty()) ||
               (regles != null && !regles.isEmpty());
    }

    @Override
    public String toString() {
        return "FilterCriteria{" +
                "prixMin=" + prixMin +
                ", prixMax=" + prixMax +
                ", dateDebut=" + dateDebut +
                ", dateFin=" + dateFin +
                ", nbLits=" + nbLits +
                ", nbChambres=" + nbChambres +
                ", nbDouches=" + nbDouches +
                ", commodites=" + commodites +
                ", preferences=" + preferences +
                ", regles=" + regles +
                '}';
    }
}