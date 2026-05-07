import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/signup/signup_screen.dart';
import 'package:asfar/screen/signup/widget/role_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/logo.dart';
import 'package:asfar/widget/text/text_seed.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/logo/logo.png"),
                opacity: 0.1,
                repeat: ImageRepeat.repeat,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(Espacement.paddingBloc),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Logo(),
                  SizedBox(height: Espacement.gapSection),
                  TextSeed(
                    "Qui êtes-vous ?",
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Espacement.paddingBloc),
                  RoleCard(
                    title: "Locataire",
                    subtitle: "Je cherche un logement à louer",
                    icon: Icons.home_outlined,
                    borderColor: AppColors.accent,
                    onTap: () => pushScreen(
                      context,
                      SignupScreen(role: "Locataire"),
                    ),
                  ),
                  RoleCard(
                    title: "Propriétaire",
                    subtitle: "Je propose des biens à la location",
                    icon: Icons.apartment_outlined,
                    borderColor: AppColors.accent,
                    disabled: true,
                    onTap: () {},
                  ),
                  RoleCard(
                    title: "Démarcheur",
                    subtitle: "Je mets en relation propriétaires et locataires",
                    icon: Icons.handshake_outlined,
                    borderColor: AppColors.success,
                    onTap: () => pushScreen(
                      context,
                      SignupScreen(role: "Demarcheur"),
                    ),
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
