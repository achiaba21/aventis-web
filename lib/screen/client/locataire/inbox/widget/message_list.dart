import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/widget/guest_login_prompt.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/message/message_tile.dart';
import 'package:asfar/widget/text/text_seed.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  void initState() {
    super.initState();

    // CRITIQUE: Définir l'utilisateur courant dans ConversationBloc
    // Filet de sécurité pour les cas où l'utilisateur navigue directement
    // vers l'inbox avant que le listener de main.dart ne se déclenche
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<ConversationBloc>().add(
        SetCurrentUser(user: userState.loadedUser),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Si l'utilisateur n'est pas connecté, afficher un message de connexion
        if (userState is! UserLoaded) {
          return GuestLoginPrompt(
            message: "Connectez-vous pour accéder à vos messages",
          );
        }

        final currentUserId = userState.loadedUser.id ?? 0;

        // Utilisateur connecté : afficher les conversations normalement
        return BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            // Afficher skeleton pendant le chargement initial (préchargement en cours)
            if (state is ConversationInitial) {
              return const ListShimmer(itemCount: 5);
            }

            // Afficher skeleton si ConversationBloc charge manuellement (cohérence UX)
            if (state is ConversationLoading) {
              return const ListShimmer(itemCount: 5);
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
            final conversations =
                (state is ConversationLoaded)
                    ? state.conversations
                    : (state is MessagesLoaded)
                    ? state.conversations
                    : (state is MessagesLoading)
                    ? state.conversations
                    : <Conversation>[];

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
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: conversations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) => MessageTile(
                  conversations[index],
                  currentUserId: currentUserId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
