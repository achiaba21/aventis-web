import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/service/preload/executors/preload_executor.dart';
import 'package:asfar/util/function.dart';

/// Executor pour précharger les conversations de l'utilisateur
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : précharger les données des conversations
///
/// Note: Les conversations dépendent de la connexion WebSocket.
/// Cet executor doit être exécuté séquentiellement après l'initialisation WebSocket.
class ConversationPreloadExecutor implements PreloadExecutor {
  final ConversationBloc _conversationBloc;

  ConversationPreloadExecutor({
    required ConversationBloc conversationBloc,
  }) : _conversationBloc = conversationBloc;

  @override
  Future<void> execute() async {
    try {
      // Vérifier si les données sont déjà chargées
      final currentState = _conversationBloc.state;

      if (currentState is ConversationLoaded &&
          currentState.conversations.isNotEmpty) {
        deboger(['[ConversationPreloadExecutor] Données déjà chargées, skip preload']);
        return;
      }

      deboger(['[ConversationPreloadExecutor] Démarrage du préchargement']);

      // Déclencher le chargement des conversations
      _conversationBloc.add(const LoadConversations());

      // Attendre la fin du chargement avec timeout
      // Timeout plus court car dépend de WebSocket
      await _conversationBloc.stream
          .firstWhere(
            (state) =>
                state is ConversationLoaded ||
                state is ConversationError,
            orElse: () => _conversationBloc.state,
          )
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              deboger(['[ConversationPreloadExecutor] Timeout après 8 secondes']);
              return _conversationBloc.state;
            },
          );

      deboger(['[ConversationPreloadExecutor] Préchargement terminé']);
    } catch (e) {
      // Log l'erreur mais ne bloque pas le préchargement global
      deboger(['[ConversationPreloadExecutor] Erreur lors du préchargement: $e']);
    }
  }
}
