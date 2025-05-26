import 'package:flutter/material.dart';
import 'package:web_flutter/service/providers/style.dart';

class CircularProgress extends StatelessWidget {
  const CircularProgress({super.key, this.color, this.value});

  final Color? color;
  final double? value;
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color ?? Style.primaryColor,
      value: value,
    );
  }
}
