import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart' as evt;
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/screen/client/shared/notifications/widget/notification_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Écran « Notifications » transverse — accessible depuis l'icône cloche
/// des dashboards (Locataire, Proprio, Démarcheur).
///
/// V8.5 Lot 10 : branché sur `NotificationBloc`. Affiche la liste des
/// `NotificationModel` triées par date décroissante. Le tap sur une ligne
/// dispatche `MarkNotificationAsRead`. Le bouton « Tout marquer comme lu »
/// dans le top-right dispatche `MarkAllNotificationsAsRead`.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationBloc>().add(const evt.LoadNotifications());
    });
  }

  void _onMarkAllAsRead() {
    context
        .read<NotificationBloc>()
        .add(const evt.MarkAllNotificationsAsRead());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Toutes les notifications marquées comme lues'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onTapNotification(NotificationModel n) {
    if (n.isUnread && n.id != null) {
      context.read<NotificationBloc>().add(evt.MarkNotificationAsRead(n.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Notifications',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
        trailing: IconBoutton(
          icon: Icons.done_all,
          onPressed: _onMarkAllAsRead,
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) return _buildLoading();
            if (state is NotificationError) {
              return EmptyState.error(
                message: state.message,
                onRetry: () => context
                    .read<NotificationBloc>()
                    .add(const evt.RefreshNotifications()),
              );
            }
            final notifications = _extractNotifications(state);
            if (notifications.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: EmptyState.hero(
                  icon: Icons.notifications_off_outlined,
                  title: 'Aucune notification',
                  body:
                      'Les nouvelles activités sur votre compte apparaîtront ici.',
                ),
              );
            }
            return _buildList(notifications);
          },
        ),
      ),
    );
  }

  List<NotificationModel> _extractNotifications(NotificationState state) {
    if (state is NotificationLoaded) return state.notifications;
    if (state is NotificationActionSuccess) return state.notifications;
    if (state is NotificationReceivedState) return state.allNotifications;
    if (state is WebSocketConnected) return state.notifications;
    if (state is WebSocketDisconnected) return state.notifications;
    if (state is WebSocketError) return state.notifications;
    return const [];
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: const [
        ShimmerCard(height: 72),
        SizedBox(height: 10),
        ShimmerCard(height: 72),
        SizedBox(height: 10),
        ShimmerCard(height: 72),
      ],
    );
  }

  Widget _buildList(List<NotificationModel> notifications) {
    final sorted = List.of(notifications)
      ..sort((a, b) =>
          (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElev1,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < sorted.length; i++)
              NotificationRow(
                notification: sorted[i],
                isLast: i == sorted.length - 1,
                onTap: () => _onTapNotification(sorted[i]),
              ),
          ],
        ),
      ),
    );
  }
}
