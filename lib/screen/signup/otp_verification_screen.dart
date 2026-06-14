import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/signup/signup_name_screen.dart';
import 'package:asfar/screen/signup/widget/otp_code_input.dart';
import 'package:asfar/screen/signup/widget/signup_step_header.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/helper/app_snackbar.dart';
import 'package:asfar/util/helper/otp_resend_policy.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';

/// Étape 2 du tunnel d'inscription : vérification du numéro par OTP.
///
/// L'utilisateur saisit le code SMS à 4 chiffres reçu sur [telephone] ;
/// la vérification ([VerifyOtp]) précède toute saisie d'identité ou de mot
/// de passe. Sur [OtpVerified], l'écran est remplacé par [SignupNameScreen]
/// (un retour arrière ne revient jamais sur un OTP consommé).
///
/// Renvoi de code à délais progressifs via [OtpResendPolicy] —
/// les tentatives et le blocage sont gérés côté backend.
class OtpVerificationScreen extends StatefulWidget {
  final String role;
  final String telephone;

  const OtpVerificationScreen({
    super.key,
    required this.role,
    required this.telephone,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // Aligné sur le backend : OtpService.genererCode() produit un code à 6
  // chiffres (fiche sécurité 07). Un champ à 4 cases empêchait de saisir le
  // code complet → verify échouait toujours.
  static const int _otpLength = 6;

  String _code = '';
  int _resendCount = 0;
  int _remainingSeconds = OtpResendPolicy.delayFor(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _remainingSeconds = OtpResendPolicy.delayFor(_resendCount));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _submit() {
    if (_code.length != _otpLength) return;
    context.read<UserBloc>().add(VerifyOtp(widget.telephone, _code));
  }

  void _resendCode() {
    if (_remainingSeconds > 0) return;
    context.read<UserBloc>().add(SendOtp(widget.telephone));
    _resendCount++;
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          showDangerSnackBar(context, state.message);
        }
        if (state is OtpVerified) {
          pushScreenAndReplace(
            context,
            SignupNameScreen(
              role: widget.role,
              telephone: state.telephone,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is UserLoading;
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
                      SignupStepHeader(
                        step: 2,
                        titleLine1: 'Vérifier',
                        titleLine2: 'votre numéro.',
                        subtitle: 'Entrez le code à $_otpLength chiffres '
                            'envoyé au ${widget.telephone}.',
                      ),
                      const SizedBox(height: 36),
                      OtpCodeInput(
                        length: _otpLength,
                        onChanged: (v) => setState(() => _code = v),
                        onCompleted: (_) => _submit(),
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: 'Vérifier',
                        onPressed: (loading || _code.length != _otpLength)
                            ? null
                            : _submit,
                        size: ButtonSize.lg,
                        block: true,
                        loading: loading,
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Pas reçu de code ? ',
                              style: AppTextStyles.small.copyWith(fontSize: 13),
                            ),
                            InkWell(
                              onTap: _remainingSeconds > 0 ? null : _resendCode,
                              child: Text(
                                _remainingSeconds > 0
                                    ? 'Renvoyer dans ${_remainingSeconds}s'
                                    : 'Renvoyer',
                                style: TextStyle(
                                  color: _remainingSeconds > 0
                                      ? AppColors.text3
                                      : AppColors.accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
