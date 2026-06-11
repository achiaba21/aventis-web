import 'package:asfar/config/env_reader.dart';

class Espacement {
  static double paddingInput = 8;
  static double paddingBloc = 16;
  static double radius = 8;
  static double circle = 100;
  static double gapItem = 4;
  static double gapSection = 12;
}

final month = [
  "Janvier",
  "Février",
  "Mars",
  "Avril",
  "Mai",
  "Juin",
  "Juillet",
  "Août",
  "Septembre",
  "Octobre",
  "Novembre",
  "Décembre",
];
final monthS = [
  "Jan",
  "Fé",
  "Ma",
  "Avril",
  "Mai",
  "Juin",
  "Juil",
  "Août",
  "Sep",
  "Oct",
  "Nov",
  "Déc",
];

/// Schéma réseau lu depuis le fichier `.env` : chiffré par défaut (RM1).
/// Dev local : USE_TLS=false dans `.env` (cf. .env.example).
final bool kUseTls = envFlag('USE_TLS', true);

/// Hôte et port du backend, surchargeables via `.env` :
/// SERVER_HOST=192.168.1.20 / SERVER_PORT=7565
final String serveur = envOr('SERVER_HOST', "192.168.1.7");
final String port = envOr('SERVER_PORT', "7565");

/// Base des appels API (http(s) selon le build)
final String domain = "${kUseTls ? 'https' : 'http'}://$serveur:$port";

/// Base du WebSocket (ws(s) aligné sur le même choix de build)
final String wsDomain = "${kUseTls ? 'wss' : 'ws'}://$serveur:$port";
