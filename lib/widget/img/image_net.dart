import 'package:flutter/material.dart';

class ImageNet extends StatelessWidget {
  const ImageNet(this.src, {super.key});
  final String src;

  @override
  Widget build(BuildContext context) {
    return Image.network(src);
  }
}
