import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/dto/user_req.dart';
import 'package:asfar/model/phone/phone_number.dart';
import 'package:asfar/screen/signup/otp_verification_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/input_pass.dart';
import 'package:asfar/widget/input/phone_input_field.dart';
import 'package:asfar/widget/logo.dart';
import 'package:asfar/widget/text/text_seed.dart';

class SignupScreen extends StatefulWidget {
  final String role;

  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  PhoneNumber? _phone;
  bool _hasNavigatedToOtp = false;

  @override
  void dispose() {
    _nomController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final nom = _nomController.text.trim();
    final password = _passwordController.text.trim();

    if (nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez saisir votre nom complet")),
      );
      return;
    }

    if (_phone == null || !_phone!.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Numéro de téléphone invalide")),
      );
      return;
    }

    if (password.isEmpty || !RegExp(r'^\d{5}$').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le mot de passe doit contenir exactement 5 chiffres")),
      );
      return;
    }

    final confirmPassword = _confirmPasswordController.text.trim();
    if (confirmPassword != password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    context.read<UserBloc>().add(SendOtp(_phone!.internationalFormat));
  }

  void _navigateToOtp(String telephone) {
    if (_hasNavigatedToOtp) return;

    final userReq = UserReq()
      ..nom = _nomController.text.trim()
      ..telephone = telephone
      ..password = _passwordController.text.trim()
      ..confirmPassword = _confirmPasswordController.text.trim()
      ..type = widget.role;

    _hasNavigatedToOtp = true;

    pushScreen(context, OtpVerificationScreen(userReq: userReq)).then((_) {
      _hasNavigatedToOtp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildForm();
          },
          listener: (context, state) {
            if (state is OtpSent) {
              _navigateToOtp(state.telephone);
            }
            if (state is UserError && !_hasNavigatedToOtp) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
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
              IconButton(
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => back(context),
              ),
              const Logo(),
              Gap(Espacement.gapSection),
              Row(
                children: [
                  TextSeed(
                    "Créer un compte",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  Gap(Espacement.gapItem),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent, width: 1),
                    ),
                    child: TextSeed(
                      widget.role,
                      fontSize: 12,
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Gap(Espacement.paddingBloc),
              InputField(
                libelle: "Nom complet",
                controller: _nomController,
                leftIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
              ),
              Gap(Espacement.gapSection),
              PhoneInputField(
                libelle: "Téléphone",
                onPhoneChanged: (phone) => _phone = phone,
              ),
              Gap(Espacement.gapSection),
              InputPass(
                controller: _passwordController,
                libelle: "Mot de passe (5 chiffres)",
                keyboardType: TextInputType.number,
              ),
              Gap(Espacement.gapSection),
              InputPass(
                controller: _confirmPasswordController,
                libelle: "Confirmer le mot de passe",
                keyboardType: TextInputType.number,
              ),
              Gap(Espacement.paddingBloc),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Continuer",
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
