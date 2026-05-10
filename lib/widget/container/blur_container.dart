import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Conteneur "Liquid Glass" iOS du design system Asfar Premium.
///
/// Reproduit `backdrop-filter: blur(20px) saturate(180%)` du prototype.
/// Utilisé pour la `TabBar` bottom et les `BottomBar` sticky des écrans
/// Detail / Reserve / Search.
///
/// Sur Android (où le blur est coûteux ou non supporté), bascule sur un
/// fond opaque `bgElev1` via [_supportsBlur].
class BlurContainer extends StatelessWidget {
  final Widget child;
  final double sigma;
  final Color tint;

  const BlurContainer({
    super.key,
    required this.child,
    this.sigma = 20,
    this.tint = const Color(0xD90A0A0B),
  });

  bool get _supportsBlur {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsBlur) {
      return ColoredBox(
        color: AppColors.bgElev1,
        child: child,
      );
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: ColoredBox(
          color: tint,
          child: child,
        ),
      ),
    );
  }
}
