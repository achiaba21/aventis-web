import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/dashboard_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referrals_screen.dart';
import 'package:asfar/screen/client/shared/inbox/messaging_list_screen.dart';
import 'package:asfar/screen/client/shared/profile/client_profile_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_tabs.dart';

/// Shell du rôle Démarcheur — BottomNav + IndexedStack.
///
/// Onglets : Accueil / Demandes / Messages / Profil. Le démarcheur touche
/// sa commission dès l'acceptation de la demande par le propriétaire — il
/// n'y a pas d'écran wallet ni de mécanisme de retrait dans l'app.
class DemarcheurShell extends StatefulWidget {
  const DemarcheurShell({super.key, this.firstName});

  final String? firstName;

  @override
  State<DemarcheurShell> createState() => _DemarcheurShellState();
}

class _DemarcheurShellState extends State<DemarcheurShell> {
  int _index = 0;

  void _switchTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DemarcheurDashboard(
        firstName: widget.firstName,
        onSwitchTab: _switchTo,
      ),
      const DemarcheurReferralsScreen(),
      const MessagingListScreen(),
      const ClientProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNav(
        tabs: BottomNavTabs.demarcheur,
        current: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}
