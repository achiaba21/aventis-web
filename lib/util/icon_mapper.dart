import 'package:flutter/material.dart';

/// Utilitaire pour mapper les noms d'icônes (String) vers IconData
class IconMapper {
  static final Map<String, IconData> _iconMap = {
    'smoke_free': Icons.smoke_free,
    'pets': Icons.pets,
    'celebration_outlined': Icons.celebration_outlined,
    'nightlight_outlined': Icons.nightlight_outlined,
    'rule': Icons.rule,
    'wifi': Icons.wifi,
    'local_parking': Icons.local_parking,
    'fitness_center': Icons.fitness_center,
    'pool': Icons.pool,
    'kitchen': Icons.kitchen,
    'tv': Icons.tv,
    'ac_unit': Icons.ac_unit,
    'elevator': Icons.elevator,
    'accessible': Icons.accessible,
    'child_friendly': Icons.child_friendly,
    'music_off': Icons.music_off,
    'do_not_disturb': Icons.do_not_disturb,
    'check_circle': Icons.check_circle,
    'cancel': Icons.cancel,
  };

  /// Retourne l'IconData correspondant au nom, ou une icône par défaut
  static IconData getIcon(String? iconName) {
    if (iconName == null) return Icons.rule;
    return _iconMap[iconName] ?? Icons.rule;
  }

  /// Retourne le nom de l'icône à partir d'IconData (pour toJson)
  static String? getIconName(IconData icon) {
    for (var entry in _iconMap.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return null;
  }
}
