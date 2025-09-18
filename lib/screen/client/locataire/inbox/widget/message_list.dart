import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_event.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_state.dart';
import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/util/extensions/conversation_extensions.dart';
import 'package:web_flutter/widget/message/message_tile.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  void initState() {
    super.initState();
    // Charger les conversations au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConversationBloc>().add(const LoadConversations());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        // Afficher loading si ConversationBloc charge
        if (state is ConversationLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Afficher erreur si échec de chargement
        if (state is ConversationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextSeed("Erreur: ${state.message}"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ConversationBloc>().add(
                      const LoadConversations(forceRefresh: true),
                    );
                  },
                  child: const Text("Réessayer"),
                ),
              ],
            ),
          );
        }

        // Obtenir les conversations du state BLoC
        final conversations = (state is ConversationLoaded) ? state.conversations : <Conversation>[];

        // Afficher liste vide
        if (conversations.isEmpty) {
          return Center(child: TextSeed("Aucun element"));
        }

        // Afficher la liste des conversations
        return RefreshIndicator(
          onRefresh: () async {
            context.read<ConversationBloc>().add(
              const LoadConversations(forceRefresh: true),
            );
          },
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) => Column(
              children: [
                MessageTile(conversations[index].toSeance()),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}
