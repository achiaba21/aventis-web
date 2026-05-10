import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/client/shared/profile/profile_display_info.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_hero_card.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_role_switcher.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_settings_card.dart';
import 'package:asfar/screen/onboarding/onboarding_screen.dart';
import 'package:asfar/screen/role_home_router.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Écran Profil transverse — partagé par les Shells locataire / démarcheur /
/// propriétaire.
///
/// Reproduit `extras.jsx::Profile` du prototype : hero card adapté au rôle
/// actif, role switcher fonctionnel (push d'un nouveau Shell via
/// [RoleHomeRouter]), card paramètres et bouton déconnexion.
///
/// Le `subtitle`, le `badge` et la liste de paramètres sont calculés via
/// [ProfileDisplayInfo.forRole] depuis `user.type`.
class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  void _onLogout(BuildContext context) {
    final user = context.read<UserBloc>().state.user;
    if (user != null) {
      context.read<UserBloc>().add(LogoutUser(user));
    }
    pushAndRemoveAll(context, const OnboardingScreen());
  }

  void _onSwitchRole(BuildContext context, String roleId) {
    final user = context.read<UserBloc>().state.user;
    if (user == null) return;
    if ((user.type ?? '').toLowerCase() == roleId) return;

    user.type = roleId;
    pushAndRemoveAll(context, RoleHomeRouter.shellFor(user));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Profil',
        trailing: IconBoutton(
          icon: Icons.settings_outlined,
          onPressed: () {},
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final user = state.user;
            final name = user?.fullName.trim().isNotEmpty == true
                ? user!.fullName
                : 'Aïcha Camara';
            final info = ProfileDisplayInfo.forRole(user?.type);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeroCard(
                    name: name,
                    subtitle: info.subtitle,
                    badge: info.badge,
                    verified: true,
                  ),
                  const SizedBox(height: 18),
                  const Text('Changer de rôle', style: AppTextStyles.h3),
                  const SizedBox(height: 10),
                  ProfileRoleSwitcher(
                    currentRole: user?.type ?? 'locataire',
                    onSwitchRole: (id) => _onSwitchRole(context, id),
                  ),
                  const SizedBox(height: 18),
                  const Text('Compte', style: AppTextStyles.h3),
                  const SizedBox(height: 10),
                  ProfileSettingsCard(
                    items: info.settingsBuilder(() {}),
                  ),
                  const SizedBox(height: 22),
                  OutlinedCustomButton(
                    text: 'Se déconnecter',
                    onPressed: () => _onLogout(context),
                    size: ButtonSize.lg,
                    block: true,
                    textColor: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Asfar v1.0 · 🇨🇮 Côte d\'Ivoire',
                      style: AppTextStyles.small.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
