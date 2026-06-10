# PRA-02 — Centraliser l'extraction du wrapper `{body, message}` dans ResponseMapper

> **Axe :** Praticité · **Sévérité :** 🟠 Élevée (duplication ×18) · **Effort :** ~4h

## Problème

Le backend Spring Boot enveloppe ses réponses dans `{body: {...}, message: "..."}`.
Chaque service réimplémente l'extraction de ce wrapper à sa façon :

- `lib/service/model/appartement/appartement_service.dart:220-234` — méthode privée `_extractBodyMap()`
- `lib/service/model/booking/reservation_service.dart:44-77` — parsing inline
  (`responseData['body']`, check `success`, etc.)
- ... et le même motif répété dans la quasi-totalité des ~18 services de `lib/service/model/`

`ResponseMapper` (`lib/util/response/response_mapper.dart`) gère déjà le mapping
listes/objets mais pas ce wrapper — chaque évolution du format backend casse N copies
(déjà vécu : fix « parsing résilient » du lot modération).

## Impact

- Tout changement du format de réponse backend = N fichiers à corriger
- Comportements divergents face aux réponses malformées (certains services throw, d'autres non)

## Marche à suivre

1. **Ajouter dans `ResponseMapper`** une méthode unique :
   ```dart
   /// Extrait le `body` du wrapper Spring Boot {body, message}.
   /// Tolère une réponse déjà "à plat" (sans wrapper).
   static Map<String, dynamic> extractBody(dynamic data) {
     if (data is Map) {
       final map = Map<String, dynamic>.from(data);
       final body = map['body'];
       if (body is Map) return Map<String, dynamic>.from(body);
       return map; // réponse déjà à plat
     }
     throw CustomException("Format de réponse invalide");
   }
   ```
   Variante liste si besoin : `extractBodyList(dynamic data)`.
2. **Écrire les tests d'abord** dans `test/util/response/response_mapper_test.dart`
   (le fichier existe déjà) : wrapper présent, réponse à plat, body null, data non-Map.
3. **Migrer service par service** (un commit par lot de 3-4 services) :
   supprimer chaque `_extractBodyMap` / parsing inline et appeler
   `ResponseMapper.extractBody(response.data)`.
   Liste des cibles : `grep -rn "_extractBodyMap\|\['body'\]" lib/service/model/`.
4. **Ne pas changer le comportement métier** pendant la migration — uniquement déplacer
   l'extraction (règle projet : pas de refactoring opportuniste au-delà du périmètre).

## Validation

- [ ] `grep -rn "_extractBodyMap" lib/` ne retourne plus rien
- [ ] Tests `response_mapper_test.dart` verts (nouveaux cas inclus)
- [ ] Parcours critiques manuels OK : login, listing appartements, création réservation
