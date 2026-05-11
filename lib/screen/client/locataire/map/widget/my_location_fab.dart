import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// FAB rond 56×56 accent or, icon `my_location` (ou spinner si loading).
///
/// Position recommandée par le parent : `Positioned(right: 18, bottom: 100)`.
class MyLocationFab extends StatelessWidget {
  final VoidCallback? onTap;
  final bool loading;

  const MyLocationFab({
    super.key,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 4),
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.onAccent),
                  ),
                )
              : const Icon(
                  Icons.my_location,
                  size: 24,
                  color: AppColors.onAccent,
                ),
        ),
      ),
    );
  }
}
