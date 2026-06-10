# PRA-04 — Uniformiser l'injection de dépendances avec GetIt

> **Axe :** Praticité · **Sévérité :** 🟡 Moyenne · **Effort :** ~1 jour

## Problème

L'accès aux services depuis les blocs est incohérent :

- Certains services sont des singletons : `WebSocketService.instance`,
  `NotificationService.instance`, `DioRequest.instance`
- D'autres sont instanciés à la volée dans chaque bloc —
  `lib/bloc/appartement_bloc/appartement_bloc.dart:23-27` :
  ```dart
  AppartementBloc() : super(AppartementInitial()) {
    appartementService = AppartementService(); // nouvelle instance par bloc
  ```
- Les repositories mélangent les deux approches.

Conséquences : impossible de mocker un service dans un test de bloc sans refactoring,
et aucune visibilité sur ce qui est partagé vs instancié.

## Impact

- Blocs non testables unitairement (dépendances en dur)
- Cycle de vie des services flou (états dupliqués potentiels)

## Marche à suivre

1. **Ajouter la dépendance** :
   ```yaml
   get_it: ^8.0.0
   ```
2. **Créer `lib/config/service_locator.dart`** :
   ```dart
   final getIt = GetIt.instance;

   void setupServiceLocator() {
     getIt.registerLazySingleton<AppartementService>(() => AppartementService());
     getIt.registerLazySingleton<AppartementRepository>(() => AppartementRepository());
     // ... un registre par service/repository
   }
   ```
   Appeler `setupServiceLocator()` dans `main()` avant `runApp`.
3. **Migrer les blocs progressivement** — pattern à appliquer :
   ```dart
   AppartementBloc({AppartementService? service})
       : _service = service ?? getIt<AppartementService>(),
         super(AppartementInitial());
   ```
   Le paramètre optionnel permet d'injecter un mock en test sans GetIt.
4. **Ordre de migration** : commencer par les blocs déjà testés
   (`appartement_wizard_bloc`, `manual_reservation_wizard_bloc`) puis les blocs touchés
   par les prochaines features — **pas de migration big-bang** (règle projet :
   on n'impose SOLID qu'au nouveau code et au code touché).
5. **Conserver les singletons existants** (`WebSocketService.instance`...) en les
   enregistrant dans GetIt (`registerSingleton(WebSocketService.instance)`) pour un
   point d'accès unique sans casser l'existant.

## Validation

- [ ] `setupServiceLocator()` appelé au boot, app fonctionnelle
- [ ] Au moins un bloc migré avec un test unitaire utilisant un service mocké
- [ ] Convention documentée : « tout nouveau bloc reçoit ses dépendances via constructeur + getIt »
