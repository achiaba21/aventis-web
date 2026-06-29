import 'package:asfar/config/app_propertie.dart';

/// Construit le lien public de partage des photos d'un appartement.
///
/// Format backend : `{BASE_URL}/share/{partageToken}` où `BASE_URL` est la
/// base d'environnement (`domain`) déjà utilisée pour appeler l'API. Le token
/// est déjà présent sur l'objet `Appartement` — aucun appel réseau, aucune
/// génération côté client : on construit juste la chaîne.
///
/// ⚠️ En DEV, `domain` vaut une IP/localhost → le lien n'est PAS ouvrable par
/// un prospect externe. À tester en prod (domaine public) ou via ngrok / IP LAN.
String buildAppartementShareUrl(String partageToken) {
  return '$domain/share/$partageToken';
}
