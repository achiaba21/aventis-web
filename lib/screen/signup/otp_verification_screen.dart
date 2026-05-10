import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/dto/user_req.dart';
import 'package:asfar/screen/role_home_router.dart';
import 'package:asfar/screen/signup/widget/otp_code_input.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';

/// Écran de vérification OTP.
///
/// L'utilisateur saisit le code SMS reçu sur [telephone]. À la complétion,
/// le code est combiné avec le [userReq] préparé au signup et envoyé via
/// [VerifyAndSignup] au [UserBloc].
///
/// Cooldown de 60s avant de pouvoir renvoyer un nouveau code.
class OtpVerificationScreen extends StatefulWidget {
  final UserReq userReq;
  final String telephone;

  const OtpVerificationScreen({
    super.key,
    required this.userReq,
    required this.telephone,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const int _cooldownSeconds = 60;
  String _code = '';
  int _remainingSeconds = _cooldownSeconds;
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
    setState(() => _remainingSeconds = _cooldownSeconds);
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
    if (_code.length != 6) return;
    context.read<UserBloc>().add(VerifyAndSignup(_code, widget.userReq));
  }

  void _resendCode() {
    if (_remainingSeconds > 0) return;
    context.read<UserBloc>().add(SendOtp(widget.telephone));
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        if (state is UserLoaded) {
          pushAndRemoveAll(
            context,
            RoleHomeRouter.shellFor(state.loadedUser),
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
                      Text.rich(
                        TextSpan(
                          style: AppTextStyles.display,
                          children: const [
                            TextSpan(text: 'Vérifier\n'),
                            TextSpan(
                              text: 'votre numéro.',
                              style: TextStyle(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Entrez le code à 6 chiffres envoyé au ${widget.telephone}.',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 36),
                      OtpCodeInput(
                        onChanged: (v) => setState(() => _code = v),
                        onCompleted: (_) => _submit(),
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        text: 'Vérifier',
                        onPressed: (loading || _code.length != 6)
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
