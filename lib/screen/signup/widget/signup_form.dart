import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/dto/user_req.dart';
import 'package:asfar/screen/signup/otp_verification_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Formulaire d'inscription.
///
/// Construit un [UserReq] avec le [role] courant, dispatch [SendOtp] sur
/// [UserBloc]. Sur [OtpSent], pousse [OtpVerificationScreen] avec le
/// [UserReq] préparé pour finaliser l'inscription.
class SignupForm extends StatefulWidget {
  final String role;

  const SignupForm({super.key, required this.role});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label requis';
    return null;
  }

  String? _validateTelephone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Téléphone requis';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Au moins 8 chiffres';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email requis';
    if (!v.contains('@')) return 'Email invalide';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Mot de passe requis';
    if (v.length < 6) return 'Au moins 6 caractères';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passwordCtrl.text) return 'Ne correspond pas';
    return null;
  }

  UserReq _buildUserReq() {
    final req = UserReq()
      ..nom = _nomCtrl.text.trim()
      ..prenom = _prenomCtrl.text.trim()
      ..telephone = _telCtrl.text.trim()
      ..email = _emailCtrl.text.trim()
      ..password = _passwordCtrl.text
      ..type = widget.role
      ..confirmPassword = _confirmCtrl.text;
    return req;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<UserBloc>().add(SendOtp(_telCtrl.text.trim()));
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
        if (state is OtpSent) {
          pushScreen(
            context,
            OtpVerificationScreen(
              userReq: _buildUserReq(),
              telephone: state.telephone,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is UserLoading;
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      controller: _nomCtrl,
                      eyebrow: 'NOM',
                      hintText: 'Camara',
                      textInputAction: TextInputAction.next,
                      validator: (v) => _required(v, 'Nom'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputField(
                      controller: _prenomCtrl,
                      eyebrow: 'PRÉNOM',
                      hintText: 'Aïcha',
                      textInputAction: TextInputAction.next,
                      validator: (v) => _required(v, 'Prénom'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InputField(
                controller: _telCtrl,
                eyebrow: 'TÉLÉPHONE',
                hintText: '+225 07 84 21 …',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: _validateTelephone,
                leadingIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 14),
              InputField(
                controller: _emailCtrl,
                eyebrow: 'EMAIL',
                hintText: 'votre@email.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _validateEmail,
                leadingIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 14),
              InputField(
                controller: _passwordCtrl,
                eyebrow: 'MOT DE PASSE',
                hintText: '••••••••',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                leadingIcon: Icons.lock_outline,
                trailing: IconBoutton(
                  icon: _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onPressed: () => setState(
                    () => _obscurePassword = !_obscurePassword,
                  ),
                  size: 32,
                  iconSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              InputField(
                controller: _confirmCtrl,
                eyebrow: 'CONFIRMER LE MOT DE PASSE',
                hintText: '••••••••',
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                validator: _validateConfirm,
                leadingIcon: Icons.lock_outline,
                trailing: IconBoutton(
                  icon: _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  onPressed: () => setState(
                    () => _obscureConfirm = !_obscureConfirm,
                  ),
                  size: 32,
                  iconSize: 16,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Créer mon compte',
                onPressed: loading ? null : _submit,
                size: ButtonSize.lg,
                block: true,
                loading: loading,
              ),
            ],
          ),
        );
      },
    );
  }
}
