import 'package:flutter/material.dart';

/// Configuration d'un onglet de la [BottomNav].
class BottomNavItem {
  final String id;
  final String label;
  final IconData icon;

  const BottomNavItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}
