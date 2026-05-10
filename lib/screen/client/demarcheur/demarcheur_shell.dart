import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/dashboard_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referrals_screen.dart';
import 'package:asfar/screen/client/demarcheur/wallet/wallet_screen.dart';
import 'package:asfar/screen/client/shared/inbox/messaging_list_screen.dart';
import 'package:asfar/screen/client/shared/profile/client_profile_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_tabs.dart';

/// Shell du rôle Démarcheur — BottomNav 5 onglets + IndexedStack.
///
/// Onglets : Accueil / Demandes / Gains / Messages / Profil.
/// Aligné sur `BottomNavTabs.demarcheur` (Vague 2) et le proto
/// `app.jsx::tabsByRole.demarcheur`.
class DemarcheurShell extends StatefulWidget {
  const DemarcheurShell({super.key, this.firstName});

  final String? firstName;

  @override
  State<DemarcheurShell> createState() => _DemarcheurShellState();
}

class _DemarcheurShellState extends State<DemarcheurShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.firstName ?? 'Diallo';
    final pages = <Widget>[
      DemarcheurDashboard(firstName: firstName),
      const DemarcheurReferralsScreen(),
      const DemarcheurWalletScreen(),
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

