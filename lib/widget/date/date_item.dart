import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/util/dialog/date_picker.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/dialog/occupation_calendar_picker_dialog.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class DateItem extends StatefulWidget {
  const DateItem({
    super.key,
    this.selectedRange,
    this.onSelectRange,
    this.showNightsCount = true,
    this.showClearButton = true,
    this.readOnly = false,
    this.appartementId, // Si fourni, utilise le calendrier d'occupation
  });

  final Function(DateTimeRange?)? onSelectRange;
  final DateTimeRange? selectedRange;
  final bool showNightsCount;
  final bool showClearButton;
  final bool readOnly;
  final int? appartementId; // Optionnel : active le calendrier d'occupation

  @override
  State<DateItem> createState() => _DateItemState();
}

class _DateItemState extends State<DateItem> {
  DateTimeRange? plage;

  bool get hasSelection => plage != null;
  int get nights => plage?.duration.inDays ?? 0;

  @override
  Widget build(BuildContext context) {
    plage = widget.selectedRange ?? plage;

    return GestureDetector(
      onTap: widget.readOnly ? null : _selectDates,
      child: Container(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: hasSelection ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(Espacement.radius),
          border: Border.all(
            color: hasSelection ? Colors.transparent : AppColors.textMuted,
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: hasSelection ? _buildFilledState() : _buildEmptyState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.calendar_month_outlined,
            color: AppColors.accent,
            size: 20,
          ),
        ),
        Gap(Espacement.gapSection),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                "Quand partez-vous ?",
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              Gap(2),
              TextSeed(
                "Appuyez pour sélectionner vos dates",
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilledState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            Gap(Espacement.gapSection),
            Expanded(
              child: Row(
                children: [
                  // Arrivée
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextSeed(
                          "Arrivée",
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        Gap(2),
                        TextSeed(
                          formatDateMonth(plage?.start),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  // Séparateur
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Départ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextSeed(
                          "Départ",
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        Gap(2),
                        TextSeed(
                          formatDateMonth(plage?.end),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bouton clear (masqué en mode lecture seule)
            if (widget.showClearButton && !widget.readOnly)
              GestureDetector(
                onTap: _clearSelection,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
          ],
        ),
        // Badge nuits
        if (widget.showNightsCount && nights > 0) ...[
          Gap(Espacement.gapItem),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 14,
                  color: AppColors.accent,
                ),
                Gap(4),
                TextSeed(
                  "$nights nuit${nights > 1 ? 's' : ''}",
                  fontSize: 12,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDates() async {
    if (widget.onSelectRange != null) {
      final DateTimeRange? result;

      // Si appartementId fourni, utiliser le calendrier d'occupation
      if (widget.appartementId != null) {
        result = await OccupationCalendarPickerDialog.show(
          context: context,
          appartementId: widget.appartementId!,
        );
      } else {
        // Sinon, utiliser le date picker classique
        result = await dateRangePicker(context);
      }

      if (result != null) {
        plage = result;
        widget.onSelectRange!(plage);
        setState(() {});
      }
    }
  }

  void _clearSelection() {
    setState(() {
      plage = null;
    });
    widget.onSelectRange?.call(null);
  }
}
