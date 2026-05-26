import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Bandeau "X résidences à [zone]" affiché en bas de l'`InteractiveMapPicker`.
///
/// Pill discret avec transition fluide à chaque update (carte qui bouge,
/// search qui change la zone). Si `zoneName` est null (backend pas encore
/// aligné R-BACK2), fallback "dans cette zone".
class MapZoneBanner extends StatelessWidget {
  final int count;
  final String? zoneName;
  final bool isLoading;

  const MapZoneBanner({
    super.key,
    required this.count,
    this.zoneName,
    this.isLoading = false,
  });

  String get _label {
    if (count == 0) {
      return zoneName != null
          ? 'Aucune résidence à $zoneName'
          : 'Aucune résidence dans cette zone';
    }
    final suffix = count > 1 ? 'résidences' : 'résidence';
    return zoneName != null
        ? '$count $suffix à $zoneName'
        : '$count $suffix dans cette zone';
  }

  Color get _textColor => count == 0 ? AppColors.text2 : AppColors.text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElev2,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.line, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.text2),
                  ),
                )
              : Text(
                  _label,
                  key: ValueKey(_label),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
