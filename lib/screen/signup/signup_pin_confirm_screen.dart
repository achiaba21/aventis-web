import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/dto/user_req.dart';
import 'package:asfar/screen/role_home_router.dart';
import 'package:asfar/screen/signup/widget/pin_dots_display.dart';
import 'package:asfar/screen/signup/widget/pin_keypad.dart';
import 'package:asfar/screen/signup/widget/signup_step_header.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/helper/app_snackbar.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';

/// Étape finale du tunnel d'inscription : confirmation du code secret.
///
/// La concordance avec [pin] est vérifiée localement (aucun appel serveur) ;
/// en cas d'écart, la saisie est réinitialisée avec un état d'erreur. À la
/// concordance, le compte est créé via [SignupUser] (email et prénom restent
/// vides — complétés plus tard dans le profil), puis l'utilisateur entre
/// directement dans l'app selon son rôle.
class SignupPinConfirmScreen extends StatefulWidget {
  final String role;
  final String telephone;
  final String nom;
  final String pin;

  const SignupPinConfirmScreen({
    super.key,
    required this.role,
    required this.telephone,
    required this.nom,
    required this.pin,
  });

  @override
  State<SignupPinConfirmScreen> createState() => _SignupPinConfirmScreenState();
}

class _SignupPinConfirmScreenState extends State<SignupPinConfirmScreen> {
  String _confirm = '';
  bool _hasError = false;

  void _onDigit(String digit) {
    if (_confirm.length >= widget.pin.length) return;
    setState(() {
      _hasError = false;
      _confirm += digit;
    });
    if (_confirm.length == widget.pin.length) _validate();
  }

  void _onBackspace() {
    if (_confirm.isEmpty) return;
    setState(() {
      _hasError = false;
      _confirm = _confirm.substring(0, _confirm.length - 1);
    });
  }

  void _validate() {
    if (_confirm != widget.pin) {
      setState(() {
        _hasError = true;
        _confirm = '';
      });
      return;
    }
    final req = UserReq()
      ..nom = widget.nom
      ..telephone = widget.telephone
      ..password = widget.pin
      ..confirmPassword = widget.pin
      ..type = widget.role;
    context.read<UserBloc>().add(SignupUser(req));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserError) {
          showDangerSnackBar(context, state.message);
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
                      const SignupStepHeader(
                        step: 4,
                        titleLine1: 'Confirmer',
                        titleLine2: 'votre code.',
                        subtitle: 'Saisissez à nouveau votre code à 5 chiffres.',
                      ),
                      const SizedBox(height: 32),
                      PinDotsDisplay(
                        filledCount: _confirm.length,
                        hasError: _hasError,
                      ),
                      if (_hasError) ...[
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Les codes ne correspondent pas. Réessayez.',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      PinKeypad(
                        onDigit: loading ? (_) {} : _onDigit,
                        onBackspace: loading ? () {} : _onBackspace,
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        text: 'Créer mon compte',
                        onPressed:
                            (loading || _confirm.length != widget.pin.length)
                                ? null
                                : _validate,
                        size: ButtonSize.lg,
                        block: true,
                        loading: loading,
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
