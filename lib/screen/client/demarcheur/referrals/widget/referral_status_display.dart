import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_display.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Mapping `ReferralStatus` → libellé court + ton de [BadgeStatus] à afficher.
///
/// Source : proto `demarcheur.jsx::DemarcheurDashboard` (badges statut sur les
/// `ReferralRow`).
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
