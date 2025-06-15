import 'package:flutter/material.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';

class ImageApp extends StatelessWidget {
  const ImageApp(
    this.name, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.radius = 0,
  });
  final String? name;
  final double? width;
  final double? size;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final errorWidget = CircleIcon(image: Icons.person, size: size ?? 16);
    return name == null
        ? errorWidget
        : Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Image.asset(
            name!,
            width: size ?? width ,
            height: size ?? height,
            alignment: Alignment.topCenter,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget;
            },
          ),
        );
  }
}
