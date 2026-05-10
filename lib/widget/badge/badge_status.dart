import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Badge de statut du design system Asfar Premium.
///
/// Pill texte 10px uppercase. 6 tons via [BadgeTone] : succès, warning, info,
/// danger, accent, neutre. Pattern : fond couleur×0.14 + texte saturé.
class BadgeStatus extends StatelessWidget {
  final String text;
  final BadgeTone tone;
  final IconData? leadingIcon;

  const BadgeStatus({
    super.key,
    required this.text,
    this.tone = BadgeTone.neutral,
    this.leadingIcon,
  });

  Color get _bg {
    switch (tone) {
      case BadgeTone.success:
        return AppColors.successLight;
      case BadgeTone.warn:
        return AppColors.warningLight;
      case BadgeTone.info:
        return AppColors.infoLight;
      case BadgeTone.danger:
        return AppColors.errorLight;
      case BadgeTone.accent:
        return AppColors.accentSoft;
      case BadgeTone.neutral:
        return AppColors.lineStrong;
    }
  }

  Color get _fg {
    switch (tone) {
      case BadgeTone.success:
        return AppColors.success;
      case BadgeTone.warn:
        return AppColors.warn;
      case BadgeTone.info:
        return AppColors.info;
      case BadgeTone.danger:
        return AppColors.danger;
      case BadgeTone.accent:
        return AppColors.accent;
      case BadgeTone.neutral:
        return AppColors.text2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (leadingIcon != null) {
      children.add(Icon(leadingIcon, size: 11, color: _fg));
      children.add(const SizedBox(width: 4));
    }
    children.add(Text(
      text.toUpperCase(),
      style: TextStyle(
        color: _fg,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
