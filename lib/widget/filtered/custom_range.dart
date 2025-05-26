import 'package:flutter/material.dart';
import 'package:web_flutter/service/providers/style.dart';

class CustomRange extends StatelessWidget {
  const CustomRange({
    super.key,
    required this.range,
    this.onChange,
    required this.max,
    required this.min,
  });
  final RangeValues range;
  final void Function(RangeValues)? onChange;
  final double max;
  final double min;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Style.containerColor2,
        inactiveTrackColor: Style.containerColor2.withAlpha(75),
        trackHeight: 1.0,
        thumbColor: Style.primaryColor,

        overlayColor: Style.primaryColor.withAlpha(75),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
        rangeThumbShape: CustomDualColorThumbShape(),
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
        rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
        valueIndicatorColor: Colors.purple,
        showValueIndicator: ShowValueIndicator.always,
      ),
      child: RangeSlider(
        values: range,
        onChanged: onChange,
        max: max,
        min: min,
        divisions: 500,
      ),
    );
  }
}

class CustomDualColorThumbShape extends RangeSliderThumbShape {
  final double thumbRadius;

  const CustomDualColorThumbShape({this.thumbRadius = 10.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool? isDiscrete,
    bool? isEnabled,
    bool? isOnTop,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;

    // Outer circle (orange)
    final Paint outerPaint =
        Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, outerPaint);

    // Inner circle (white)
    final Paint innerPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius * 0.6, innerPaint);
  }
}
