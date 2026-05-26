import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/role_home_router.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/phone_input_field.dart';

/// Formulaire de connexion : téléphone + mot de passe.
///
/// Dispatch [LoginUser] sur le [UserBloc]. Affiche le statut via [BlocConsumer] :
/// - [UserLoading] → bouton en loading
/// - [UserLoaded] → SnackBar succès
/// - [UserError] → SnackBar erreur
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _fullPhone = '';
  String? _phoneError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 4) return 'Au moins 4 caractères';
    return null;
  }

  bool _isPhoneValid() {
    final digits = _fullPhone.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 11;
  }

  void _submit() {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!_isPhoneValid()) {
      setState(() => _phoneError = 'Numéro de téléphone invalide');
      return;
    }
    setState(() => _phoneError = null);
    if (!formOk) return;
    final user = User(
      telephone: _fullPhone,
      password: _passwordCtrl.text,
    );
    context.read<UserBloc>().add(LoginUser(user));
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Récupération de mot de passe à venir'),
        duration: Duration(seconds: 2),
      ),
    );
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
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhoneInputField(
                controller: _phoneCtrl,
                eyebrow: 'TÉLÉPHONE',
                errorText: _phoneError,
                onChanged: (full) {
                  _fullPhone = full;
                  if (_phoneError != null) {
                    setState(() => _phoneError = null);
                  }
                },
              ),
              const SizedBox(height: 14),
              InputField(
                controller: _passwordCtrl,
                eyebrow: 'MOT DE PASSE',
                hintText: '••••••••',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
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
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: _onForgotPassword,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              CustomButton(
                text: 'Se connecter',
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
