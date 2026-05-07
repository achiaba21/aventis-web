import 'package:flutter/material.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/theme/app_colors.dart';

/// Cas d'un jour dans le calendrier démarcheur
enum DayCas {
  /// Aucune plage ou toutes DISPONIBLE → clicable, formulaire direct
  a,

  /// Contient une plage OCCUPE → bloqué
  b,

  /// EN_ATTENTE d'autres démarcheurs uniquement → clicable, bottom sheet
  c,

  /// EN_ATTENTE dont une appartient au démarcheur courant → lecture seule
  d,
}

/// Analyse les plages d'un jour pour déterminer le cas d'affichage.
///
/// Règles métier :
/// - Cas A : plages vides ou toutes DISPONIBLE
/// - Cas B : au moins une plage OCCUPE
/// - Cas D : EN_ATTENTE dont une m'appartient (comparaison téléphone normalisé)
/// - Cas C : EN_ATTENTE d'autres uniquement
class DayAnalysis {
  final List<CalendarPlage> plages;
  final String userTelephone;

  const DayAnalysis({
    required this.plages,
    required this.userTelephone,
  });

  String _normalize(String? tel) =>
      (tel ?? '').replaceAll(RegExp(r'\s+'), '');

  bool _isMine(CalendarPlage p) =>
      _normalize(p.demarcheurTelephone) == _normalize(userTelephone) &&
      _normalize(userTelephone).isNotEmpty;

  List<CalendarPlage> get enAttentePlages => plages
      .where((p) => p.statut == PlageStatut.enAttente)
      .toList();

  DayCas get cas {
    if (plages.isEmpty) return DayCas.a;

    final hasOccupe = plages.any((p) => p.statut == PlageStatut.occupe);
    if (hasOccupe) return DayCas.b;

    final hasEnAttente = enAttentePlages.isNotEmpty;
    if (!hasEnAttente) return DayCas.a;

    final hasMyRequest = enAttentePlages.any(_isMine);
    return hasMyRequest ? DayCas.d : DayCas.c;
  }

  /// Vrai si le jour peut ouvrir une action (formulaire ou bottom sheet).
  /// Faux uniquement pour Cas B (OCCUPE) — jamais tappable.
  bool get isTappable => cas != DayCas.b;

  /// Vrai si le démarcheur peut créer une réservation sur ce jour (Cas A et C).
  bool get isBookable => cas == DayCas.a || cas == DayCas.c;

  int get badgeCount => enAttentePlages.length;

  bool get hasBadge => badgeCount > 0;

  Color get bgColor {
    switch (cas) {
      case DayCas.a:
        return AppColors.success.withValues(alpha: 0.25);
      case DayCas.b:
        return AppColors.error;
      case DayCas.c:
        return AppColors.warning;
      case DayCas.d:
        return AppColors.warning;
    }
  }

  Color get headerColor {
    switch (cas) {
      case DayCas.c:
        return AppColors.warning;
      case DayCas.d:
        return AppColors.warning;
      default:
        return AppColors.warning;
    }
  }
}
