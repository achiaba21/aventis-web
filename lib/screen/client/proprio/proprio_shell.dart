import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/listings_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/finances_screen.dart';
import 'package:asfar/screen/client/proprio/home/dashboard_screen.dart';
import 'package:asfar/screen/client/shared/profile/client_profile_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_tabs.dart';

/// Shell du rôle Propriétaire — BottomNav 5 onglets + IndexedStack.
///
/// Onglets : Accueil / Annonces / Finances / Messages / Profil.
/// Aligné sur `BottomNavTabs.proprio` (Vague 2) et le proto
/// `app.jsx::tabsByRole.proprio`.
class ProprioShell extends StatefulWidget {
  const ProprioShell({super.key, this.firstName});

  final String? firstName;

  @override
  State<ProprioShell> createState() => _ProprioShellState();
}

class _ProprioShellState extends State<ProprioShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final firstName = widget.firstName ?? 'Aminata';
    final pages = <Widget>[
      ProprioDashboard(firstName: firstName),
      const ProprioListingsScreen(),
      const ProprioFinancesScreen(),
      const _MessagesPlaceholder(),
      const ClientProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNav(
        tabs: BottomNavTabs.proprio,
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
