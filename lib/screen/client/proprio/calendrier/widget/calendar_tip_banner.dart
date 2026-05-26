import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/tip_suggestion_engine.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Bandeau « Conseil » jaune avec icône éclair et message chiffré.
///
/// Affiché si `TipSuggestionEngine.computeForCurrentWeek` retourne une
/// suggestion non null. Le screen parent décide de l'affichage (visibility
/// conditionnelle).
class CalendarTipBanner extends StatelessWidget {
  final TipSuggestion suggestion;

  const CalendarTipBanner({super.key, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final n = suggestion.joursOuvrables;
    final gain = FcfaFormatter.compact(suggestion.gainPotentielFcfa);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.warn.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt_outlined, size: 18, color: AppColors.warn),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.text,
                ),
                children: [
                  TextSpan(
                    text: 'Conseil : ',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warn,
                    ),
                  ),
                  const TextSpan(
                      text:
                          "en augmentant l'ouverture de "),
                  TextSpan(
                    text: '$n jours',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                      text:
                          ' cette semaine, vous pourriez gagner jusqu\'à '),
                  TextSpan(
                    text: gain,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' supplémentaires.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
