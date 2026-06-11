import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Lit la variable [key] du fichier `.env` chargé au démarrage.
///
/// Retourne [fallback] si le `.env` n'a pas été chargé (tests, fichier
/// absent) ou si la clé est absente ou vide.
String envOr(String key, String fallback) {
  if (!dotenv.isInitialized) return fallback;
  final value = dotenv.maybeGet(key)?.trim();
  if (value == null || value.isEmpty) return fallback;
  return value;
}

/// Variante booléenne de [envOr] : `true`/`false` insensibles à la casse,
/// toute autre valeur retombe sur [fallback].
bool envFlag(String key, bool fallback) {
  switch (envOr(key, '$fallback').toLowerCase()) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      return fallback;
  }
}
