import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';

class Block extends StatelessWidget {
  const Block({super.key, this.child, this.color});
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Style.containerColor2,
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: child,
    );
  }
}
