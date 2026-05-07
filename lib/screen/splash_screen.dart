import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/model/user/demarcheur.dart';
import 'package:asfar/screen/client/locataire/home/home.dart';
import 'package:asfar/screen/client/proprio/proprio_navigation.dart';
import 'package:asfar/screen/client/demarcheur/demarcheur_navigation.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/widget/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Vérifier si un utilisateur est stocké localement
    context.read<UserBloc>().add(CheckStoredUser());
  }

  void _handleUserState(UserState state) {
    if (!mounted) return;

    if (state is UserLoaded) {
      // Utilisateur connecté, rediriger selon le type
      _redirectBasedOnUserType(state.loadedUser);
    } else if (state is UserInitial) {
      // Pas d'utilisateur connecté, aller au login
      pushAndRemoveAll(context, const LoginScreen());
    }
    // UserLoading : on reste sur le splash screen
  }

  void _redirectBasedOnUserType(User user) {
    // Logs pour debug
    deboger("SplashScreen: Redirection utilisateur");
    deboger("User type: ${user.runtimeType}");
    deboger("User is Proprietaire: ${user is Proprietaire}");
    deboger("User is Locataire: ${user is Locataire}");

    // Redirection selon le type d'utilisateur
    if (user is Proprietaire) {
      // Utilisateur propriétaire → Dashboard propriétaire
      deboger("SplashScreen: Redirection vers ProprioNavigation");
      pushAndRemoveAll(context, const ProprioNavigation());
    } else if (user is Demarcheur) {
      // Utilisateur démarcheur → Dashboard démarcheur
      deboger("SplashScreen: Redirection vers DemarcheurNavigation");
      pushAndRemoveAll(context, const DemarcheurNavigation());
    } else if (user is Locataire) {
      // Utilisateur locataire → Dashboard locataire
      deboger("SplashScreen: Redirection vers Home (Locataire)");
      pushAndRemoveAll(context, const Home());
    } else {
      // Type inconnu - redirection par défaut vers dashboard locataire
      deboger("SplashScreen: Type inconnu, redirection par défaut vers Home");
      pushAndRemoveAll(context, const Home());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) => _handleUserState(state),
      builder: (context, state) {
        // Vérifier l'état initial au premier build
        if (state is UserLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _redirectBasedOnUserType(state.loadedUser);
          });
        } else if (state is UserInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            pushAndRemoveAll(context, const LoginScreen());
          });
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de l'application
                Logo(),
                const SizedBox(height: 24),
                // Indicateur de chargement
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
