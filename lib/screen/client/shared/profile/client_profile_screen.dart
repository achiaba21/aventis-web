// ignore_for_file: dead_code
// Le bloc `if (false)` (switcher « Changer de vue ») est une feature désactivée
// volontairement, conservée comme placeholder pour réactivation future.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/active_shell_cubit/active_shell_cubit.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/bloc/document_cubit/document_cubit.dart';
import 'package:asfar/bloc/document_cubit/document_state.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/screen/client/shared/notifications/notifications_screen.dart';
import 'package:asfar/screen/client/shared/partenariats/partenariats_screen.dart';
import 'package:asfar/screen/client/shared/profile/personal_info_screen.dart';
import 'package:asfar/screen/client/shared/profile/profile_display_info.dart';
import 'package:asfar/screen/client/shared/profile/kyc/kyc_screen.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_hero_card.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_role_switcher.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_settings_card.dart';
import 'package:asfar/screen/onboarding/onboarding_screen.dart';
import 'package:asfar/screen/role_home_router.dart';
import 'package:asfar/util/calc/kyc_status_resolver.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
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
class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Charger le statut KYC uniquement pour les rôles habilités à envoyer
      // une pièce (propriétaire / démarcheur).
      final user = context.read<UserBloc>().state.user;
      final activeView =
          context.read<ActiveShellCubit>().state ?? user?.type ?? 'locataire';
      if (_canSubmitKyc(activeView)) {
        context.read<DocumentCubit>().load();
      }
    });
  }

  bool _canSubmitKyc(String? role) {
    final r = (role ?? '').toLowerCase();
    return r == 'proprietaire' || r == 'demarcheur';
  }

  String _kycLabel(KycGlobalStatus status) {
    switch (status) {
      case KycGlobalStatus.verified:
        return 'Vérifié';
      case KycGlobalStatus.pending:
        return 'En attente';
      case KycGlobalStatus.none:
        return 'Non vérifié';
    }
  }

  bool _isKycNotification(String? titre) {
    final t = (titre ?? '').toLowerCase();
    return t.contains('identité vérifiée') || t.contains('document refusé');
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
    final cubit = context.read<ActiveShellCubit>();
    final currentView = cubit.state ?? user.type;
    if ((currentView ?? '').toLowerCase() == roleId.toLowerCase()) return;

    // V8.5 — change la vue active (différente du type de compte) et persiste.
    // user.type reste INTACT — on n'écrase pas le type de compte.
    cubit.setView(roleId);

    pushAndRemoveAll(context, RoleHomeRouter.shellFor(user, viewId: roleId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(
        title: 'Profil',
      ),
      body: SafeArea(
        top: false,
        child: BlocListener<NotificationBloc, NotificationState>(
          listenWhen: (prev, curr) => curr is NotificationReceivedState,
          listener: (context, notifState) {
            if (notifState is NotificationReceivedState &&
                _isKycNotification(notifState.notification.titre)) {
              context.read<DocumentCubit>().load();
            }
          },
          child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final user = state.user;
            final name = user?.fullName.trim().isNotEmpty == true
                ? user!.fullName
                : 'Aïcha Camara';
            final activeView = context.watch<ActiveShellCubit>().state ??
                user?.type ??
                'locataire';
            final info = ProfileDisplayInfo.forRole(activeView);
            final availableViews = user != null
                ? RoleHomeRouter.availableViewsFor(user)
                : <String>['locataire'];
            // Gate du switcher « Changer de vue » (bloc `if (false)` plus bas) :
            // conservé pour réactivation future.
            // ignore: unused_local_variable
            final canSwitchView = availableViews.length > 1;

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
                  if (false) ...[
                    const SizedBox(height: 18),
                    const Text('Changer de vue', style: AppTextStyles.h3),
                    const SizedBox(height: 10),
                    ProfileRoleSwitcher(
                      currentRole: activeView,
                      availableViews: availableViews,
                      onSwitchRole: (id) => _onSwitchRole(context, id),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Text('Compte', style: AppTextStyles.h3),
                  const SizedBox(height: 10),
                  BlocBuilder<DocumentCubit, DocumentState>(
                    builder: (context, docState) {
                      final showKyc = _canSubmitKyc(activeView);
                      return ProfileSettingsCard(
                        items: info.settingsBuilder(
                          ProfileSettingsCallbacks(
                            onPersonalInfo: () => pushScreen(
                                context, const PersonalInfoScreen()),
                            onNotifications: () => pushScreen(
                                context, const NotificationsScreen()),
                            onPartenariats: () => pushScreen(
                                context, const PartenariatsScreen()),
                            onComingSoon: () => _toast(
                                context, 'Disponible prochainement'),
                            onKyc: showKyc
                                ? () =>
                                    pushScreen(context, const KycScreen())
                                : null,
                            kycStatusLabel: showKyc
                                ? _kycLabel(docState.globalStatus)
                                : null,
                          ),
                        ),
                      );
                    },
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
      ),
    );
  }
}
