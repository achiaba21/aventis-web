package com.asfar.web.entity;

import com.fasterxml.jackson.annotation.JsonProperty;
import javax.persistence.*;
import java.time.LocalDateTime;

/**
 * Entité pour les favoris utilisateur
 */
@Entity
@Table(name = "user_favorites",
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "appartement_id"}))
public class UserFavorite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "appartement_id", nullable = false)
    private Appartement appartement;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    // Constructeurs
    public UserFavorite() {
        this.createdAt = LocalDateTime.now();
    }

    public UserFavorite(User user, Appartement appartement) {
        this.user = user;
        this.appartement = appartement;
        this.createdAt = LocalDateTime.now();
    }

    // Getters et Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Appartement getAppartement() {
        return appartement;
    }

    public void setAppartement(Appartement appartement) {
        this.appartement = appartement;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    // Méthodes utilitaires pour les DTOs
    @JsonProperty("apartId")
    public Long getApartId() {
        return appartement != null ? appartement.getId() : null;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof UserFavorite)) return false;
        UserFavorite that = (UserFavorite) obj;
        return user != null && appartement != null &&
               user.equals(that.user) && appartement.equals(that.appartement);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }

    @Override
    public String toString() {
        return "UserFavorite{" +
                "id=" + id +
                ", userId=" + (user != null ? user.getId() : null) +
                ", appartementId=" + (appartement != null ? appartement.getId() : null) +
                ", createdAt=" + createdAt +
                '}';
    }
}