import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void deboger(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}

/// Affiche un objet de manière formatée et complète (pretty-print)
///
/// Utilise la méthode toJson() de l'objet pour l'afficher en JSON indenté
/// Idéal pour debugger des objets complexes (Appartement, User, etc.)
///
/// Exemples:
/// ```dart
/// prettyPrint(appartement, label: 'Appartement créé');
/// prettyPrint(user, label: 'User connecté');
/// prettyPrint(appartement.offres, label: 'Liste des offres');
/// ```
void prettyPrint(
  dynamic object, {
  String? label,
  bool showType = true,
}) {
  if (!kDebugMode) return; // Ne rien afficher en mode release

  try {
    
    // Créer l'encodeur JSON avec indentation
    const encoder = JsonEncoder.withIndent('  ');

    // Ligne de séparation
    final separator = '=' * 60;
    final title = label ?? 'Object';

    print(separator);
    print('  $title');
    print(separator);

    // Afficher le type de l'objet si demandé
    if (showType) {
      print('Type: ${object.runtimeType}');
      print('---');
    }

    // Convertir l'objet en JSON et formater
    dynamic jsonObject;

    if (object == null) {
      print('null');
    } else if (object is String || object is num || object is bool) {
      // Types primitifs
      print(object);
    } else if (object is Map) {
      // Map déjà en JSON
      jsonObject = object;
    } else if (object is List) {
      // Liste d'objets
      jsonObject = object.map((item) {
        // Si l'item a une méthode toJson, l'utiliser
        try {
          return (item as dynamic).toJson();
        } catch (e) {
          return item.toString();
        }
      }).toList();
    } else if (object is FormData) {
      prettyPrint(object.fields.map((e)=>json.decode(e.value)));
    }else {
      // Objet avec méthode toJson()
      try {
        jsonObject = (object as dynamic).toJson();
      } catch (e) {
        // Si pas de toJson(), utiliser toString()
        print(object.toString());
        print(separator);
        return;
      }
    }

    // Encoder en JSON formaté et afficher ligne par ligne
    if (jsonObject != null) {
      final prettyString = encoder.convert(jsonObject);
      final lines = prettyString.split('\n');

      // for (var line in lines) {
      //   print(line);
      // }
      print(lines);
    }

    print(separator);
  } catch (e) {
    // En cas d'erreur, fallback sur toString()
    print('Erreur lors du formatage: $e');
    print(object.toString());
  }
}

T? findByid<T>(List<T> items, bool Function(T) test) {
  try {
    return items.firstWhere(test);
  } catch (e) {
    return null;
  }
}
