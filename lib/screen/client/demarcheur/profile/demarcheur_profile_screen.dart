import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/demarcheur.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/plain_button_expand.dart';
import 'package:asfar/widget/profile/profile_menu_item.dart';
import 'package:asfar/widget/profile/profile_section.dart';
import 'package:asfar/widget/profile/user_profile_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Page de profil pour un démarcheur
class DemarcheurProfileScreen extends StatelessWidget {
  const DemarcheurProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! UserLoaded) {
          return Center(child: TextSeed("Erreur de chargement du profil"));
        }

        final demarcheur = state.user as Demarcheur;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(Espacement.paddingBloc),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back, size: 24, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      TextSeed(
                        "Profil",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),

                UserProfileCard(client: demarcheur),

                Gap(Espacement.gapSection),

                // Badge démarcheur
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Espacement.paddingBloc),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.handshake_outlined,
                            color: AppColors.accent),
                        const SizedBox(width: 12),
                        TextSeed(
                          "Compte Démarcheur",
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),

                Gap(Espacement.gapSection * 2),

                ProfileSection(
                  title: "Mon compte",
                  children: [
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: "Informations personnelles",
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.security_outlined,
                      title: "Sécurité et confidentialité",
                      onTap: () {},
                    ),
                  ],
                ),

                Gap(Espacement.gapSection * 2),

                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Espacement.paddingBloc),
                  child: PlainButtonExpand(
                    value: "Se déconnecter",
                    onPress: () {
                      context.read<UserBloc>().add(LogoutUser(demarcheur));
                    },
                    color: AppColors.error,
                  ),
                ),

                Gap(Espacement.gapSection * 2),
              ],
            ),
          ),
          ),
        ),
        );
      },
    );
  }
}
