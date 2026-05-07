import 'package:flutter/material.dart';
import 'package:asfar/config/map_config.dart';

/// Marker moderne style Airbnb pour afficher le prix sur la carte
///
/// Trois modes d'affichage :
/// - Normal : Compact avec prix abrégé (25K)
/// - Sélectionné : Étendu avec prix complet + note
/// - Cluster : Cercle avec nombre de résidences
class CustomMapMarker extends StatefulWidget {
  const CustomMapMarker({
    super.key,
    this.price,
    this.rating,
    this.isSelected = false,
    this.isCluster = false,
    this.clusterCount,
    this.onTap,
  });

  /// Prix en FCFA (null si non disponible)
  final int? price;

  /// Note moyenne (affichée si sélectionné)
  final double? rating;

  /// État sélectionné
  final bool isSelected;

  /// Mode cluster
  final bool isCluster;

  /// Nombre d'éléments dans le cluster
  final int? clusterCount;

  /// Callback au tap
  final VoidCallback? onTap;

  @override
  State<CustomMapMarker> createState() => _CustomMapMarkerState();
}

class _CustomMapMarkerState extends State<CustomMapMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: MapConfig.markerTapDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Formate le prix selon le format demandé
  String _formatPrice(int price, {bool withCurrency = false}) {
    String formatted;
    if (price >= 1000000) {
      formatted = '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      formatted = '${(price / 1000).toInt()}K';
    } else {
      formatted = '$price';
    }
    return withCurrency ? '$formatted FCFA' : formatted;
  }

  /// Formate le prix pour affichage compact
  String get _displayPrice {
    if (widget.price == null) return '?';
    return _formatPrice(widget.price!);
  }

  /// Formate le prix complet avec devise
  String get _fullPrice {
    if (widget.price == null) return '?';
    return _formatPrice(widget.price!, withCurrency: true);
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCluster) {
      return _buildClusterMarker();
    }
    return widget.isSelected ? _buildSelectedMarker() : _buildNormalMarker();
  }

  /// Marker normal compact
  Widget _buildNormalMarker() {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bulle avec prix
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: MapConfig.markerColor,
                borderRadius: BorderRadius.circular(MapConfig.markerBorderRadius),
                boxShadow: MapConfig.markerShadow,
              ),
              child: Text(
                _displayPrice,
                style: const TextStyle(
                  color: MapConfig.markerTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Flèche vers le bas
            CustomPaint(
              size: Size(MapConfig.markerArrowSize, MapConfig.markerArrowSize),
              painter: _ArrowPainter(color: MapConfig.markerColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Marker sélectionné étendu
  Widget _buildSelectedMarker() {
    return GestureDetector(
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: MapConfig.markerSelectDuration,
        curve: Curves.elasticOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bulle étendue
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MapConfig.markerSelectedColor,
                borderRadius: BorderRadius.circular(MapConfig.markerBorderRadius),
                boxShadow: MapConfig.markerSelectedShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fullPrice,
                    style: const TextStyle(
                      color: MapConfig.markerTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.rating != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: MapConfig.markerTextColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: MapConfig.markerTextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Flèche vers le bas
            CustomPaint(
              size: Size(MapConfig.markerArrowSize, MapConfig.markerArrowSize),
              painter: _ArrowPainter(color: MapConfig.markerSelectedColor),
            ),
          ],
        ),
      ),
    );
  }

  /// Marker cluster avec animation pulse
  Widget _buildClusterMarker() {
    return GestureDetector(
      onTap: widget.onTap,
      child: _PulseAnimation(
        child: Container(
          width: MapConfig.clusterSize,
          height: MapConfig.clusterSize,
          decoration: BoxDecoration(
            color: MapConfig.markerColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: MapConfig.markerTextColor,
              width: 2,
            ),
            boxShadow: MapConfig.markerShadow,
          ),
          child: Center(
            child: Text(
              '${widget.clusterCount ?? 0}',
              style: const TextStyle(
                color: MapConfig.markerTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter pour la flèche du marker
class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animation pulse pour les clusters
class _PulseAnimation extends StatefulWidget {
  const _PulseAnimation({required this.child});

  final Widget child;

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MapConfig.pulseDuration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
