import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Pin de prix posé sur les tuiles d'une vraie carte FlutterMap.
///
/// Style « pill + pointe » (à la Airbnb) : pastille accent or compacte avec
/// le prix, prolongée d'un petit triangle vers le bas qui ancre le marker sur
/// le point géographique exact. Texte onAccent mono, ombre douce pour
/// ressortir sur les tuiles dark.
class MapPricePin extends StatelessWidget {
  final int price;
  final VoidCallback? onTap;

  const MapPricePin({
    super.key,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: AppColors.onAccent, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ],
              ),
              child: Text(
                FcfaFormatter.compact(price),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onAccent,
                )),
              ),
            ),
            // Pointe triangulaire qui ancre la pill sur le point exact.
            Transform.translate(
              offset: const Offset(0, -2),
              child: const _PinTail(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petit triangle accent or pointant vers le bas, sous la pill de prix.
class _PinTail extends StatelessWidget {
  const _PinTail();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 7),
      painter: _TailPainter(),
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
