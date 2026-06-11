import 'package:flutter/material.dart';
import 'package:asfar/screen/signup/signup_pin_confirm_screen.dart';
import 'package:asfar/screen/signup/widget/pin_dots_display.dart';
import 'package:asfar/screen/signup/widget/pin_keypad.dart';
import 'package:asfar/screen/signup/widget/signup_step_header.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';

/// Étape 4 du tunnel d'inscription : création du code secret (PIN 5 chiffres).
///
/// Saisie exclusivement via le clavier dédié [PinKeypad] — aucun clavier
/// système sur cette page. La confirmation se fait sur l'écran suivant.
class SignupPinScreen extends StatefulWidget {
  final String role;
  final String telephone;
  final String nom;

  const SignupPinScreen({
    super.key,
    required this.role,
    required this.telephone,
    required this.nom,
  });

  @override
  State<SignupPinScreen> createState() => _SignupPinScreenState();
}

class _SignupPinScreenState extends State<SignupPinScreen> {
  static const int _pinLength = 5;
  String _pin = '';

  void _onDigit(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() => _pin += digit);
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _submit() {
    if (_pin.length != _pinLength) return;
    pushScreen(
      context,
      SignupPinConfirmScreen(
        role: widget.role,
        telephone: widget.telephone,
        nom: widget.nom,
        pin: _pin,
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
                    step: 4,
                    titleLine1: 'Votre',
                    titleLine2: 'code secret.',
                    subtitle: 'Choisissez un code à 5 chiffres. Il vous '
                        'servira à vous connecter.',
                  ),
                  const SizedBox(height: 32),
                  PinDotsDisplay(filledCount: _pin.length),
                  const SizedBox(height: 32),
                  PinKeypad(
                    onDigit: _onDigit,
                    onBackspace: _onBackspace,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'Continuer',
                    onPressed: _pin.length == _pinLength ? _submit : null,
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
