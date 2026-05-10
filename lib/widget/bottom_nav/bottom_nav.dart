import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_cell.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_item.dart';
import 'package:asfar/widget/container/blur_container.dart';

/// Tab bar bottom du design system Asfar Premium.
///
/// Reproduit `.tabbar` du proto : blur Liquid Glass, border-top `line`,
/// padding 8 top + safe area bottom. Item actif en accent or, inactif en
/// `text3`.
///
/// Configurations standard via `BottomNavTabs.locataire` / `.proprio` /
/// `.demarcheur`.
class BottomNav extends StatelessWidget {
  final List<BottomNavItem> tabs;
  final int current;
  final ValueChanged<int> onChanged;

  const BottomNav({
    super.key,
    required this.tabs,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.line, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: BottomNavCell(
                      item: tabs[i],
                      active: i == current,
                      onTap: () => onChanged(i),
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
