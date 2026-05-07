import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

Future<DateTimeRange?> dateRangePicker(
  BuildContext context, {
  DateTime? firstDate,
  DateTime? lastDate,
  DateTimeRange? initialDateRange,
}) async {
  final now = DateTime.now();
  return showDateRangePicker(
    context: context,
    currentDate: now,
    barrierColor: AppColors.accent,
    firstDate: firstDate ?? now,
    lastDate: lastDate ?? DateTime(now.year + 2, 12, 31),
    builder: (context, child) {
      return DatePickerTheme(
        data: DatePickerThemeData(
          dayForegroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.textPrimary;
            }
            return AppColors.textPrimary;
          }),
          dayBackgroundColor: WidgetStatePropertyAll(
            AppColors.background.withAlpha(200),
          ),
          dayOverlayColor: WidgetStatePropertyAll(AppColors.accent),
          rangePickerBackgroundColor: AppColors.background,
          rangeSelectionBackgroundColor: AppColors.background.withAlpha(75),
          rangeSelectionOverlayColor: WidgetStatePropertyAll(
            AppColors.background,
          ),
        ),
        child: Theme(data: ThemeData.dark().copyWith(), child: child!),
      );
    },
  );
}
