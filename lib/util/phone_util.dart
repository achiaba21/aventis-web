/// Utilitaire pour la gestion des numéros de téléphone
class PhoneUtil {
  /// Retire l'indicatif pays (+225 ou 225) d'un numéro de téléphone
  ///
  /// Exemples:
  /// - "+22507123456" -> "07123456"
  /// - "22507123456" -> "07123456"
  /// - "07123456" -> "07123456"
  static String removeCountryCode(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    String normalized = phoneNumber.trim();

    // Retirer +225
    if (normalized.startsWith('+225')) {
      return normalized.substring(4);
    }

    // Retirer 225
    if (normalized.startsWith('225') && normalized.length > 10) {
      return normalized.substring(3);
    }

    return normalized;
  }

  /// Ajoute l'indicatif pays (+225) à un numéro de téléphone s'il n'existe pas
  ///
  /// Exemples:
  /// - "07123456" -> "+22507123456"
  /// - "+22507123456" -> "+22507123456"
  /// - "22507123456" -> "+22507123456"
  static String addCountryCode(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    String normalized = phoneNumber.trim();

    // Déjà avec +225
    if (normalized.startsWith('+225')) {
      return normalized;
    }

    // Avec 225 sans +
    if (normalized.startsWith('225') && normalized.length > 10) {
      return '+$normalized';
    }

    // Sans indicatif
    return '+225$normalized';
  }
}
