import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart' as events;
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/widget/guest_login_prompt.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/notification/notification_tile.dart';
import 'package:asfar/widget/text/text_seed.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  // Plus besoin de initState() - le préchargement s'en occupe automatiquement

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Si l'utilisateur n'est pas connecté, afficher un message de connexion
        if (userState is! UserLoaded) {
          return GuestLoginPrompt(
            message: "Connectez-vous pour accéder à vos notifications",
          );
        }

        // Utilisateur connecté : afficher les notifications normalement
        return BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            // Afficher skeleton pendant le chargement initial (préchargement en cours)
            if (state is NotificationInitial) {
              return const ListShimmer(itemCount: 5);
            }

            // Afficher skeleton pendant le chargement manuel (cohérence UX)
            if (state is NotificationLoading) {
              return const ListShimmer(itemCount: 5);
            } else if (state is NotificationLoaded) {
              final notifs = state.notifications;

              if (notifs.isEmpty) {
                return Center(child: TextSeed("Aucune notification"));
              }

              return ListView.builder(
                itemCount: notifs.length,
                itemBuilder:
                    (context, index) => NotificationTile(notif: notifs[index]),
              );
            } else if (state is NotificationError) {
              return Center(child: TextSeed("Erreur: ${state.message}"));
            }

            return Center(child: TextSeed("Aucune notification"));
          },
        );
      },
    );
  }
}
