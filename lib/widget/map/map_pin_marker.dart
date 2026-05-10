import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Pin central du Detail (carte Emplacement).
///
/// Cercle 44×44 accent or + halo concentrique double (rgba 0.18 puis 0.08).
/// Reproduit la marker animée du proto Detail.
class MapPinMarker extends StatelessWidget {
  final IconData icon;
  final double size;

  const MapPinMarker({
    super.key,
    this.icon = Icons.place,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent,
        boxShadow: [
          BoxShadow(
            color: Color(0x2EE8B86B),
            blurRadius: 0,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Color(0x14E8B86B),
            blurRadius: 0,
            spreadRadius: 16,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: size * 0.5,
        color: AppColors.onAccent,
      ),
    );
  }
}
