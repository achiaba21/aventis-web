import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Choix de la source d'une réservation manuelle : client direct (proprio) ou
/// via un apporteur (démarcheur).
///
/// Rendu en **radios** (choix unique exclusif) plutôt qu'en toggle segmenté,
/// pour rester cohérent avec un vrai choix de type. L'API publique est
/// inchangée (`sourceApporteur` + `onSourceChanged`).
class SourceToggle extends StatelessWidget {
  final bool sourceApporteur;
  final ValueChanged<bool> onSourceChanged;

  const SourceToggle({
    super.key,
    required this.sourceApporteur,
    required this.onSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SourceRadioRow(
          label: 'Client direct',
          selected: !sourceApporteur,
          onTap: () => onSourceChanged(false),
        ),
        const SizedBox(height: 10),
        _SourceRadioRow(
          label: 'Via apporteur',
          selected: sourceApporteur,
          onTap: () => onSourceChanged(true),
        ),
      ],
    );
  }
}

/// Ligne radio d'une source : pastille de sélection + label, fond mis en avant
/// quand sélectionnée. Privée au widget [SourceToggle].
class _SourceRadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SourceRadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentSoft : AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _RadioDot(selected: selected),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: selected ? AppColors.accent : AppColors.text,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille radio (cercle vide / cercle plein accent). Privée.
class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.lineStrong,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
            )
          : null,
    );
  }
}
