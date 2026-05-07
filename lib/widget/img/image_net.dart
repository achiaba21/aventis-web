import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/widget/img/image_app.dart';

class ImageNet extends StatelessWidget {
  const ImageNet(
    this.src, {
    super.key,
    this.height,
    this.size,
    this.width,
    this.radius = 0,
  });
  final String? src;
  final double? size;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final w = size ?? width;
    final h = size ?? height;

    // Vérification rigoureuse de la source
    if (src == null || src!.isEmpty || src == 'null') {
      return ImageApp(null, width: w, height: h, radius: radius);
    }
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: Image.network(
        "$domain/$src",
        width: w,
        height: h,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          deboger([error, stackTrace]);
          return ImageApp(src, width: w, height: h, radius: radius);
        },
      ),
    );
  }
}
