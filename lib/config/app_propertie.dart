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

/// Schéma réseau décidé au build : production = chiffré par défaut (RM1).
/// Dev local : flutter run --dart-define=USE_TLS=false
const bool kUseTls = bool.fromEnvironment('USE_TLS', defaultValue: true);

/// Hôte et port du backend, surchargeables au build :
/// flutter run --dart-define=SERVER_HOST=192.168.1.20 --dart-define=SERVER_PORT=7565
const String serveur =
    String.fromEnvironment('SERVER_HOST', defaultValue: "192.168.1.7");
const String port = String.fromEnvironment('SERVER_PORT', defaultValue: "7565");

/// Base des appels API (http(s) selon le build)
final String domain = "${kUseTls ? 'https' : 'http'}://$serveur:$port";

/// Base du WebSocket (ws(s) aligné sur le même choix de build)
final String wsDomain = "${kUseTls ? 'wss' : 'ws'}://$serveur:$port";
