# PERF-02 — Pagination des listes (appartements, réservations)

> **Axe :** Fluidité · **Sévérité :** 🟠 Élevée (scalabilité) · **Effort :** ~1 jour (+ backend)

## Problème

- **Appartements** : `AppartementService.getAppartements()`
  (`lib/service/model/appartement/appartement_service.dart:26`) charge **tout le
  catalogue d'un coup**. Avec quelques milliers d'annonces, le premier chargement du
  feed locataire peut atteindre 10-20 s et plusieurs Mo de JSON.
- **Réservations** : même pattern, pas de pagination.
- **Conversations** : la pagination existe côté service
  (`conversation_service.dart:154-207`, params `page`/`limit`) mais **les blocs ne
  demandent jamais la page > 1** — implémentée mais inutilisée.

## Impact

- Premier chargement lent (latence proportionnelle à la taille du catalogue)
- Transfert data massif, parsing JSON bloquant potentiellement l'isolate UI

## Marche à suivre

1. **Backend (prérequis)** : exposer `page`/`size` sur les endpoints listes
   (Spring Data `Pageable` le donne quasi gratuitement) + retour du
   `totalElements`/`hasNext` dans le body.
2. **Service** : ajouter les paramètres aux méthodes existantes sans casser les appels
   actuels :
   ```dart
   Future<List<Appartement>> getAppartements({int page = 0, int size = 30})
   ```
3. **Bloc** : ajouter un événement `LoadMoreAppartements` qui accumule
   (`state.items + nouvelles pages`) avec un flag `hasReachedEnd` ; conserver le
   pattern cache-first du repository pour la **première page uniquement**.
4. **UI** : dans les `ListView.builder` des feeds, déclencher `LoadMore` quand l'index
   construit approche la fin de liste (ou via `ScrollController` +
   `position.extentAfter < 500`). Afficher un loader discret en pied de liste.
5. **Activer la pagination conversations déjà prête** : brancher `page > 1` dans
   `conversation_bloc` sur le scroll vers le haut de l'historique.
6. **Réservations** : appliquer le même pattern dans un second temps (volume plus faible).

## Validation

- [ ] Premier affichage du feed avec page de 30 items : < 2 s sur connexion moyenne
- [ ] Scroll jusqu'en bas : pages suivantes chargées sans à-coup, pas de doublons
- [ ] Mode avion après la première page : le cache Hive affiche toujours la page 1
