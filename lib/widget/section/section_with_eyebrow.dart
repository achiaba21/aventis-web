import 'package:flutter/material.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Section labellisée transverse : eyebrow uppercase au-dessus du contenu,
/// gap 10px.
///
/// Utilisée dans toutes les pages détail/édition de l'app (réservation,
/// charge, partenariat…) pour éviter la répétition du pattern
/// `Text(label) + SizedBox(10) + content`.
class SectionWithEyebrow extends StatelessWidget {
  final String label;
  final Widget child;

  const SectionWithEyebrow({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.eyebrow),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}
