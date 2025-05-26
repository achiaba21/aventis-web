import 'package:flutter/material.dart';

class StartProgress extends StatelessWidget {
  final double fillPercentage; // De 0.0 (vide) à 1.0 (plein)
  final double size;
  const StartProgress({
    super.key,
    required this.fillPercentage,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Icon(
            Icons.star_border, // étoile vide
            size: size,
            color: Colors.grey,
          ),
          ClipRect(
            clipper: _StarClipper(fillPercentage / 5),
            child: Icon(
              Icons.star, // étoile pleine
              size: size,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fillPercentage;

  _StarClipper(this.fillPercentage);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fillPercentage, size.height);
  }

  @override
  bool shouldReclip(covariant _StarClipper oldClipper) {
    return oldClipper.fillPercentage != fillPercentage;
  }
}
