import 'package:flutter/material.dart';

/// Halos radiaux or des écrans d'authentification (Onboarding, Login,
/// Signup, OTP).
///
/// Reproduit le double radial-gradient du proto :
/// - top-left : ellipse 400×300 px @ 20%/0% — accent or 0.18
/// - bottom-right : ellipse 400×400 px @ 90%/60% — accent or 0.10
///
/// À utiliser dans un `Stack` derrière le contenu, en `Positioned.fill`.
/// `IgnorePointer` est appliqué automatiquement pour ne pas bloquer les taps.
class AuthRadialBackground extends StatelessWidget {
  const AuthRadialBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.6, -1.0),
                  radius: 0.9,
                  colors: [
                    Color(0x2EE8B86B),
                    Color(0x00E8B86B),
                  ],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, 0.2),
                  radius: 0.9,
                  colors: [
                    Color(0x1AE8B86B),
                    Color(0x00E8B86B),
                  ],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
