import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bottom sheet de sélection d'un `TypeCharge` parmi les 13 types prédéfinis.
///
/// Mode "filtre" : option `Tous les types` retournée comme `null`.
/// Mode "création" : option `Tous les types` masquée (`includeAll: false`).
class ChargeTypePicker {
  ChargeTypePicker._();

  static Future<TypeCharge?> show(
    BuildContext context, {
    required TypeCharge? selected,
    bool includeAll = true,
  }) {
    return showModalBottomSheet<TypeCharge?>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => _ChargeTypePickerBody(
        selected: selected,
        includeAll: includeAll,
      ),
    );
  }
}

class _ChargeTypePickerBody extends StatelessWidget {
  final TypeCharge? selected;
  final bool includeAll;

  const _ChargeTypePickerBody({
    required this.selected,
    required this.includeAll,
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
                child: Text('TYPE DE CHARGE', style: AppTextStyles.eyebrow),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (includeAll)
                      _TypeTile(
                        label: 'Tous les types',
                        emoji: null,
                        selected: selected == null,
                        onTap: () => Navigator.of(context).pop(null),
                      ),
                    ...TypeCharge.values.map((t) => _TypeTile(
                          label: t.label,
                          emoji: t.icon,
                          selected: selected == t,
                          onTap: () => Navigator.of(context).pop(t),
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

class _TypeTile extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.label,
    required this.emoji,
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
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
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
