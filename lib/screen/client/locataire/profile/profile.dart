import 'package:asfar/model/user/client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/locataire/profile/account_information.dart';
import 'package:asfar/screen/client/locataire/profile/feed.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button_expand.dart';
import 'package:asfar/widget/guest_login_prompt.dart';
import 'package:asfar/widget/profile/profile_menu_item.dart';
import 'package:asfar/widget/profile/profile_section.dart';
import 'package:asfar/widget/profile/earn_money_card.dart';
import 'package:asfar/widget/profile/user_profile_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        // Si l'utilisateur n'est pas connecté, afficher un message de connexion
        if (state is! UserLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: TextSeed("Profile"),
              foregroundColor: AppColors.textPrimary,
            ),
            body: GuestLoginPrompt(
              message: "Connectez-vous pour accéder à votre profil",
            ),
          );
        }

        // Utilisateur connecté : afficher le profil normalement
        final client = state.user as Client;

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
                UserProfileCard(client: client),

                Gap(Espacement.gapSection),

                // // Earn Money Card
                // EarnMoneyCard(
                //   onTap: () {
                //     // TODO: Navigate to "How it works" page
                //   },
                // ),
                Gap(Espacement.gapSection * 2),

                // Account Settings Section
                ProfileSection(
                  title: "Account settings",
                  children: [
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: "Account information",
                      onTap:
                          () => pushScreen(
                            context,
                            AccountInformation(client: client),
                          ),
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
                      icon: Icons.payment_outlined,
                      title: "Payment and payouts",
                      onTap: () {
                        // TODO: Navigate to Payment page
                      },
                    ),
                  ],
                ),

                Gap(Espacement.gapSection * 2),

                // Hosting Section
                ProfileSection(
                  title: "Hosting",
                  children: [
                    ProfileMenuItem(
                      icon: Icons.swap_horiz_outlined,
                      title: "Switch to hosting",
                      onTap: () {
                        // TODO: Navigate to Switch hosting page
                      },
                    ),
                    Divider(height: 1),
                    ProfileMenuItem(
                      icon: Icons.home_outlined,
                      title: "List your space",
                      onTap: () {
                        // TODO: Navigate to List space page
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
                  padding: EdgeInsets.symmetric(
                    horizontal: Espacement.paddingBloc,
                  ),
                  child: PlainButtonExpand(
                    value: "Se déconnecter",
                    onPress: () {
                      context.read<UserBloc>().add(LogoutUser(client));
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
