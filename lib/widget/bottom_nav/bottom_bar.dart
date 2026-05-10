import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/container/blur_container.dart';

/// Bottom bar sticky du design system Asfar Premium.
///
/// Reproduit `.bottom-bar` du proto : blur Liquid Glass, border-top `line`,
/// padding 14×18×30 (avec safe area bottom). Conteneur générique pour les
/// CTAs sticky des écrans Detail / Reserve / Search.
///
/// Pour le pattern courant "info à gauche + CTA à droite", composer dans
/// [child] avec un `Row` :
/// ```dart
/// BottomBar(child: Row(children: [Expanded(child: info), action]))
/// ```
class BottomBar extends StatelessWidget {
  final Widget child;

  const BottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      tint: const Color(0xEB0A0A0B),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.line, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: child,
          ),
        ),
      ),
    );
  }
}
