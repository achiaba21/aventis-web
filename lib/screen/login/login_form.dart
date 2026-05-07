import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/client/locataire/home/home.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/input/phone_input_field.dart';
import 'package:asfar/model/phone/phone_number.dart';
import 'package:asfar/widget/input/input_pass.dart';
import 'package:asfar/widget/item/login_social.dart';
import 'package:asfar/widget/logo.dart';
import 'package:asfar/widget/separate.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/widget/text/text_singup.dart';
import 'package:asfar/theme/app_colors.dart';

class LoginForm extends StatefulWidget {
  final String? phoneNumber;
  final bool isReconnection;

  const LoginForm({
    super.key,
    this.phoneNumber,
    this.isReconnection = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController tel = TextEditingController();
  TextEditingController password = TextEditingController();
  PhoneNumber phone = PhoneNumber();

  @override
  void initState() {
    super.initState();
    // Pré-remplir le numéro de téléphone si fourni
    if (widget.phoneNumber != null) {
      tel.text = widget.phoneNumber!;
    }
  }

  @override
  void dispose() {
    tel.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image/logo/logo.png"),
          opacity: 0.1,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Logo(),
            // Afficher un message différent si c'est une reconnexion
            if (widget.isReconnection) ...[
              TextSeed(
                "Session expirée",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
              Gap(Espacement.gapItem),
              TextSeed(
                "Veuillez vous reconnecter pour continuer",
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ] else
              TextSeed("Login page"),
            Gap(Espacement.gapSection),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PhoneInputField(
                    libelle: "Téléphone",
                    controller: tel,
                    onPhoneChanged: (PhoneNumber phoneNumber) {
                      // Le numéro sera automatiquement formaté
                      // et la validation se fait en temps réel
                      phone = phoneNumber;
                    },
                  ),
                  Gap(Espacement.gapItem),
                  InputPass(libelle: "Mot de passe", controller: password),
                  Gap(Espacement.gapSection),

                  CustomButton(
                    text: "Continue",
                    onPressed:
                        () => context.read<UserBloc>().add(
                          LoginUser(User(telephone: phone.internationalFormat, password: password.text)),
                        ),
                  ),
                  Gap(Espacement.gapSection),
                  Separate(data: "Ou"),
                  TextSeed("Sign up with"),
                  Gap(Espacement.gapItem),
                  LoginSocial(),

                  // Bouton pour mode invité (seulement si ce n'est pas une reconnexion)
                  if (!widget.isReconnection) ...[
                    Gap(Espacement.gapSection),
                    Center(
                      child: TextButton(
                        onPressed: () => pushAndRemoveAll(context, Home()),
                        child: TextSeed(
                          "Continuer sans se connecter",
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Spacer(),
            TextSingup(),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
