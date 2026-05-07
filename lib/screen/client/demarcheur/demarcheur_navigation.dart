import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/client/demarcheur/home/demarcheur_home.dart';
import 'package:asfar/screen/client/demarcheur/partenariat/demarcheur_partenariat_screen.dart';
import 'package:asfar/screen/client/demarcheur/profile/demarcheur_profile_screen.dart';
import 'package:asfar/screen/client/demarcheur/reservations/demarcheur_reservations_screen.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_item.dart';

/// Navigation principale du démarcheur (4 onglets + profil en AppBar)
class DemarcheurNavigation extends StatefulWidget {
  const DemarcheurNavigation({super.key});

  @override
  State<DemarcheurNavigation> createState() => _DemarcheurNavigationState();
}

class _DemarcheurNavigationState extends State<DemarcheurNavigation> {
  int _currentIndex = 0;

  static final List<BottomNavItem> _menuItems = [
    BottomNavItem(text: "Appartements", image: Icons.apartment),
    BottomNavItem(text: "Réservations", image: Icons.event_note_outlined),
    BottomNavItem(text: "Partenariats", image: Icons.handshake_outlined),
    BottomNavItem(text: "Notifications", image: Icons.notifications_outlined),
  ];

  final List<Widget> _pages = [
    const DemarcheurHome(),
    const DemarcheurReservationsScreen(),
    const DemarcheurPartenariatScreen(),
    const NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserInitial) {
          pushAndRemoveAll(context, const LoginScreen());
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        child: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                Expanded(child: _pages[_currentIndex]),
                BottomNav(
                  items: _menuItems,
                  currentIndex: _currentIndex,
                  onTap: (index, _) => setState(() => _currentIndex = index),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
