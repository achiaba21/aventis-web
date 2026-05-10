import 'package:flutter/material.dart';

/// Indicateurs de photo (dots) — overlay sur galeries (listing cards, detail).
///
/// Dot actif blanc (avec option [animated] pour étirement à 24px), inactifs
/// blanc 0.4. Aligné centre par défaut.
class PhotoDots extends StatelessWidget {
  final int active;
  final int count;
  final bool animated;

  const PhotoDots({
    super.key,
    required this.active,
    required this.count,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: animated && i == active ? 24 : (animated ? 6 : 5),
              height: animated ? 6 : 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: i == active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
            if (i < count - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}
