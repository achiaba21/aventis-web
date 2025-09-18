package com.asfar.web.dto.filter;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/**
 * DTO pour les options de filtrage disponibles
 */
public class FilterOptions {

    @JsonProperty("commodites")
    private List<String> commodites;

    @JsonProperty("preferences")
    private List<String> preferences;

    @JsonProperty("regles")
    private List<String> regles;

    @JsonProperty("prix_min")
    private Double prixMin;

    @JsonProperty("prix_max")
    private Double prixMax;

    // Constructeurs
    public FilterOptions() {}

    public FilterOptions(List<String> commodites, List<String> preferences,
                        List<String> regles, Double prixMin, Double prixMax) {
        this.commodites = commodites;
        this.preferences = preferences;
        this.regles = regles;
        this.prixMin = prixMin;
        this.prixMax = prixMax;
    }

    // Getters et Setters
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

    @Override
    public String toString() {
        return "FilterOptions{" +
                "commodites=" + commodites +
                ", preferences=" + preferences +
                ", regles=" + regles +
                ", prixMin=" + prixMin +
                ", prixMax=" + prixMax +
                '}';
    }
}