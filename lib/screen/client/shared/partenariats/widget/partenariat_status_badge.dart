import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/statut_partenariat.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Badge de statut d'une `DemandePartenariat` — labels FR + tons selon
/// `StatutPartenariat`.
class PartenariatStatusBadge extends StatelessWidget {
  final StatutPartenariat statut;

  const PartenariatStatusBadge({super.key, required this.statut});

  static String labelOf(StatutPartenariat s) {
    switch (s) {
      case StatutPartenariat.enAttente:
        return 'En attente';
      case StatutPartenariat.acceptee:
        return 'Acceptée';
      case StatutPartenariat.refusee:
        return 'Refusée';
    }
  }

  static BadgeTone toneOf(StatutPartenariat s) {
    switch (s) {
      case StatutPartenariat.enAttente:
        return BadgeTone.warn;
      case StatutPartenariat.acceptee:
        return BadgeTone.success;
      case StatutPartenariat.refusee:
        return BadgeTone.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BadgeStatus(
      text: labelOf(statut),
      tone: toneOf(statut),
    );
  }
}
