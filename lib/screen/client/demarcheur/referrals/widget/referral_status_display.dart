import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Mapping `ReferralStatus` → libellé court + ton de [BadgeStatus] à afficher.
///
/// Source : proto `demarcheur.jsx::DemarcheurDashboard` (badges statut sur les
/// `ReferralRow`). Helper dédié pour respecter la règle « pas de logique
/// dispersée dans les widgets ».
class ReferralStatusDisplay {
  ReferralStatusDisplay._();

  static String labelOf(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.pending:
        return 'En attente';
      case ReferralStatus.accepted:
        return 'Acceptée';
      case ReferralStatus.completed:
        return 'Terminée';
      case ReferralStatus.refused:
        return 'Refusée';
    }
  }

  static BadgeTone toneOf(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.pending:
        return BadgeTone.warn;
      case ReferralStatus.accepted:
        return BadgeTone.success;
      case ReferralStatus.completed:
        return BadgeTone.neutral;
      case ReferralStatus.refused:
        return BadgeTone.danger;
    }
  }
}
