import 'package:flutter/material.dart';

import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Indicateur silencieux d'auto-save. Affiche brièvement un ✓ avec fade-in/out
/// quand [isSaving] passe à `true`.
class WizardAutoSaveIndicator extends StatefulWidget {
  const WizardAutoSaveIndicator({
    super.key,
    required this.isSaving,
  });

  final bool isSaving;

  @override
  State<WizardAutoSaveIndicator> createState() => _WizardAutoSaveIndicatorState();
}

class _WizardAutoSaveIndicatorState extends State<WizardAutoSaveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    if (widget.isSaving) {
      _runFlash();
    }
  }

  @override
  void didUpdateWidget(covariant WizardAutoSaveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSaving && !oldWidget.isSaving) {
      _runFlash();
    }
  }

  Future<void> _runFlash() async {
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      await _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingInput,
          vertical: Espacement.paddingInput / 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 14, color: AppColors.success),
            SizedBox(width: Espacement.gapItem),
            TextSeed(
              "Enregistré",
              fontSize: 11,
              color: AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
