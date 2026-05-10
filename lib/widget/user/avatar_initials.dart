/// Helper pour extraire les initiales d'un nom complet.
///
/// Prend les 2 premières lettres des 2 premiers mots du nom.
///
/// Exemples :
/// - `from('Aïcha Camara')` → `'AC'`
/// - `from('Aminata Koné')` → `'AK'`
/// - `from('  diallo')` → `'D'`
class AvatarInitials {
  AvatarInitials._();

  static String from(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts
        .take(2)
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .join();
  }
}
