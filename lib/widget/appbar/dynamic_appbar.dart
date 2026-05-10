import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Top nav du design system Asfar Premium.
///
/// Reproduit `TopNav` du prototype : 3 colonnes (left 40 / center title+eyebrow
/// / right 40). [eyebrow] optionnel s'affiche au-dessus du titre (ex. "Étape 3/7").
///
/// Utilisable comme `appBar:` d'un `Scaffold` (implements [PreferredSizeWidget]).
class DynamicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? eyebrow;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;

  const DynamicAppBar({
    super.key,
    required this.title,
    this.eyebrow,
    this.leading,
    this.trailing,
    this.backgroundColor,
  });

  static const double _baseHeight = 48;
  static const double _eyebrowExtra = 16;

  @override
  Size get preferredSize => Size.fromHeight(
        eyebrow != null ? _baseHeight + _eyebrowExtra : _baseHeight,
      );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: leading,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (eyebrow != null) ...[
                        Text(eyebrow!, style: AppTextStyles.eyebrow),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        title,
                        style: AppTextStyles.h3,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
