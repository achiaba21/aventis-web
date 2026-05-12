import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bottom sheet de sélection d'un appartement parmi ceux du proprio.
///
/// Retourne via `Navigator.pop` :
/// - `null` si annulation (drag-down)
/// - `-1` si choix "Tous les appartements"
/// - l'`appartId` choisi sinon
class ChargeAppartementPicker {
  ChargeAppartementPicker._();

  static Future<int?> show(
    BuildContext context, {
    required List<Appartement> appartements,
    required int? selectedId,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => _ChargeAppartementPickerBody(
        appartements: appartements,
        selectedId: selectedId,
      ),
    );
  }
}

class _ChargeAppartementPickerBody extends StatelessWidget {
  final List<Appartement> appartements;
  final int? selectedId;

  const _ChargeAppartementPickerBody({
    required this.appartements,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mq.size.height * 0.75,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDim,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('APPARTEMENT', style: AppTextStyles.eyebrow),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ChargePickerTile(
                      label: 'Tous les appartements',
                      selected: selectedId == null,
                      onTap: () => Navigator.of(context).pop(-1),
                    ),
                    ...appartements.map((a) => _ChargePickerTile(
                          label: a.titleSafe,
                          sub: a.areaName,
                          selected: selectedId == a.id,
                          onTap: () => Navigator.of(context).pop(a.id),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ChargePickerTile extends StatelessWidget {
  final String label;
  final String? sub;
  final bool selected;
  final VoidCallback onTap;

  const _ChargePickerTile({
    required this.label,
    this.sub,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.line, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.text,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (sub != null && sub!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sub!,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 12,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
