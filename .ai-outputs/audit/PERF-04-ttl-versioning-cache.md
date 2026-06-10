# PERF-04 — TTL actif et versioning du cache Hive

> **Axe :** Fluidité / fiabilité · **Sévérité :** 🟡 Moyenne · **Effort :** ~3h

## Problème

Le pattern cache-first des repositories est bon (cache rendu immédiatement, refresh en
arrière-plan), mais son invalidation est passive :

- `lib/service/repository/appartement_repository.dart:246-252` — `isCacheStale()`
  existe (TTL 24h par défaut) mais **rien ne l'appelle automatiquement** : l'invalidation
  ne se produit que sur `forceRefresh` explicite. Un utilisateur peut voir des données
  vieilles de 24h.
- **Pas de versioning du schéma de cache** : si le backend change la structure JSON,
  les données Hive existantes restent incompatibles jusqu'à un vidage manuel
  (source probable de bugs de parsing du type corrigé dans le lot modération).
- `lib/service/repository/charge_repository.dart` — cache **uniquement local, jamais
  synchronisé avec l'API** : risque de désynchronisation durable.

## Impact

- Données périmées affichées (prix, disponibilités, statuts d'annonces)
- Crashs/parsing silencieusement faux après une mise à jour backend

## Marche à suivre

1. **TTL actif** : dans chaque repository, au moment du `get` cache-first, déclencher le
   refresh arrière-plan **systématiquement si `isCacheStale(maxAge)`** — avec un TTL
   réaliste par domaine (ex. appartements 1h, réservations 15 min) au lieu de 24h.
2. **Versioning du cache** : ajouter une constante par repository :
   ```dart
   static const int _cacheVersion = 1; // incrémenter à chaque changement de schéma
   ```
   Stocker la version dans la box ; au boot, si la version stockée diffère, vider la
   box concernée avant utilisation. Incrémenter `_cacheVersion` à chaque modification
   de modèle (`Appartement`, `Reservation`...).
3. **Parsing défensif du cache** : entourer la désérialisation Hive d'un try/catch qui
   vide la box et refetch en cas d'échec (même philosophie que le ResponseMapper
   résilient déjà en place).
4. **ChargeRepository** : décider du statut — soit le brancher sur un endpoint de sync,
   soit documenter explicitement qu'il est local-only (et l'exclure des écrans qui
   suggèrent une donnée serveur).
5. **Invalidation ciblée via WebSocket** : les événements temps réel
   (`realtime_action_handler.dart`) mettent déjà à jour les entités — vérifier qu'ils
   **écrivent aussi dans le cache Hive**, pas seulement dans l'état mémoire du bloc.

## Validation

- [ ] Cache vieilli artificiellement (modifier le timestamp) → refresh auto au prochain affichage
- [ ] Incrémenter `_cacheVersion` → box vidée au boot, refetch propre, pas de crash
- [ ] Donnée corrompue injectée dans la box → l'app refetch au lieu de crasher
