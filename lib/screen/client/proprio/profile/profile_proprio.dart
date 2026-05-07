import 'package:asfar/model/user/proprietaire.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/locataire/profile/account_information.dart';
import 'package:asfar/screen/client/locataire/profile/feed.dart';
import 'package:asfar/screen/client/proprio/compte/compte_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button_expand.dart';
import 'package:asfar/widget/profile/profile_menu_item.dart';
import 'package:asfar/widget/profile/profile_section.dart';
import 'package:asfar/widget/profile/user_profile_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ProfileProprio extends StatelessWidget {
  const ProfileProprio({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! UserLoaded) {
          return Center(
            child: TextSeed("Erreur de chargement du profil"),
          );
        }

        // Utilisateur connecté : afficher le profil normalement
        final proprio = state.user as Proprietaire;

        return Container(
          color: AppColors.background,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(Espacement.paddingBloc),
                  child: TextSeed(
                    "Profile",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // User Info Card
                UserProfileCard(client: proprio),

                Gap(Espacement.gapSection),

                Gap(Espacement.gapSection * 2),

                // Account Settings Section
                ProfileSection(
                  title: "Account settings",
                  children: [
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: "Account information",
                      onTap: () => pushScreen(context, AccountInformation(client: proprio)),
                    ),
                    Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.security_outlined,
                      title: "Security and privacy",
                      onTap: () {
                        // TODO: Navigate to Security page
                      },
                    ),
                    Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Mon Compte",
                      onTap: () => pushScreen(context, const CompteScreen()),
                    ),
                  ],
                ),

                Gap(Espacement.gapSection * 2),

                // Hosting Section
                ProfileSection(
                  title: "Hosting",
                  children: [
                    ProfileMenuItem(
                      icon: Icons.home_work_outlined,
                      title: "Mes résidences",
                      onTap: () {
                        // TODO: Navigate to mes résidences page
                      },
                    ),
                    Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.apartment_outlined,
                      title: "Mes appartements",
                      onTap: () {
                        // TODO: Navigate to mes appartements page
                      },
                    ),
                    Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.add_home_outlined,
                      title: "Add a new property",
                      onTap: () {
                        // TODO: Navigate to add property page
                      },
                    ),
                  ],
                ),

                Gap(Espacement.gapSection * 2),

                // Support Section
                ProfileSection(
                  title: "Support",
                  children: [
                    ProfileMenuItem(
                      icon: Icons.help_outline,
                      title: "How does Asansa work",
                      onTap: () {
                        // TODO: Navigate to How it works page
                      },
                    ),
                    Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.question_answer_outlined,
                      title: "Frequently asked questions",
                      onTap: () {
                        // TODO: Navigate to FAQ page
                      },
                    ),
                    Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.feedback_outlined,
                      title: "Envoyé des avis",
                      onTap: () => pushScreen(context, Feed()),
                    ),
                  ],
                ),

                Gap(Espacement.gapSection * 2),

                // Logout Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
                  child: PlainButtonExpand(
                    value: "Se déconnecter",
                    onPress: () {
                      context.read<UserBloc>().add(LogoutUser(proprio));
                    },
                    color: AppColors.error,
                  ),
                ),

                Gap(Espacement.gapSection * 2),
              ],
            ),
          ),
        );
      },
    );
  }
}