import 'package:jwt_decoder/jwt_decoder.dart';

/// Validité d'un jeton de session (JWT) côté client
///
/// Logique pure (aucune I/O, aucun singleton) pour rester testable
/// unitairement. La vérification de signature reste la responsabilité
/// du serveur : ici on ne décide que « ce jeton vaut-il la peine d'être
/// envoyé ? » (présent, décodable, non expiré).
class TokenValidator {
  TokenValidator._();

  /// `true` si le jeton est présent, décodable et non expiré
  ///
  /// Un jeton malformé ou sans date d'expiration est traité comme invalide.
  /// Ne lève jamais d'exception.
  static bool isValid(String? token) {
    if (token == null || token.isEmpty) return false;
    try {
      return !JwtDecoder.isExpired(token);
    } catch (_) {
      return false;
    }
  }
}
