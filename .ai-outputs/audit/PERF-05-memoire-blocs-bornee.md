# PERF-05 — Borner la mémoire des blocs (sessions longues)

> **Axe :** Fluidité / stabilité · **Sévérité :** 🟡 Moyenne · **Effort :** ~½ journée

## Problème

Les blocs gardent des collections en mémoire **sans aucune limite** :

- `lib/bloc/conversation_bloc/conversation_bloc.dart:19-22` :
  ```dart
  List<Conversation> _conversations = [];
  Map<int, List<ChatMessage>> _conversationMessages = {}; // croît sans borne
  ```
  Chaque conversation ouverte ajoute ses messages à la map, jamais purgée tant que le
  bloc vit (et les blocs sont fournis au niveau racine dans `main.dart`, donc vivent
  toute la session).
- Le cache Hive, lui, est correctement borné
  (`conversation_cache_service.dart:21-22` — 100 messages/conversation, 50 conversations
  max, purge FIFO) : **le disque est protégé, la RAM ne l'est pas**.
- Même pattern non borné sur d'autres blocs de listes (appartements, notifications).

## Impact

- Croissance mémoire continue sur sessions longues (2h+ de navigation) → ralentissements
  puis kill par l'OS (OOM), surtout sur appareils entrée de gamme

## Marche à suivre

1. **Aligner la RAM sur les limites du cache disque** dans `ConversationBloc` :
   appliquer les mêmes plafonds que `ConversationCacheService` (100 messages par
   conversation en mémoire, conversations au-delà de 50 purgées en LRU). Réutiliser
   les constantes existantes au lieu d'en dupliquer.
2. **Purge à la fermeture d'écran** : quand l'utilisateur quitte une conversation,
   tronquer `_conversationMessages[id]` aux N derniers messages (le scroll-back
   re-paginera depuis Hive/API — cf. PERF-02 étape 5).
3. **Audit des autres blocs racine** :
   ```bash
   grep -rn "List<.*> _.*= \[\]\|Map<.*> _.*= {}" lib/bloc/
   ```
   Pour chaque collection : soit elle est naturellement bornée (KPI, profil), soit lui
   appliquer un plafond.
4. **NotificationBloc (759 lignes)** : vérifier que l'historique des notifications en
   mémoire est plafonné (garder ~100, le reste vit dans Hive).
5. **Mesurer** : DevTools → Memory, scénario « ouvrir 30 conversations puis naviguer » —
   la heap doit se stabiliser au lieu de croître linéairement.

## Validation

- [ ] Heap stable (plateau) après navigation intensive en mode profile
- [ ] Ouvrir une vieille conversation purgée recharge les messages depuis Hive sans erreur
- [ ] Aucune régression sur le temps réel (un message WebSocket entrant s'affiche toujours)
