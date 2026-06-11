import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/signup/otp_verification_screen.dart';
import 'package:asfar/util/helper/app_snackbar.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/input/phone_input_field.dart';

/// Étape 1 du tunnel d'inscription : saisie du numéro de téléphone.
///
/// Dispatch [SendOtp] sur [UserBloc]. Le backend refuse un numéro déjà
/// inscrit dès cet appel — l'erreur s'affiche donc ici, avant tout SMS.
/// Sur [OtpSent], pousse [OtpVerificationScreen] avec le [role] courant.
class SignupPhoneForm extends StatefulWidget {
  final String role;

  const SignupPhoneForm({super.key, required this.role});

  @override
  State<SignupPhoneForm> createState() => _SignupPhoneFormState();
}

class _SignupPhoneFormState extends State<SignupPhoneForm> {
  final _telCtrl = TextEditingController();
  String _fullPhone = '';
  String? _telError;

  @override
  void dispose() {
    _telCtrl.dispose();
    super.dispose();
  }

  bool _isPhoneValid() {
    final digits = _fullPhone.replaceAll(RegExp(r'[^\d]'), '');
    // +225 (3 chiffres) + 10 chiffres national CI = 13 chiffres au total.
    return digits.length >= 11;
  }

  void _submit() {
    if (!_isPhoneValid()) {
      setState(() => _telError = 'Numéro de téléphone invalide');
      return;
    }
    setState(() => _telError = null);
    context.read<UserBloc>().add(SendOtp(_fullPhone));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        // Garde isCurrent : le renvoi d'OTP depuis l'écran suivant émet aussi
        // OtpSent — seule la route au premier plan doit réagir.
        if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
        if (state is UserError) {
          showDangerSnackBar(context, state.message);
        }
        if (state is OtpSent) {
          pushScreen(
            context,
            OtpVerificationScreen(
              role: widget.role,
              telephone: state.telephone,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is UserLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhoneInputField(
              controller: _telCtrl,
              eyebrow: 'TÉLÉPHONE',
              errorText: _telError,
              onChanged: (full) {
                _fullPhone = full;
                if (_telError != null) {
                  setState(() => _telError = null);
                }
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Continuer',
              onPressed: loading ? null : _submit,
              size: ButtonSize.lg,
              block: true,
              loading: loading,
            ),
          ],
        );
      },
    );
  }
}
