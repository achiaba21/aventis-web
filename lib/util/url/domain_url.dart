import 'package:asfar/config/app_propertie.dart';

/// Résout une URL relative en URL complète en préfixant avec `$domain`.
///
/// Le backend renvoie typiquement des paths relatifs (ex : `/uploads/xyz.jpg`,
/// `uploads/xyz.jpg`, ou parfois juste `xyz.jpg`). Ce helper :
///
/// - retourne `null` si l'entrée est `null` ou vide
/// - retourne l'entrée telle quelle si elle est déjà absolue (`http://`,
///   `https://`, `data:`, `blob:`)
/// - retourne sinon `$domain/<path>` (avec normalisation du slash)
///
/// À utiliser systématiquement avant un `Image.network` qui consomme un
/// champ retourné par le backend (`PhotoAppart.path`, `Appartement.imgUrl`,
/// `Client.imgUrl`, etc.).
String? resolveDomainUrl(String? path) {
  if (path == null) return null;
  final trimmed = path.trim();
  if (trimmed.isEmpty) return null;

  final lower = trimmed.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('data:') ||
      lower.startsWith('blob:')) {
    return trimmed;
  }

  final normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  return '$domain/$normalized';
}
