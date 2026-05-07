/// Utilitaires pour la manipulation des chaînes de caractères
class StringUtils {
  /// Récupère les initiales d'un nom
  /// Exemples:
  /// - "Jean Dupont" → "JD"
  /// - "Marie" → "M"
  /// - "" → "?"
  static String getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
