import 'package:flutter/material.dart';
import 'package:asfar/config/map_config.dart';
import 'package:asfar/theme/app_colors.dart';

/// États du bouton de géolocalisation
enum LocationButtonState {
  /// Inactif - position non connue
  inactive,

  /// Recherche en cours
  searching,

  /// Centré sur la position
  centered,
}

/// Bouton FAB de géolocalisation avec animation
///
/// Affiche différents états visuels :
/// - Inactif : gris
/// - Recherche : pulse bleu
/// - Centré : bleu fixe
class LocationButton extends StatefulWidget {
  const LocationButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  /// État actuel du bouton
  final LocationButtonState state;

  /// Callback au tap
  final VoidCallback onPressed;

  @override
  State<LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: MapConfig.pulseDuration,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(LocationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.state == LocationButtonState.searching) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Couleur de fond (constante blanche pour tous les états)
  Color get _backgroundColor => AppColors.white;

  Color get _iconColor {
    switch (widget.state) {
      case LocationButtonState.inactive:
        return MapConfig.geolocInactiveColor;
      case LocationButtonState.searching:
      case LocationButtonState.centered:
        return MapConfig.geolocActiveColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = widget.state == LocationButtonState.searching
            ? _pulseAnimation.value
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        elevation: 4,
        shape: const CircleBorder(),
        color: _backgroundColor,
        child: InkWell(
          onTap: widget.onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: MapConfig.fabSize,
            height: MapConfig.fabSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: MapConfig.fabShadow,
            ),
            child: Icon(
              Icons.my_location,
              color: _iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
