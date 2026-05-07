import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/client/locataire/inbox/widget/message_list.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/guest_login_prompt.dart';
import 'package:asfar/widget/text/text_seed.dart';

class Inbox extends StatelessWidget {
  const Inbox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        // Si l'utilisateur n'est pas connecté, afficher un message de connexion sans les tabs
        if (userState is! UserLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: TextSeed("Inbox"),
              foregroundColor: AppColors.textPrimary,
            ),
            body: GuestLoginPrompt(
              message:
                  "Connectez-vous pour accéder à vos messages et notifications",
            ),
          );
        }

        // Utilisateur connecté : afficher les tabs normalement
        final color = AppColors.accent;
        return DefaultTabController(
          length: 2,
          initialIndex: 1,
          child: Scaffold(
            appBar: AppBar(
              title: TextSeed("Inbox"),
              foregroundColor: AppColors.textPrimary,
              bottom: TabBar(
                dividerColor: color,
                indicatorColor: color,
                labelColor: color,
                overlayColor: WidgetStateColor.resolveWith(
                  (states) => color.withAlpha(75),
                ),
                tabs: [Tab(text: "Message"), Tab(text: "Notification")],
              ),
            ),
            body: TabBarView(children: [MessageList(), NotificationsScreen(showAppBar: false)]),
          ),
        );
      },
    );
  }
}
