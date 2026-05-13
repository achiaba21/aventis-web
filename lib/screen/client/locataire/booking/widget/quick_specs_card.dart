import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card "Quick specs" du Detail logement.
///
/// 3 colonnes (lits / chambres / salles de bain) avec icons accent or et
/// dividers verticaux. Toutes les valeurs proviennent du backend.
class QuickSpecsCard extends StatelessWidget {
  final int beds;
  final int rooms;
  final int baths;

  const QuickSpecsCard({
    super.key,
    required this.beds,
    required this.rooms,
    required this.baths,
  });

  @override
  Widget build(BuildContext context) {
    final cells = <_SpecCellData>[
      _SpecCellData(
        icon: Icons.bed_outlined,
        value: '$beds',
        label: beds > 1 ? 'lits' : 'lit',
      ),
      _SpecCellData(
        icon: Icons.meeting_room_outlined,
        value: '$rooms',
        label: rooms > 1 ? 'chambres' : 'chambre',
      ),
      _SpecCellData(
        icon: Icons.bathtub_outlined,
        value: '$baths',
        label: baths > 1 ? 'salles de bain' : 'salle de bain',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Icon(cells[i].icon, size: 20, color: AppColors.accent),
                  const SizedBox(height: 6),
                  Text(
                    cells[i].value,
                    style: AppTextStyles.mono(const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    )),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cells[i].label,
                    style: AppTextStyles.small.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (i < cells.length - 1)
              Container(
                width: 1,
                height: 44,
                color: AppColors.line,
              ),
          ],
        ],
      ),
    );
  }
}

class _SpecCellData {
  final IconData icon;
  final String value;
  final String label;
  _SpecCellData({required this.icon, required this.value, required this.label});
}
