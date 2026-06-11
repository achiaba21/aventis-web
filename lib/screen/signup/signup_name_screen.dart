import 'package:flutter/material.dart';
import 'package:asfar/screen/signup/signup_pin_screen.dart';
import 'package:asfar/screen/signup/widget/signup_step_header.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Étape 3 du tunnel d'inscription : saisie du nom complet.
///
/// Atteignable uniquement après vérification OTP. Une page = une saisie =
/// un clavier : le nom utilise le clavier système, le code secret (étape
/// suivante) son clavier dédié.
class SignupNameScreen extends StatefulWidget {
  final String role;
  final String telephone;

  const SignupNameScreen({
    super.key,
    required this.role,
    required this.telephone,
  });

  @override
  State<SignupNameScreen> createState() => _SignupNameScreenState();
}

class _SignupNameScreenState extends State<SignupNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  String? _validateNom(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nom requis';
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    pushScreen(
      context,
      SignupPinScreen(
        role: widget.role,
        telephone: widget.telephone,
        nom: _nomCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthRadialBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBoutton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => back(context),
                  ),
                  const SizedBox(height: 28),
                  const SignupStepHeader(
                    step: 3,
                    titleLine1: 'Comment',
                    titleLine2: 'vous appeler ?',
                    subtitle:
                        'Votre nom complet, tel qu\'il apparaîtra sur votre profil.',
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: InputField(
                      controller: _nomCtrl,
                      eyebrow: 'NOM COMPLET',
                      hintText: 'Aïcha Camara',
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      validator: _validateNom,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Continuer',
                    onPressed: _submit,
                    size: ButtonSize.lg,
                    block: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
