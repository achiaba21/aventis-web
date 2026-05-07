import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/config/map_config.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Type de sélection de zone
enum ZoneType {
  /// Cercle avec rayon
  circle,

  /// Zone libre dessinée
  freeform,
}

/// Bottom sheet pour la sélection de zone sur la carte
///
/// Permet de :
/// - Choisir le type de zone (cercle ou libre)
/// - Ajuster le rayon (mode cercle)
/// - Lancer la recherche dans la zone
/// - Effacer la zone
class ZoneSelector extends StatefulWidget {
  const ZoneSelector({
    super.key,
    this.initialRadius = MapConfig.defaultZoneRadius,
    this.initialType = ZoneType.circle,
    required this.onSearch,
    required this.onClear,
    this.onTypeChanged,
    this.onRadiusChanged,
  });

  /// Rayon initial (km)
  final double initialRadius;

  /// Type initial
  final ZoneType initialType;

  /// Callback recherche
  final VoidCallback onSearch;

  /// Callback effacer zone
  final VoidCallback onClear;

  /// Callback changement de type
  final ValueChanged<ZoneType>? onTypeChanged;

  /// Callback changement de rayon
  final ValueChanged<double>? onRadiusChanged;

  @override
  State<ZoneSelector> createState() => _ZoneSelectorState();
}

class _ZoneSelectorState extends State<ZoneSelector> {
  late ZoneType _selectedType;
  late double _radius;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _radius = widget.initialRadius;
  }

  void _onTypeChanged(ZoneType? type) {
    if (type == null) return;
    setState(() => _selectedType = type);
    widget.onTypeChanged?.call(type);
  }

  void _onRadiusChanged(double value) {
    setState(() => _radius = value);
    widget.onRadiusChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Titre
          TextSeed(
            'Rechercher dans une zone',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),

          const SizedBox(height: 20),

          // Sélection du type
          Row(
            children: [
              Expanded(
                child: _ZoneTypeOption(
                  type: ZoneType.circle,
                  label: 'Cercle',
                  icon: Icons.radio_button_unchecked,
                  isSelected: _selectedType == ZoneType.circle,
                  onTap: () => _onTypeChanged(ZoneType.circle),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ZoneTypeOption(
                  type: ZoneType.freeform,
                  label: 'Zone libre',
                  icon: Icons.gesture,
                  isSelected: _selectedType == ZoneType.freeform,
                  onTap: () => _onTypeChanged(ZoneType.freeform),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Slider rayon (seulement en mode cercle)
          if (_selectedType == ZoneType.circle) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSeed(
                  'Rayon',
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
                TextSeed(
                  '${_radius.toStringAsFixed(1)} km',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.textSecondary,
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.withValues(alpha: 0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _radius,
                min: MapConfig.minZoneRadius,
                max: MapConfig.maxZoneRadius,
                divisions: 9,
                onChanged: _onRadiusChanged,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextSeed(
                  '${MapConfig.minZoneRadius} km',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                TextSeed(
                  '${MapConfig.maxZoneRadius.toInt()} km',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Bouton recherche
          PlainButton(
            value: 'Rechercher dans la zone',
            onPress: widget.onSearch,
          ),

          const SizedBox(height: 12),

          // Bouton effacer
          Center(
            child: TextButton(
              onPressed: widget.onClear,
              child: TextSeed(
                'Effacer la zone',
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Option de type de zone
class _ZoneTypeOption extends StatelessWidget {
  const _ZoneTypeOption({
    required this.type,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final ZoneType type;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(Espacement.radius),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : icon,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            TextSeed(
              label,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.accent : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
