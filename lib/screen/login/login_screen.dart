import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/client/locataire/home/home.dart';
import 'package:asfar/screen/client/proprio/proprio_navigation.dart';
import 'package:asfar/screen/client/demarcheur/demarcheur_navigation.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/model/user/demarcheur.dart';
import 'package:asfar/screen/login/login_form.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/util/function.dart';

class LoginScreen extends StatelessWidget {
  final String? phoneNumber;
  final bool isReconnection;

  const LoginScreen({
    super.key,
    this.phoneNumber,
    this.isReconnection = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: BlocConsumer<UserBloc, UserState>(
          builder: (context, state) {
            return Stack(
              children: [
                LoginForm(
                  phoneNumber: phoneNumber,
                  isReconnection: isReconnection,
                ),
                if (state is UserLoading)
                  Container(
                    color: AppColors.textSecondary,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
          listener: (context, state) {
            if (state is UserLoaded) {
              _redirectBasedOnUserRole(context, state.user);
            }
            if (state is UserError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),
      ),
    );
  }

  void _redirectBasedOnUserRole(BuildContext context, dynamic user) {
    // Si c'est une reconnexion, on retourne simplement à la page précédente
    if (isReconnection) {
      deboger("LoginScreen: Mode reconnexion - retour à la page précédente");
      back(context);
      return;
    }

    // Logs pour debug
    deboger("LoginScreen: Redirection utilisateur");
    deboger("User type: ${user.runtimeType}");
    deboger("User is Proprietaire: ${user is Proprietaire}");
    deboger("User is Locataire: ${user is Locataire}");

    // Redirection selon le type d'utilisateur
    if (user is Proprietaire) {
      deboger("LoginScreen: Redirection vers ProprioNavigation");
      pushAndRemoveAll(context, ProprioNavigation());
    } else if (user is Demarcheur) {
      deboger("LoginScreen: Redirection vers DemarcheurNavigation");
      pushAndRemoveAll(context, DemarcheurNavigation());
    } else if (user is Locataire) {
      deboger("LoginScreen: Redirection vers Home (Locataire)");
      pushAndRemoveAll(context, Home());
    } else {
      deboger("LoginScreen: Type inconnu, redirection par défaut vers Home");
      pushAndRemoveAll(context, Home());
    }
  }
}
