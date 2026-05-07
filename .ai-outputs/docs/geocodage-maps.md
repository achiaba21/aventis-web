# Recherche par nom sur les cartes : le Géocodage

## Concept de base

La recherche par nom s'appelle le **géocodage** (geocoding). C'est la conversion d'une adresse textuelle en coordonnées GPS (latitude/longitude).

```
"Tour Eiffel, Paris" → (48.8584, 2.2945)
```

L'inverse existe aussi : le **géocodage inverse** (reverse geocoding) :
```
(48.8584, 2.2945) → "Champ de Mars, 75007 Paris"
```

---

## Comment ça fonctionne ?

```
┌─────────────────┐
│ Utilisateur     │
│ tape "Paris"    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│ API de Géocodage                    │
│ (Google, Mapbox, OpenStreetMap...)  │
│                                     │
│ Base de données contenant :         │
│ - Noms de villes                    │
│ - Adresses                          │
│ - Points d'intérêt (POI)            │
│ - Codes postaux                     │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ Réponse JSON    │
│ lat: 48.8566    │
│ lng: 2.3522     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Carte centrée   │
│ sur Paris       │
└─────────────────┘
```

---

## Les principales APIs de géocodage

| Service | Gratuit | Avantages |
|---------|---------|-----------|
| **Google Places API** | 200$/mois offerts | Très précis, autocomplétion |
| **Mapbox Geocoding** | 100k req/mois | Bon rapport qualité/prix |
| **OpenStreetMap (Nominatim)** | Illimité | Gratuit, open source |
| **Here Geocoder** | 250k req/mois | Bonne couverture mondiale |

---

## Fonctionnalités clés

### 1. Autocomplétion (Autocomplete)
L'utilisateur tape → suggestions en temps réel
```
"Par" → ["Paris", "Parc des Princes", "Parking Opéra"...]
```

### 2. Recherche avec contexte
L'API peut prioriser selon :
- La position actuelle de l'utilisateur
- Un pays/région spécifique
- Un type de lieu (ville, restaurant, adresse...)

### 3. Résultats structurés
La réponse contient généralement :
- Coordonnées (lat/lng)
- Adresse formatée
- Composants (rue, ville, pays, code postal)
- Bounding box (zone englobante)
- Type de lieu

---

## Flux typique dans une app

```
┌──────────────────────────────────────────────────────┐
│ 1. SAISIE                                            │
│    TextField avec debounce (attendre 300ms)          │
│    pour éviter trop de requêtes API                  │
└──────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────┐
│ 2. AUTOCOMPLÉTION                                    │
│    Appel API → Liste de suggestions                  │
│    Affichage dans une liste déroulante               │
└──────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────┐
│ 3. SÉLECTION                                         │
│    L'utilisateur clique sur une suggestion           │
│    → Récupération des coordonnées complètes          │
└──────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────┐
│ 4. AFFICHAGE                                         │
│    Carte animée vers les nouvelles coordonnées       │
│    Marqueur placé sur le lieu                        │
└──────────────────────────────────────────────────────┘
```

---

## Points d'attention

| Aspect | Considération |
|--------|---------------|
| **Coût** | Les APIs payantes facturent par requête |
| **Rate limiting** | Limiter les appels (debounce/throttle) |
| **Cache** | Stocker les résultats fréquents localement |
| **Fallback** | Prévoir une API de secours si la principale échoue |
| **Offline** | Le géocodage nécessite internet |
