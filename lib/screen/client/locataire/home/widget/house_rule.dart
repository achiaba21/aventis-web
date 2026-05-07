import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/rule.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/icon_mapper.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Widget affichant les règles de la maison
/// avec des icônes et un design structuré
class HouseRule extends StatelessWidget {
  const HouseRule({super.key, this.rules});

  final List<Rule>? rules;

  /// Règles par défaut si aucune règle n'est fournie
  static final List<Rule> _defaultRules = [
    Rule(
      iconName: 'smoke_free',
      text: "Interdiction de fumer à l'intérieur",
      isAllowed: false,
    ),
    Rule(
      iconName: 'pets',
      text: "Animaux de compagnie acceptés",
      isAllowed: true,
    ),
    Rule(
      iconName: 'celebration_outlined',
      text: "Pas de fêtes ou d'événements",
      isAllowed: false,
    ),
    Rule(
      iconName: 'nightlight_outlined',
      text: "Respecter le calme après 22h",
      isAllowed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displayRules = rules ?? _defaultRules;

    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Icon(
                Icons.rule,
                color: AppColors.accent,
                size: 22,
              ),
              Gap(Espacement.gapItem),
              TextSeed(
                "Règles de la maison",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ],
          ),

          Gap(Espacement.gapSection),

          // Liste des règles
          ...displayRules.map((rule) {
            final icon = IconMapper.getIcon(rule.iconName);
            final isAllowed = rule.isAllowed ?? false;
            final text = rule.text ?? "";

            return Padding(
              padding: EdgeInsets.only(bottom: Espacement.gapItem),
              child: Row(
                children: [
                  // Icône de la règle avec badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                      // Badge check/cross
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isAllowed ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isAllowed ? Icons.check : Icons.close,
                            size: 12,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Gap(Espacement.gapSection),

                  // Texte de la règle
                  Expanded(
                    child: TextSeed(
                      text,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
