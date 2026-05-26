import 'package:flutter/material.dart';

class Commodite {
  int? id;
  String? nom;
  String? description;
  String? value;

  Commodite({
    this.id,
    this.nom,
    this.description,
    this.value,
  });

  Commodite.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    description = json['description'];
    value = json['value'];
  }

  /// Crée une instance de Commodite depuis un JSON
  /// Plus besoin de sous-classes - on utilise directement Commodite
  static Commodite fromJsonAll(Map<String, dynamic> json) {
    return Commodite.fromJson(json);
  }

  /// Retourne l'icône correspondant à la commodité.
  ///
  /// Le mapping `value → IconData` reste côté Flutter (les icônes ne viennent
  /// pas du backend). Aligné sur le référentiel `GET /auth/commodites` qui
  /// expose 16 chips wizard + variantes legacy.
  IconData getIcon() {
    switch (value?.toLowerCase()) {
      case 'wifi':
      case 'wifi_fibre':
        return Icons.wifi;
      case 'ac':
      case 'climatisation':
      case 'climatiseur':
        return Icons.ac_unit;
      case 'hot_water':
      case 'water_flow':
      case 'water':
        return Icons.water_drop;
      case 'kitchen_eq':
      case 'kitchen':
      case 'cuisine':
        return Icons.kitchen_outlined;
      case 'washing_machine':
      case 'machine_a_laver':
        return Icons.local_laundry_service;
      case 'fridge':
        return Icons.kitchen;
      case 'tv':
        return Icons.tv;
      case 'carpark':
      case 'parking':
        return Icons.local_parking;
      case 'security':
        return Icons.security;
      case 'pool':
        return Icons.pool;
      case 'gym':
      case 'fitness':
        return Icons.fitness_center;
      case 'elevator':
        return Icons.elevator;
      case 'sea_view':
      case 'lagoon_view':
        return Icons.waves;
      case 'balcony':
      case 'balcon':
        return Icons.balcony;
      case 'heater':
      case 'chauffe_eau':
        return Icons.water_damage;
      default:
        return Icons.check_circle_outline;
    }
  }

  /// Retourne le label à afficher pour la commodité
  /// Utilise 'nom' si disponible, sinon fallback sur 'value'
  String getLabel() {
    return nom ?? value ?? 'Équipement';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['description'] = description;
    data['value'] = value;
    return data;
  }
}
