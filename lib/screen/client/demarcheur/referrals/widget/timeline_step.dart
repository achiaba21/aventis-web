import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// État d'une étape de la timeline démarcheur (`ReferralTimeline`).
enum TimelineStepState { done, current, upcoming }

/// Une étape verticale d'une timeline.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurReferralDetail` (timeline
/// 5 étapes verticales) : rond 22 px à gauche (success/accent/grey selon
/// l'état) + connector vertical 2 px qui rejoint le rond suivant + titre +
/// sous-titre date.
///
/// Le parent (`ReferralTimeline`) doit positionner les étapes en colonne et
/// passer `isLast: true` à la dernière (= pas de connector).
class TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final TimelineStepState state;
  final bool isLast;

  const TimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.state,
    this.isLast = false,
  });

  Color get _circleColor {
    switch (state) {
      case TimelineStepState.done:
        return AppColors.success;
      case TimelineStepState.current:
        return AppColors.accent;
      case TimelineStepState.upcoming:
        return AppColors.bgElev3;
    }
  }

  Color get _iconColor {
    switch (state) {
      case TimelineStepState.done:
      case TimelineStepState.current:
        return AppColors.onAccent;
      case TimelineStepState.upcoming:
        return AppColors.text3;
    }
  }

  IconData get _icon {
    switch (state) {
      case TimelineStepState.done:
        return Icons.check;
      case TimelineStepState.current:
        return Icons.hourglass_top_outlined;
      case TimelineStepState.upcoming:
        return Icons.circle_outlined;
    }
  }

  Color get _connectorColor {
    return state == TimelineStepState.upcoming
        ? AppColors.bgElev3
        : AppColors.success;
  }

  Color get _titleColor {
    return state == TimelineStepState.upcoming
        ? AppColors.text3
        : AppColors.text;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _circleColor,
                ),
                child: Icon(_icon, size: 12, color: _iconColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: _connectorColor,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: state == TimelineStepState.current
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: _titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.small.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
