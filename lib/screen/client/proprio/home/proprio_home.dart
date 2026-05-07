import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/proprio/appartements/proprio_appart_detail_screen.dart';
import 'package:asfar/screen/client/proprio/home/widget/listings_content.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/appartement_wizard_screen.dart';
import 'package:asfar/screen/client/proprio/inbox/inbox.dart';
import 'package:asfar/screen/client/proprio/reservations/reservations_proprio.dart';
import 'package:asfar/screen/client/proprio/reservations/reservation_manuelle_form_screen.dart';
import 'package:asfar/screen/client/proprio/demarcheurs/mes_demarcheurs_screen.dart';
import 'package:asfar/screen/client/proprio/reservations/qr_scanner_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/util/notification_utils.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ProprioHome extends StatefulWidget {
  const ProprioHome({super.key});

  @override
  State<ProprioHome> createState() => _ProprioHomeState();
}

class _ProprioHomeState extends State<ProprioHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Action du bouton "+" selon l'onglet actif
  void _onAddButtonPressed() {
    if (_currentTabIndex == 0) {
      // Tab Réservations -> Ajouter réservation manuelle
      pushScreen(context, const ReservationManuelleFormScreen());
    } else {
      // Tab Listings -> Ajouter appartement (wizard guidé)
      pushScreen(context, const AppartementWizardScreen());
    }
  }

  /// Tooltip du bouton "+" selon l'onglet actif
  String get _addButtonTooltip {
    return _currentTabIndex == 0
        ? "Ajouter une réservation"
        : "Ajouter un listing";
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.accent;
    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: BlocBuilder<UserBloc, UserState>(
            builder: (context, userState) {
              final userName = userState.user?.fullName ?? "Propriétaire";
              return TextSeed(
                "Hi, $userName",
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              );
            },
          ),
          actions: [
            // Bouton Add contextuel (réservation ou listing selon tab)
            IconButton(
              onPressed: _onAddButtonPressed,
              icon: Icon(Icons.add_circle_outline),
              tooltip: _addButtonTooltip,
              color: AppColors.accent,
              iconSize: 28,
            ),
            // Icône notification avec badge
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final unreadCount = NotificationUtils.getUnreadCount(state);
                return IconButton(
                  onPressed: () {
                    pushScreen(context, const Inbox());
                  },
                  icon: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: TextStyle(fontSize: 10),
                    ),
                    child: Icon(Icons.notifications_outlined),
                  ),
                  tooltip: "Notifications",
                  color: AppColors.accent,
                  iconSize: 28,
                );
              },
            ),
            IconButton(
              onPressed: () {
                pushScreen(context, const MesDemarcheursScreen());
              },
              icon: Icon(Icons.people_outline),
              tooltip: "Mes démarcheurs",
              color: AppColors.accent,
              iconSize: 28,
            ),
            if (false)
              IconButton(
                onPressed: () {
                  pushScreen(context, const QRScannerScreen());
                },
                icon: Icon(Icons.qr_code_scanner),
                tooltip: "Scanner QR Code",
                color: AppColors.accent,
                iconSize: 28,
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            dividerColor: color,
            indicatorColor: color,
            labelColor: color,
            unselectedLabelColor: AppColors.textPrimary.withAlpha(150),
            overlayColor: WidgetStateColor.resolveWith(
              (states) => color.withAlpha(75),
            ),
            tabs: [Tab(text: "Réservations"), Tab(text: "Listings")],
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Espacement.paddingInput),
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab Réservations
                ReservationsProprio(),
                // Tab Listings
                ListingsContent(
                  onViewDetails: (appartement) {
                    pushScreen(context, ProprioAppartDetailScreen(appartement));
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}
