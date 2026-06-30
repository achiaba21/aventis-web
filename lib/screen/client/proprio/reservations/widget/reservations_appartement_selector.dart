import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Sélecteur de bien pour filtrer les réservations : affiche « Tous les
/// biens ▾ » ou le titre du bien actif, et ouvre une bottom-sheet listant les
/// biens distincts.
///
/// [appartements] = biens dérivés des réservations chargées ; [selectedId]
/// `null` = tous. `onSelect(null)` revient à « Tous les biens ».
class ReservationsAppartementSelector extends StatelessWidget {
  final List<Appartement> appartements;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  const ReservationsAppartementSelector({
    super.key,
    required this.appartements,
    required this.selectedId,
    required this.onSelect,
  });

  static const String _tousLabel = 'Tous les biens';

  /// Libellé d'un bien par son [id] (null = « Tous les biens »).
  String _labelFor(int? id) {
    if (id == null) return _tousLabel;
    for (final a in appartements) {
      if (a.id == id) return a.titre ?? a.numero ?? _tousLabel;
    }
    return _tousLabel;
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (sheetContext) {
        final ids = <int?>[null, ...appartements.map((a) => a.id)];
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ids.length,
            itemBuilder: (_, i) {
              final id = ids[i];
              final isSelected = id == selectedId;
              return ListTile(
                title: Text(
                  _labelFor(id),
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? AppColors.accent : AppColors.text,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check,
                        color: AppColors.accent, size: 18)
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onSelect(id);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedId != null;
    final fg = hasSelection ? AppColors.accent : AppColors.text2;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: () => _openSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_work_outlined, size: 14, color: fg),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _labelFor(selectedId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        hasSelection ? FontWeight.w600 : FontWeight.w400,
                    color: fg,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
