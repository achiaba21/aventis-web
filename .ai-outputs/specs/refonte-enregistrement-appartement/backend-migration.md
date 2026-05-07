# 🔧 Migration Backend — BACKEND-FLAT-APPART

**Cible** : Spring Boot (backend Asfar)
**Objectif** : aligner le backend sur le nouveau modèle plat côté client.
**Effet attendu** : suppression de la couche `AppartementBackendMapper` côté Flutter une fois le backend déployé.

---

## 1. Vue d'ensemble

| Composant | Avant | Après |
|---|---|---|
| **Schéma BDD** | `appartement.residence_id → residence.address_id → address` | `appartement.address_id → address` |
| **Entité JPA** | `Appartement` ↔ `Residence` ↔ `Address` | `Appartement` ↔ `Address` |
| **Endpoint REST** | `POST /appartement/new` reçoit `{ residence: { address: {…} } }` | reçoit `{ address: {…} }` directement |
| **Endpoints résidence** | `POST/PUT/GET /api/proprietaire/residence` | **Supprimés** |

---

## 2. Plan en 6 étapes (zero-downtime conseillé)

### Étape A — Migration BDD (Flyway/Liquibase)

```sql
-- V20XX__flat_appartement_address.sql

-- 1) Ajouter la colonne address_id sur appartement
ALTER TABLE appartement
  ADD COLUMN address_id BIGINT NULL,
  ADD CONSTRAINT fk_appartement_address
      FOREIGN KEY (address_id) REFERENCES address(id);

-- 2) Backfill : copier l'address de la résidence parente vers chaque appart
UPDATE appartement a
SET address_id = (
    SELECT r.address_id
    FROM residence r
    WHERE r.id = a.residence_id
)
WHERE a.address_id IS NULL
  AND a.residence_id IS NOT NULL;

-- 3) Vérification (à lancer en console après migration)
SELECT COUNT(*) AS apparts_orphelins
FROM appartement
WHERE address_id IS NULL;
-- Si > 0, ces appartements n'avaient pas de résidence parente avec address.
-- Décision produit : les laisser tels quels (proprio devra compléter via le wizard)
-- OU rejeter la migration et investiguer.

-- 4) Index pour les requêtes de filtrage
CREATE INDEX idx_appartement_address_id ON appartement(address_id);
```

> **Important** : ne pas encore supprimer `appartement.residence_id` ni la table `residence` à cette étape. La compatibilité descendante est requise pendant la transition.

### Étape B — Adapter l'entité JPA `Appartement`

```java
// Avant
@Entity
public class Appartement {
    @ManyToOne
    @JoinColumn(name = "residence_id")
    private Residence residence;
    // …
}

// Après
@Entity
public class Appartement {
    @ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JoinColumn(name = "address_id")
    private Address address;

    // ⚠️ CONSERVÉ TEMPORAIREMENT pour rétrocompat — voir Étape F
    @Deprecated
    @ManyToOne
    @JoinColumn(name = "residence_id")
    private Residence residence;
}
```

### Étape C — Adapter les DTOs / requêtes REST

**Avant** (lecture & écriture) :
```json
{
  "id": 42,
  "titre": "Studio Cocody",
  "residence": {
    "id": 7,
    "nom": "Auto",
    "address": { "lat": 5.34, "longi": -4.02, "nom": "…" }
  }
}
```

**Après** :
```json
{
  "id": 42,
  "titre": "Studio Cocody",
  "address": { "lat": 5.34, "longi": -4.02, "nom": "…" }
}
```

DTOs Java :
```java
// AppartementDto.java
public class AppartementDto {
    private Long id;
    private String titre;
    private AddressDto address;   // ← top-level
    // … plus de champ residence ni residenceId
}

// AppartementCreateRequest.java
public class AppartementCreateRequest {
    @NotBlank private String titre;
    @NotNull  private AddressDto address;
    @Positive private Double prix;
    // …
}
```

### Étape D — Endpoints à modifier

| Endpoint | Action |
|---|---|
| `POST /api/proprietaire/appartement/new` | Accepter `address` au top-level. Créer/réutiliser une `Address` (pas de `Residence` virtuelle). |
| `POST /api/proprietaire/appartement/new-with-images` | Idem (multipart) |
| `PUT /api/proprietaire/appartement/{id}` | Idem |
| `GET /api/proprietaire/appartement/appartements` | Retourne `Appartement` avec `address` (et plus `residence`) |
| `GET /auth/appartement/apparts` | Idem |
| `DELETE /auth/appartement/{id}` | Inchangé |

**Endpoints à supprimer** (après vérification qu'aucun client legacy ne les utilise) :
- `GET /api/proprietaire/residence`
- `GET /api/proprietaire/residence/all-client`
- `GET /api/proprietaire/residence/{id}`
- `POST /api/proprietaire/residence`
- `PUT /api/proprietaire/residence/{id}`
- `DELETE /api/proprietaire/residence/{id}`

### Étape E — Adapter le service / repository JPA

```java
// AppartementService.java

@Transactional
public Appartement create(AppartementCreateRequest req, Proprietaire proprietaire) {
    Address address = addressRepository.save(toAddress(req.getAddress()));

    Appartement appart = new Appartement();
    appart.setTitre(req.getTitre());
    appart.setAddress(address);
    appart.setProprietaire(proprietaire);
    // …
    return appartementRepository.save(appart);
}

// Filtres par ville/commune (utilisés côté locataire/démarcheur)
public List<Appartement> findByCommune(Long communeId) {
    return appartementRepository.findByAddressCommuneId(communeId);
}
public List<Appartement> findByVille(Long villeId) {
    return appartementRepository.findByAddressCommuneVilleId(villeId);
}
```

`AppartementRepository.java` (Spring Data JPA) :
```java
public interface AppartementRepository extends JpaRepository<Appartement, Long> {
    List<Appartement> findByAddressCommuneId(Long communeId);
    List<Appartement> findByAddressCommuneVilleId(Long villeId);
    List<Appartement> findByProprietaireId(Long proprietaireId);
}
```

### Étape F — Cleanup BDD final (à reporter de quelques jours)

Après que le client Flutter ait été mis à jour, déployé, et que la rétrocompat ne soit plus nécessaire :

```sql
-- V20XX+1__cleanup_residence.sql

-- 1) Drop FK residence_id sur appartement
ALTER TABLE appartement
  DROP CONSTRAINT IF EXISTS fk_appartement_residence,
  DROP COLUMN residence_id;

-- 2) Drop la table residence
DROP TABLE residence;
```

Côté Java :
```java
// Appartement.java — supprimer le champ deprecated
// (nettoyer aussi ResidenceController, ResidenceService, ResidenceRepository, Residence entity)
```

---

## 3. Cas particuliers à traiter

### 3.1 Fusion d'addresses dupliquées

Plusieurs apparts d'un même proprio partageaient leur `address_id` (ils étaient sous la même résidence). Avec le nouveau modèle, c'est toujours valide (`address` peut être partagée). Mais si vous voulez que **chaque appart ait son adresse propre** (recommandé pour éviter les effets de bord à l'édition) :

```sql
-- Cloner l'address pour chaque appart partageant un même address_id
WITH duplicated_addresses AS (
    SELECT address_id
    FROM appartement
    WHERE address_id IS NOT NULL
    GROUP BY address_id
    HAVING COUNT(*) > 1
)
INSERT INTO address (lat, longi, nom, description, commune_id, geo_lat, geo_longi)
SELECT a.lat, a.longi, a.nom, a.description, a.commune_id, a.geo_lat, a.geo_longi
FROM appartement ap
JOIN address a ON a.id = ap.address_id
JOIN duplicated_addresses d ON d.address_id = ap.address_id
WHERE ap.id NOT IN (
    SELECT MIN(ap2.id) FROM appartement ap2 WHERE ap2.address_id = ap.address_id
);
-- (puis UPDATE appartement.address_id pour pointer vers les nouvelles addresses)
```

> Optionnel — à décider selon la sémantique métier souhaitée.

### 3.2 Gestion des charges qui référençaient une résidence

Les charges en BDD ont un champ `residence_id` (cf. `Charge.java`). Décision :
- **Option A** : conserver le champ `residence_id` comme info historique (nullable, plus alimenté).
- **Option B** : drop le champ + migration des charges pour ne garder que `appartement_id`.

Le client Flutter a déjà neutralisé le filtre par résidence en comptabilité — donc l'option A suffit techniquement.

### 3.3 Données du locataire (favoris, réservations)

`Reservation.appart_id` et `Favorite.appart_id` ne référencent que des appartements → **aucune migration nécessaire**.

---

## 4. Tests à mettre à jour

| Test | Action |
|---|---|
| `AppartementServiceTest` | Update : assertions sur `appart.getAddress()` au lieu de `appart.getResidence().getAddress()` |
| `ResidenceServiceTest` | **Supprimer** (en même temps que la classe) |
| Tests d'intégration REST | Update : payload sans `residence` wrapper |
| Tests de migration | Ajouter test de l'étape A (backfill du address_id) |

---

## 5. Cleanup côté client Flutter (après déploiement backend)

Une fois le backend déployé, lancer un **lot de simplification** côté Flutter :

### À supprimer
- `lib/service/model/appartement/appartement_backend_mapper.dart` (intégralement)
- `lib/service/migration/legacy_residence_migration.dart` (intégralement, après ~1 mois en prod pour laisser le temps à tous les utilisateurs de migrer)

### À simplifier
- `lib/service/repository/appartement_repository.dart` :
  - Drop import du mapper
  - Drop le cache `Map<int, int> _backendResidenceIds`
  - Drop le helper `_persistAndReturn` (devient un simple parsing JSON standard)
  - `saveAppartement(appart)` → `_apiService.saveAppartement(appart.toJson())` directement
- `lib/service/model/appartement/appartement_service.dart` :
  - Les méthodes peuvent à nouveau prendre/retourner directement `Appartement` au lieu de `Map`
- `lib/model/residence/appart.dart` :
  - **Supprimer la fusion défensive** dans `Appartement.fromJson` (le bloc qui lit `json['residence']?['address']`)
  - Le commentaire "TODO BACKEND-FLAT-APPART" doit disparaître
- `lib/main.dart` :
  - Drop l'appel `LegacyResidenceMigration.instance.runIfNeeded()` (après ~1 mois)

### Garde-fou final côté client
```bash
grep -rn "BACKEND-FLAT-APPART" lib/
# Doit retourner 0 résultat → preuve que la dette est éteinte.
```

---

## 6. Ordre de déploiement recommandé (zero-downtime)

```
Jour J     : Étape A (migration BDD additive : ajout address_id, backfill)
             → BDD prête, ancien et nouveau code coexistent

Jour J+1   : Étape B + C + D + E (déploiement backend)
             → API expose le nouveau format. Ancien client Flutter
               continue de fonctionner grâce à la sérialisation
               compatible (residence wrapper laissé en lecture).

Jour J+7   : Cleanup côté Flutter (lot dédié)
             → Le mapper est supprimé, app simplifiée.

Jour J+30  : Étape F (cleanup BDD : drop residence_id, drop table residence)
             → Aucun client legacy en production.
```

> **Astuce rétrocompat** : pendant la phase J+1 → J+30, le backend peut **émettre les deux formats** dans les réponses (`residence: { address }` ET `address`) en utilisant un sérialiseur Jackson custom. Cela permet aux anciennes versions de l'app de continuer à fonctionner sans cassure.

---

## 7. Estimation d'effort

| Tâche | Effort estimé |
|---|---|
| Migration SQL (A + F) | 1 j (avec tests sur env staging) |
| Refonte entités/DTOs (B, C) | 0.5 j |
| Refonte controllers + services (D, E) | 1 j |
| Mise à jour des tests | 0.5 j |
| Cleanup côté Flutter | 0.5 j |
| **Total** | **~3.5 j** |

---

## 8. Risques & mitigations

| Risque | Probabilité | Mitigation |
|---|:-:|---|
| Apparts orphelins en backfill (résidence sans address) | Faible | Vérification SQL préalable + flag UI déjà géré côté client |
| Anciens clients Flutter cassés après bascule API | Moyenne | Sérialisation **dual-format** pendant la période transitoire |
| Charges référençant residence_id orphelin | Moyenne | Garder le champ nullable (option A) ; le client a déjà désactivé le filtre |
| Régression en prod sur endpoints critiques | Faible | Déploiement progressif (canary) + tests E2E avant chaque étape |

---

## 9. Checklist de validation post-déploiement

- [ ] `POST /api/proprietaire/appartement/new` accepte `{ titre, address: {…} }` directement
- [ ] `GET /api/proprietaire/appartement/appartements` retourne `address` au top-level
- [ ] Aucun appel à `/api/proprietaire/residence/*` dans les logs
- [ ] Création d'un appart depuis le wizard Flutter fonctionne sans le mapper (test après cleanup côté client)
- [ ] Filtre par ville/commune côté locataire toujours fonctionnel
- [ ] Charges en mode offline toujours rattachées à leur appartement
- [ ] Migration BDD réversible documentée (backup avant Étape F)
