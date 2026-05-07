import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart';
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/client/shared/notifications/widget/notifications_content.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/notification_utils.dart';
import 'package:asfar/widget/guest_login_prompt.dart';
import 'package:asfar/widget/notification/notification_connection_banner.dart';
import 'package:asfar/widget/notification/notification_filter_chips.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Page unifiée pour les notifications (locataire et propriétaire)
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _selectedFilter = NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationBloc = context.read<NotificationBloc>();
      if (notificationBloc.state is NotificationInitial) {
        notificationBloc.add(const RefreshNotifications());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is! UserLoaded) {
          if (!widget.showAppBar) {
            return const GuestLoginPrompt(
              message: "Connectez-vous pour accéder à vos notifications",
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: const TextSeed("Notifications"),
              foregroundColor: AppColors.textPrimary,
            ),
            body: const GuestLoginPrompt(
              message: "Connectez-vous pour accéder à vos notifications",
            ),
          );
        }

        final content = BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            return Column(
              children: [
                if (state is NotificationLoaded ||
                    state is WebSocketConnected ||
                    state is WebSocketDisconnected ||
                    state is WebSocketError)
                  NotificationConnectionBanner(
                    webSocketState: NotificationUtils.getWebSocketState(state),
                  ),
                Expanded(
                  child: NotificationsContent(
                    state: state,
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                ),
              ],
            );
          },
        );

        if (!widget.showAppBar) {
          return content;
        }

        return Scaffold(
          appBar: AppBar(
            title: const TextSeed("Notifications"),
            foregroundColor: AppColors.textPrimary,
          ),
          body: content,
        );
      },
    );
  }
}
