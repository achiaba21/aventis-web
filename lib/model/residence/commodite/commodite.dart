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

  /// Retourne l'icône correspondant à la commodité
  /// Basé sur le mapping avec AmenitiesGrid.amenities
  ///
  /// PRINCIPE SOLID - Single Responsibility (S) :
  /// Cette méthode a la responsabilité de mapper les valeurs backend vers les icônes Flutter
  IconData getIcon() {
    // Mapping des valeurs de commodités vers les icônes Material
    switch (value?.toLowerCase()) {
      case 'pool':
        return Icons.pool;
      case 'carpark':
      case 'parking':
        return Icons.local_parking;
      case 'gym':
      case 'fitness':
        return Icons.fitness_center;
      case 'kitchen':
      case 'cuisine':
        return Icons.kitchen;
      case 'water_flow':
      case 'water':
        return Icons.water_drop;
      case 'wifi':
        return Icons.wifi;
      case 'ac':
      case 'climatisation':
      case 'climatiseur':
        return Icons.ac_unit;
      case 'balcony':
      case 'balcon':
        return Icons.balcony;
      case 'washing_machine':
      case 'machine_a_laver':
        return Icons.local_laundry_service;
      case 'heater':
      case 'chauffe_eau':
        return Icons.water_damage;
      default:
        // Icône par défaut pour les commodités non reconnues
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
