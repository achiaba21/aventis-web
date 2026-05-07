import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Sélecteur d'appartement pour la vue comptabilité par appartement
class AppartementSelector extends StatelessWidget {
  final List<Appartement> appartements;
  final int? selectedAppartementId;
  final Function(int? appartementId) onSelected;
  final bool enabled;

  const AppartementSelector({
    super.key,
    required this.appartements,
    this.selectedAppartementId,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (appartements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: TextSeed(
                "Sélectionnez d'abord une résidence pour voir ses appartements.",
                fontSize: 13,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      );
    }

    final selectedAppartement = selectedAppartementId != null
        ? appartements.firstWhere(
            (a) => a.id == selectedAppartementId,
            orElse: () => Appartement(),
          )
        : null;

    return GestureDetector(
      onTap: enabled ? () => _showAppartementPicker(context) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.door_front_door_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeed(
                      "Appartement",
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                    TextSeed(
                      selectedAppartement?.titre ??
                      selectedAppartement?.numero ??
                      "Tous les appartements",
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: enabled ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppartementPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSeed(
              "Sélectionner un appartement",
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 20),

            // Option "Tous les appartements"
            _AppartementOption(
              appartement: null,
              isSelected: selectedAppartementId == null,
              onTap: () {
                Navigator.pop(ctx);
                onSelected(null);
              },
            ),

            Divider(height: 24, color: AppColors.divider),

            // Liste des appartements avec scroll
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: appartements.map((appartement) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AppartementOption(
                      appartement: appartement,
                      isSelected: selectedAppartementId == appartement.id,
                      onTap: () {
                        Navigator.pop(ctx);
                        onSelected(appartement.id);
                      },
                    ),
                  )).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _AppartementOption extends StatelessWidget {
  final Appartement? appartement;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppartementOption({
    required this.appartement,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = appartement == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAll ? Icons.dashboard : Icons.door_front_door_outlined,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSeed(
                    isAll
                        ? "Tous les appartements"
                        : (appartement?.titre ?? appartement?.numero ?? "Appartement ${appartement?.id}"),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                  ),
                  if (!isAll && appartement?.prix != null)
                    TextSeed(
                      "${appartement!.prix!.toStringAsFixed(0)} FCFA/nuit",
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }
}
