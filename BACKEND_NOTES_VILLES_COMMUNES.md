# 🛰️ Notes Backend — Villes & Communes (référentiel géographique)

> **Date :** 2026-05-11
> **Contexte :** V9.1 Wizard création appartement — l'étape 2 ("Localisation") demande au proprio de choisir une **Ville** puis une **Commune**. Actuellement (MVP) les listes sont **hardcodées côté Flutter** dans `step_location_capacity.dart`. Il faut les faire venir du backend pour que :
> - L'admin Asfar puisse ajouter/retirer des villes/communes sans déployer une nouvelle version mobile
> - Les `id` backend soient propagés dans `Address.commune.id` (cohérence référentielle)
> - D'autres écrans (carte, filtres, etc.) puissent réutiliser le même référentiel

---

## ⚡ MISE À JOUR (2026-05-11) — Découverte audit code

Vérification du code projet : **l'infra `Pays` existe déjà entièrement côté Flutter**, mais pas `Ville` ni `Commune`. Détails :

| Composant | Pays | Ville | Commune | Region |
|---|---|---|---|---|
| Modèle | ✅ `Pays` | ✅ `Ville` | ✅ `Commune` | ✅ `Region` |
| Service | ✅ `PaysService` (`api/lieux/pays`) | ❌ Manquant | ❌ Manquant | ❌ Manquant |
| BLoC | ✅ `PaysBloc` (avec `LoadAllPays`/`LoadPaysById`/`LoadPaysByCode`) | ❌ Manquant | ❌ Manquant | ❌ Manquant |
| Provider main.dart | ✅ ligne 109 | ❌ | ❌ | ❌ |

**Conséquence** : le backend Asfar a très probablement déjà un `LieuxController` exposant `/api/lieux/pays`. **À tester avant de créer de nouveaux endpoints** : il pourrait déjà supporter `/api/lieux/villes` et `/api/lieux/communes` selon la convention REST standard.

### Hiérarchie modèles Flutter
```
Pays
 └─ regions: List<Region>?
     └─ villes: List<Ville>?
         └─ communes: List<Commune>?
```

**Important** : `Pays.fromJson` parse déjà `regions` nested, `Region.fromJson` parse `villes` nested, `Ville.fromJson` parse `communes` nested. Donc **si le backend retourne le pays complet avec son arbre**, un seul appel `getPaysByCode("CI")` peut tout charger.

---

## 0bis. Deux stratégies possibles

### 🟢 Stratégie A — Exploiter `PaysService.getPaysByCode("CI")` existant
Le backend retourne déjà le pays "Côte d'Ivoire" avec toute sa hiérarchie nested. **Aucun nouveau endpoint à créer.**

**Test à faire (curl ou Postman)** :
```bash
curl -i "http://192.168.1.11:7565/api/lieux/pays/CI" \
  -H "Authorization: Bearer <token>"
```

Si la réponse contient :
```json
{
  "body": {
    "id": 225,
    "nom": "Côte d'Ivoire",
    "code": "CI",
    "regions": [
      {
        "id": 1,
        "nom": "Lagunes",
        "villes": [
          {
            "id": 1,
            "nom": "Abidjan",
            "communes": [
              { "id": 11, "nom": "Plateau" },
              { "id": 12, "nom": "Cocody" }
            ]
          }
        ]
      }
    ]
  }
}
```

→ **rien à créer côté backend**, juste consommer dans le wizard via `PaysBloc`/`PaysService` déjà providés.

### 🟡 Stratégie B — Endpoints dédiés (si A ne marche pas)
Si `PaysService.getPaysByCode("CI")` ne retourne PAS l'arbre complet (seulement `Pays` plat sans regions/villes/communes), alors créer les endpoints dédiés ci-dessous.

---

## 1. Modèles Flutter déjà en place

Les modèles existent déjà côté Flutter et sont prêts à être consommés depuis l'API.

### `lib/model/locolite/lieux/ville.dart`

```dart
class Ville extends Lieux {
  int? id;              // hérité de Lieux
  String? nom;          // hérité de Lieux
  String? code;         // hérité de Lieux
  Region? region;
  bool? ville = true;
  List<Commune>? communes;
}
```

### `lib/model/locolite/lieux/commune.dart`

```dart
class Commune extends Lieux {
  int? id;
  String? nom;
  String? code;
  bool? commune = true;
  Ville? ville;
}
```

Les deux modèles ont déjà `fromJson` / `toJson` implémentés. Le backend n'a qu'à exposer ces champs.

---

## 2. Listes actuellement hardcodées dans Flutter (à migrer)

Source : `lib/screen/client/proprio/appartements/wizard/widget/step_location_capacity.dart` lignes 32-58.

### Villes (10)

| Nom | Notes |
|---|---|
| Abidjan | Capitale économique, principale ville |
| Yamoussoukro | Capitale politique |
| Bouaké | Ville du nord-centre |
| San-Pédro | Ville portuaire sud-ouest |
| Korhogo | Nord |
| Daloa | Centre-ouest |
| Man | Ouest montagneux |
| Gagnoa | Centre-ouest |
| Abengourou | Est |
| Soubré | Sud-ouest |

### Communes Abidjan (12)

`Plateau`, `Cocody`, `Marcory`, `Treichville`, `Yopougon`, `Adjamé`, `Abobo`, `Koumassi`, `Port-Bouët`, `Attécoubé`, `Bingerville`, `Songon`

### Communes Yamoussoukro (4)

`Centre-ville`, `Habitat`, `N'Zuessy`, `Morofé`

### Autres villes (fallback générique)

`Centre-ville`, `Quartier résidentiel`

> ⚠️ Cette liste fallback est **incomplète** — l'admin Asfar doit pouvoir préciser les communes réelles de Bouaké, San-Pédro, etc.

---

## 3. Endpoints attendus côté backend (Stratégie B uniquement, si A ne marche pas)

### Endpoint 1 — Liste des villes (avec ou sans communes incluses)

**Route :** `GET /api/lieux/villes`

**Query params optionnels :**
- `withCommunes=true` — inclure le tableau `communes` dans chaque ville (réponse plus lourde mais 1 seul round-trip pour tout charger)
- `region={id}` — filtrer par région si pertinent

**Réponse 200 :**

```json
[
  {
    "id": 1,
    "nom": "Abidjan",
    "code": "ABJ",
    "type": "Ville",
    "ville": true,
    "region": { "id": 1, "nom": "Lagunes", "code": "LAG" },
    "communes": [
      { "id": 11, "nom": "Plateau", "code": "PLT", "type": "Commune", "commune": true },
      { "id": 12, "nom": "Cocody", "code": "CCD", "type": "Commune", "commune": true },
      { "id": 13, "nom": "Marcory", "code": "MCY", "type": "Commune", "commune": true }
    ]
  },
  {
    "id": 2,
    "nom": "Yamoussoukro",
    "code": "YAM",
    "type": "Ville",
    "ville": true,
    "region": { "id": 2, "nom": "Bélier", "code": "BLR" },
    "communes": [
      { "id": 21, "nom": "Centre-ville", "code": "YAM-C", "type": "Commune", "commune": true },
      { "id": 22, "nom": "Habitat", "code": "YAM-H", "type": "Commune", "commune": true }
    ]
  }
]
```

**Sans `withCommunes`** : le tableau `communes` est `null` ou absent. Le client devra appeler l'endpoint 2 pour charger les communes au besoin.

### Endpoint 2 — Communes d'une ville (lazy)

**Route :** `GET /api/lieux/villes/{villeId}/communes`

**Réponse 200 :**

```json
[
  { "id": 11, "nom": "Plateau", "code": "PLT", "type": "Commune", "commune": true, "ville": { "id": 1, "nom": "Abidjan" } },
  { "id": 12, "nom": "Cocody", "code": "CCD", "type": "Commune", "commune": true, "ville": { "id": 1, "nom": "Abidjan" } }
]
```

### Endpoint 3 (optionnel) — Recherche full-text

**Route :** `GET /api/lieux/search?q={query}&type={Ville|Commune}`

Pratique si le wizard a un input texte libre — non requis MVP V9.1 (`SearchableSelect` filtre côté client).

---

## 4. Authentification

| Route | Auth |
|---|---|
| `GET /api/lieux/villes` | **Bearer obligatoire** (préfixe `api/`) |
| `GET /api/lieux/villes/{id}/communes` | **Bearer obligatoire** |

Cohérent avec la convention Asfar `api/` vs `auth/` documentée dans `BACKEND_NOTES_MAP_V9_7B.md` :
- `auth/...` = routes publiques (pas de token)
- `api/...` = routes privées (Bearer)

> ⚠️ Alternative : si le référentiel villes/communes est public (pas de raison de le cacher), exposer aussi en `auth/lieux/villes` pour permettre le chargement avant connexion (ex: écran d'inscription proprio qui demande la ville).

---

## 5. Cache

### Côté backend
- Réponse `Cache-Control: max-age=86400` (24h) : les villes/communes ne changent presque jamais
- Optionnellement `ETag` pour permettre `If-None-Match` côté client → 304 si pas de changement

### Côté Flutter
- Réutiliser `Hive` (boxes déjà initialisées) pour cacher les listes
- TTL 24h avec refresh background au launch
- Nouveau service `LieuxService` à créer (pattern projet) :

```dart
class LieuxService {
  Future<List<Ville>> getVillesWithCommunes() async {
    // 1. Tenter cache Hive (< 24h)
    // 2. Sinon fetch GET /api/lieux/villes?withCommunes=true
    // 3. Sauvegarder en Hive
    // 4. Retourner
  }
}
```

---

## 6. Migration côté Flutter (V9.1b)

### Si Stratégie A confirmée (PaysService retourne arbre complet)

**Étape Flutter uniquement (~1h)** :
1. Au launch de l'app (ou au mount du wizard step 2), dispatch `PaysBloc.add(LoadPaysByCode('CI'))` (déjà providé globalement dans `main.dart:109`)
2. Modifier `step_location_capacity.dart` :
   - Retirer les constantes `cities`, `_communesByVille`, `_defaultCommunes`
   - Consommer `BlocBuilder<PaysBloc, PaysState>` :
     ```dart
     final pays = (state as SinglePaysLoaded).pays;
     final villes = pays.regions
         ?.expand((r) => r.villes ?? <Ville>[])
         .toList() ?? [];
     ```
   - Pour `SearchableSelect` Ville : `villes.map((v) => v.nom).whereType<String>().toList()`
   - Pour Commune : `villes.firstWhere(v => v.nom == selectedVille).communes`
3. À la création d'appart, `Address.commune` porte déjà le `Commune` complet (avec id) → backend reçoit FK propre

### Si Stratégie B requise (endpoints dédiés à créer)

**Étape 1 — Backend (~3h)** :
- Créer table SQL `ville` (id, nom, code, region_id, created_at, updated_at) si absente
- Créer table SQL `commune` (id, nom, code, ville_id, created_at, updated_at) si absente
- Seed initial avec les **10 villes** + **18 communes** listées ci-dessus
- Exposer `GET /api/lieux/villes?withCommunes=true` + `GET /api/lieux/villes/{id}/communes`

**Étape 2 — Flutter (~2h)** :
- Créer `lib/service/model/localite/ville_service.dart` (parallèle de `PaysService`)
- Optionnel : `lib/service/model/localite/commune_service.dart`
- Créer `lib/bloc/ville_bloc/ville_bloc.dart` (events : `LoadAllVilles`, `LoadCommunesForVille(id)`)
- Provider global dans `main.dart` (à côté de `PaysBloc`)
- Modifier `step_location_capacity.dart` comme décrit ci-dessus mais via `VilleBloc` au lieu de `PaysBloc`

### Étape 3 (commune aux 2 stratégies) — Cohérence Address
- L'`Address.commune` Flutter porte un `Commune` complet (id + nom + ville)
- À la sauvegarde de l'appartement, le payload backend reçoit la `commune.id` (pas que le nom)
- Le backend peut ainsi joindre proprement la commune dans ses tables (FK)

---

## 7. Plan d'exécution

### Backend (~3h)

| # | Tâche | Effort |
|---|---|---|
| B1 | Créer tables `ville` + `commune` + `region` si absente, FK ville→region, commune→ville | 30 min |
| B2 | Seed initial 10 villes + 18 communes + régions associées | 30 min |
| B3 | DTOs `VilleDto` / `CommuneDto` (id, nom, code, type, ville/commune flags) | 20 min |
| B4 | `LieuxController` avec `@GetMapping("/api/lieux/villes")` (`withCommunes` query param) + `@GetMapping("/api/lieux/villes/{id}/communes")` | 1h |
| B5 | Tests JUnit : 10 villes seedées, communes Abidjan = 12, withCommunes=true charge bien tout | 30 min |
| B6 | Cache headers (max-age 86400 + ETag) | 15 min |

### Flutter (~2h, après backend prêt)

| # | Tâche | Effort |
|---|---|---|
| F1 | `LieuxService` avec `getVillesWithCommunes()` + cache Hive 24h | 45 min |
| F2 | (Optionnel) `LieuxBloc` si on veut state management globalement, sinon FutureBuilder local | 30 min |
| F3 | Modifier `step_location_capacity.dart` pour consommer le service à la place des constantes | 20 min |
| F4 | Tests : ville sélectionnée → communes filtrées dynamiquement | 15 min |

---

## 8. Récap mémo

| Question | Réponse |
|---|---|
| Pourquoi pas hardcoder côté mobile ? | L'admin Asfar doit pouvoir ajouter une ville/commune sans nouveau déploiement |
| Infrastructure Pays existe ? | ✅ `PaysService` + `PaysBloc` + provider main.dart ligne 109 — endpoint `api/lieux/pays` |
| Infrastructure Ville/Commune existe ? | ❌ Aucun service ni Bloc côté Flutter |
| Test à faire en priorité | `curl GET /api/lieux/pays/CI` — voir si l'arbre `regions[].villes[].communes[]` est nested |
| Si arbre nested OK → | **Stratégie A** — juste consommer `PaysBloc` dans le wizard, **0 endpoint à créer** |
| Si arbre plat → | **Stratégie B** — créer `VilleService` + `CommuneService` + endpoints `/api/lieux/villes` |
| Endpoint Stratégie B principal | `GET /api/lieux/villes?withCommunes=true` |
| Auth ? | Bearer obligatoire (`api/`, comme PaysService) |
| Cache backend ? | `max-age=86400` + ETag idéalement |
| Cache Flutter ? | Hive 24h TTL, refresh background au launch |
| Listes à seeder (si Stratégie B) ? | 10 villes CI + 18 communes (12 Abidjan + 4 Yamoussoukro + 2 fallback) |
| Modèles Flutter prêts ? | ✅ `Pays`/`Region`/`Ville`/`Commune` tous implémentés avec `fromJson` nested |
| ID propagation ? | Côté Flutter, `Address.commune.id` (FK) envoyé au backend lors du save appart |

---

## 9. Référence code

- Modèle Pays : `lib/model/locolite/lieux/pays.dart` (avec `regions: List<Region>?` nested)
- Modèle Region : `lib/model/locolite/lieux/region.dart` (avec `villes: List<Ville>?` nested)
- Modèle Ville : `lib/model/locolite/lieux/ville.dart` (avec `communes: List<Commune>?` nested)
- Modèle Commune : `lib/model/locolite/lieux/commune.dart`
- **Service existant** : `lib/service/model/localite/pays_service.dart` (endpoint `api/lieux/pays`)
- **BLoC existant** : `lib/bloc/pays_bloc/` (`LoadAllPays`, `LoadPaysById`, `LoadPaysByCode`)
- **Provider main.dart** : `lib/main.dart:109` (`BlocProvider(create: (_) => PaysBloc())`)
- Listes hardcodées (à supprimer après migration) : `lib/screen/client/proprio/appartements/wizard/widget/step_location_capacity.dart:32-58`
- Usage dans le wizard : étape 2 — `SearchableSelect` Ville + Commune
- Note backend connexe : `BACKEND_NOTES_MAP_V9_7B.md` (convention `api/` vs `auth/`)
