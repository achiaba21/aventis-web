import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/favorite/favorite_screen.dart';
import 'package:asfar/screen/client/locataire/home/home_screen.dart';
import 'package:asfar/screen/client/locataire/trips/trips_screen.dart';
import 'package:asfar/screen/client/shared/profile/client_profile_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_tabs.dart';

/// Shell du rôle Locataire — BottomNav 5 onglets + IndexedStack pour
/// préserver l'état de chaque onglet.
///
/// Onglets : Explorer / Voyages / Favoris / Messages / Profil.
class LocataireShell extends StatefulWidget {
  const LocataireShell({super.key, this.firstName});

  final String? firstName;

  @override
  State<LocataireShell> createState() => _LocataireShellState();
}

class _LocataireShellState extends State<LocataireShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.firstName ?? 'Aïcha';
    final pages = <Widget>[
      LocataireHomeScreen(firstName: firstName),
      const LocataireTripsScreen(),
      const LocataireFavoriteScreen(),
      const _MessagesPlaceholder(),
      const ClientProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNav(
        tabs: BottomNavTabs.locataire,
        current: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Placeholder de l'onglet Messages — à reconstruire en Vague 8.
class _MessagesPlaceholder extends StatelessWidget {
  const _MessagesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Messagerie à venir (Vague 8)',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text2, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
