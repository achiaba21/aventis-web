import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/active_shell_cubit/active_shell_cubit.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/screen/onboarding/onboarding_screen.dart';
import 'package:asfar/screen/role_home_router.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';

/// Splash de démarrage Asfar Premium.
///
/// Affiche le logo "A" or pendant ~1.5s, dispatch [CheckStoredUser] sur le
/// [UserBloc] et route :
/// - `UserLoaded` → shell du rôle via [RoleHomeRouter]
/// - sinon → [OnboardingScreen]
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _routed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserBloc>().add(CheckStoredUser());
    });
    _timer = Timer(const Duration(milliseconds: 1500), _routeIfReady);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _routeIfReady() {
    if (_routed || !mounted) return;
    _routed = true;
    final state = context.read<UserBloc>().state;
    if (state is UserLoaded) {
      // V8.5 — restaurer la vue active persistée si disponible (un proprio
      // qui avait basculé en mode Locataire reste en mode Locataire après
      // redémarrage). Fallback sur user.type sinon.
      final activeView = context.read<ActiveShellCubit>().state;
      pushAndRemoveAll(
        context,
        RoleHomeRouter.shellFor(state.loadedUser, viewId: activeView),
      );
    } else {
      pushAndRemoveAll(context, const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded && _timer?.isActive == true) {
          _timer?.cancel();
          _routeIfReady();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: AppColors.onAccent,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('asfar', style: AppTextStyles.h1),
            ],
          ),
        ),
      ),
    );
  }
}
