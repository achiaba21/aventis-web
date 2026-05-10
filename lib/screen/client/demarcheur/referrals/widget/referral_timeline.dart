import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/timeline_step.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Timeline verticale de 5 étapes pour un suivi de référence.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurReferralDetail` :
/// 1. Demande envoyée
/// 2. Vue par le propriétaire
/// 3. Acceptée par le propriétaire (étape courante par défaut)
/// 4. Paiement client
/// 5. Commission versée
///
/// L'index de l'étape courante (`currentIndex`) détermine l'état de chaque
/// étape : avant = `done`, courante = `current`, après = `upcoming`.
class ReferralTimeline extends StatelessWidget {
  final List<TimelineEntry> steps;
  final int currentIndex;

  const ReferralTimeline({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  TimelineStepState _stateFor(int i) {
    if (i < currentIndex) return TimelineStepState.done;
    if (i == currentIndex) return TimelineStepState.current;
    return TimelineStepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++)
            TimelineStep(
              title: steps[i].title,
              subtitle: steps[i].subtitle,
              state: _stateFor(i),
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

/// Une entrée de la [ReferralTimeline] — données brutes (titre + sous-titre).
/// L'état est calculé par la timeline depuis l'index.
class TimelineEntry {
  final String title;
  final String subtitle;

  const TimelineEntry({required this.title, required this.subtitle});
}
