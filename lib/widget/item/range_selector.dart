import 'package:flutter/material.dart';

class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.values,
    required this.onChanged,
    this.divisions,
    this.min = 0,
    this.max = 1,
  });
  final RangeValues values;
  final void Function(RangeValues)? onChanged;
  final int? divisions;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: values,
      onChanged: onChanged,
      divisions: divisions,
      max: max,
      min: min,
    );
  }
}
