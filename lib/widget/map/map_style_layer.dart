import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:asfar/config/map_config.dart';

/// Layer de tuiles stylisées pour flutter_map
///
/// Utilise Stadia Maps avec support du mode sombre
class MapStyleLayer extends StatelessWidget {
  const MapStyleLayer({
    super.key,
    this.isDarkMode = true,
  });

  /// Activer le mode sombre
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: MapConfig.getTileUrl(isDark: isDarkMode),
      userAgentPackageName: MapConfig.userAgent,
      maxZoom: 19,
      minZoom: 3,
    );
  }
}
