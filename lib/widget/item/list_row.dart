import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Ligne de liste du design system Asfar Premium.
///
/// Reproduit `.listrow` du prototype : padding 14×16, gap 12, divider bottom
/// optionnel. Slots [leading] (icon ou avatar), [title]+[subtitle] au centre,
/// [trailing] (badge, chevron, valeur, bouton).
class ListRow extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool divider;
  final EdgeInsets padding;

  const ListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.divider = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (leading != null) {
      children.add(leading!);
      children.add(const SizedBox(width: 12));
    }
    children.add(Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          title,
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.text3,
              ),
              child: subtitle!,
            ),
          ],
        ],
      ),
    ));
    if (trailing != null) {
      children.add(const SizedBox(width: 12));
      children.add(trailing!);
    }

    final row = Container(
      padding: padding,
      decoration: divider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.line, width: 1),
              ),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: row,
      ),
    );
  }
}
