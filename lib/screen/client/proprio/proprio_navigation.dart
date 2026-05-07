import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/home/proprio_home.dart';
import 'package:asfar/screen/client/proprio/calendrier/global_calendar_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/comptabilite_screen.dart';
import 'package:asfar/screen/client/proprio/profile/profile_proprio.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_item.dart';

class ProprioNavigation extends StatefulWidget {
  const ProprioNavigation({super.key});

  @override
  State<ProprioNavigation> createState() => _ProprioNavigationState();
}

class _ProprioNavigationState extends State<ProprioNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser le ChargeBloc avec les résidences
    _syncChargeData();
  }

  void _syncChargeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chargeBloc = context.read<ChargeBloc>();

      // Injecter les appartements (pour le mode offline)
      final appartementState = context.read<AppartementBloc>().state;
      chargeBloc.setAppartements(appartementState.appartements);

      // Charger les charges
      chargeBloc.add(LoadCharges());
    });
  }

  List<BottomNavItem> _buildMenu(int alertCount, int pendingReservations) {
    return [
      BottomNavItem(text: "Home", image: Icons.home),
      BottomNavItem(
        text: "Calendrier",
        image: Icons.calendar_month,
        badgeCount: pendingReservations,
      ),
      BottomNavItem(
        text: "Compta",
        image: Icons.analytics_outlined,
        badgeCount: alertCount,
      ),
      BottomNavItem(text: "Profil", image: Icons.person),
    ];
  }

  final List<Widget> _pages = [
    ProprioHome(),
    GlobalCalendarScreen(),
    ComptabiliteScreen(),
    ProfileProprio(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            // Détecter la déconnexion et rediriger vers login
            if (state is UserInitial) {
              pushAndRemoveAll(context, const LoginScreen());
            }
          },
        ),
        // Synchroniser les appartements vers ChargeBloc (pour le mode offline)
        BlocListener<AppartementBloc, AppartementState>(
          listener: (context, state) {
            context.read<ChargeBloc>().setAppartements(state.appartements);
          },
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Expanded(child: _pages[_currentIndex]),
              BlocBuilder<ChargeBloc, ChargeState>(
                builder: (context, chargeState) {
                  // Afficher le nombre d'alertes (charges en retard/à venir)
                  int alertCount = 0;
                  if (chargeState is ChargeLoaded) {
                    alertCount = chargeState.nombreAlertes;
                  }

                  return BlocBuilder<ReservationBloc, ReservationState>(
                    builder: (context, reservationState) {
                      // Calculer le nombre de réservations en attente
                      int pendingReservations = 0;
                      if (reservationState is ReservationLoaded) {
                        pendingReservations = reservationState.reservations
                            .where((r) => r.statut == ReservationStatus.enAttente)
                            .length;
                      }

                      return BottomNav(
                        items: _buildMenu(alertCount, pendingReservations),
                        currentIndex: _currentIndex,
                        onTap: onTap,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTap(int index, BuildContext context) {
    setState(() {
      _currentIndex = index;
    });
  }
}
