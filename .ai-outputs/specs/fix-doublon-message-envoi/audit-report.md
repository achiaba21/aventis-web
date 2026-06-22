# Rapport d'audit — Correctif « doublon message à l'envoi »

**Date :** 2026-06-22
**Mode :** 🟡 Feature Light
**Verdict :** ✅ VALIDÉ — **98/100**

## Périmètre

| Fichier | Nature |
|---|---|
| `lib/util/chat_message_merger.dart` | créé |
| `lib/bloc/conversation_bloc/conversation_event.dart` | modifié (`MessageReceived.conversationId`) |
| `lib/bloc/conversation_bloc/conversation_bloc.dart` | modifié (`_onSendMessage`, `_onMessageReceived`) |
| `lib/screen/client/shared/inbox/messaging_thread_screen.dart` | modifié (topic passe `conversationId`) |
| `test/util/chat_message_merger_test.dart` | créé (10 tests) |

## Scores

| Dimension | Score | Constats |
|---|---|---|
| Complexité | 90 | `upsert` CC ~9 (< 10), 3 params, imbrication 2. `_onMessageReceived` ~50 lignes (pré-existant). |
| Lisibilité | 100 | Noms explicites, aucun magic number, lignes < 120. |
| DRY | 100 | Dédup centralisée (était dupliquée send/receive). |
| Documentation | 100 | Doc classe + méthode (WHY), commentaires par branche. |
| SOLID | 100 | SRP, fonction pure, testable isolément. |
| Dette technique | 100 | Aucun TODO/print/catch vide/code commenté. |
| **GLOBAL** | **98** | ✅ VALIDÉ |

## Vérifications

- `flutter analyze` (fichiers touchés) : 0 nouvelle issue.
- `flutter test test/util/chat_message_merger_test.dart` : 10/10 verts.
- Suite complète : 306/306 verts (aucune régression).

## Cause racine corrigée

Le message optimiste (identifié par `tempId`, `id == null`) et l'écho temps réel
(identifié par `id` serveur) n'étaient jamais réconciliés. Quand l'écho WS gagnait
la course contre la réponse HTTP, il s'ajoutait comme 2ᵉ bulle. `ChatMessageMerger.upsert`
fait converger toutes les insertions vers un point idempotent : réconciliation de
l'optimiste + dédup par `id`, quel que soit l'ordre ou le nombre de livraisons.
