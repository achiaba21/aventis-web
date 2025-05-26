import 'package:flutter/material.dart';
import 'package:web_flutter/service/providers/style.dart';

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
    barrierColor: Style.primaryColor,
    firstDate: firstDate ?? now,
    lastDate: lastDate ?? DateTime(now.year + 2, 12, 31),
    builder: (context, child) {
      return DatePickerTheme(
        data: DatePickerThemeData(
          dayForegroundColor: WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Style.primaireColor;
            }
            return Style.primaireColor;
          }),
          dayBackgroundColor: WidgetStatePropertyAll(
            Style.containerColor2.withAlpha(200),
          ),
          dayOverlayColor: WidgetStatePropertyAll(Style.primaryColor),
          rangePickerBackgroundColor: Style.containerColor3,
          rangeSelectionBackgroundColor: Style.containerColor2.withAlpha(75),
          rangeSelectionOverlayColor: WidgetStatePropertyAll(
            Style.containerColor3,
          ),
        ),
        child: Theme(data: ThemeData.dark().copyWith(), child: child!),
      );
    },
  );
}
