import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_statut.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Mapping `Charge` → `ChargeStatut` + libellé FR + `BadgeTone` + icône Material.
///
/// Helper transverse utilisé par toutes les surfaces qui affichent un statut
/// de charge : `ChargeRow`, `ChargeDetailHeader`, `ChargesAlertCard`, filtres.
class ChargeStatusDisplay {
  ChargeStatusDisplay._();

  /// Calcule le statut visuel à partir des champs métier de la charge.
  static ChargeStatut statutOf(Charge c) {
    if (c.estPaye == true) return ChargeStatut.payee;
    if (c.estEnRetard) return ChargeStatut.enRetard;
    if (c.echeanceProche) return ChargeStatut.echeanceProche;
    return ChargeStatut.impayee;
  }

  static String labelOf(ChargeStatut s) {
    switch (s) {
      case ChargeStatut.payee:
        return 'Payée';
      case ChargeStatut.enRetard:
        return 'En retard';
      case ChargeStatut.echeanceProche:
        return 'Bientôt due';
      case ChargeStatut.impayee:
        return 'Impayée';
    }
  }

  static BadgeTone toneOf(ChargeStatut s) {
    switch (s) {
      case ChargeStatut.payee:
        return BadgeTone.success;
      case ChargeStatut.enRetard:
        return BadgeTone.danger;
      case ChargeStatut.echeanceProche:
        return BadgeTone.warn;
      case ChargeStatut.impayee:
        return BadgeTone.neutral;
    }
  }

  static IconData iconOf(ChargeStatut s) {
    switch (s) {
      case ChargeStatut.payee:
        return Icons.check_circle_outline;
      case ChargeStatut.enRetard:
        return Icons.warning_amber_rounded;
      case ChargeStatut.echeanceProche:
        return Icons.schedule;
      case ChargeStatut.impayee:
        return Icons.pending_outlined;
    }
  }
}
