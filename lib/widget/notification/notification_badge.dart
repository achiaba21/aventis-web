import 'package:flutter/material.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Badge de compteur pour afficher le nombre de notifications non lues
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.size = 18,
    this.fontSize = 11,
  });

  final int count;
  final int maxCount;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Ne rien afficher si count est 0 ou négatif
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final displayText = count > maxCount ? '$maxCount+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: AppColors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: TextSeed(
          displayText,
          color: AppColors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Badge positionné en position absolue (pour overlay sur icône)
class PositionedNotificationBadge extends StatelessWidget {
  const PositionedNotificationBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.right = 0,
    this.top = 0,
  });

  final int count;
  final int maxCount;
  final double right;
  final double top;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: right,
      top: top,
      child: NotificationBadge(
        count: count,
        maxCount: maxCount,
      ),
    );
  }
}
