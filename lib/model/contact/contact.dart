/// Entité générique représentant un contact joignable depuis l'app.
///
/// Décrit *qui* l'utilisateur peut contacter et *par quels canaux*. Ne porte
/// aucune logique de disponibilité (statut, rôle viewer) — cela relève de
/// `ContactAvailability`.
///
/// Utilisé par `ContactSheet`, `ContactButton`, `CallButton` et produit par
/// `ContactTargetResolver`.
class Contact {
  /// Nom affichable de la cible (ex: "Jean Dupont").
  final String displayName;

  /// Libellé du rôle de la cible (ex: "Propriétaire", "Client", "Démarcheur").
  final String roleLabel;

  /// Téléphone pour appel direct (`tel:`). Null ou vide si non disponible.
  final String? telephone;

  /// Numéro WhatsApp dédié si différent du téléphone classique.
  /// Si null, on retombe sur [telephone] pour la disponibilité WhatsApp.
  final String? whatsAppPhone;

  /// Identifiant user backend pour ouvrir un chat in-app. Null si la cible
  /// n'est pas chattable (ex: client externe d'une résa manuelle).
  final int? userId;

  /// URL avatar optionnelle pour affichage dans la sheet.
  final String? avatarUrl;

  const Contact({
    required this.displayName,
    required this.roleLabel,
    this.telephone,
    this.whatsAppPhone,
    this.userId,
    this.avatarUrl,
  });

  /// `true` si un numéro de téléphone classique est renseigné.
  bool get hasPhone => (telephone ?? '').trim().isNotEmpty;

  /// `true` si un numéro est joignable via WhatsApp (whatsAppPhone explicite,
  /// ou fallback sur telephone).
  bool get hasWhatsApp =>
      (whatsAppPhone ?? telephone ?? '').trim().isNotEmpty;

  /// `true` si la cible est chattable in-app (un `userId` est connu).
  bool get canChat => userId != null;

  /// Numéro effectif pour WhatsApp (whatsAppPhone si présent, sinon telephone).
  String? get effectiveWhatsAppPhone {
    final wa = (whatsAppPhone ?? '').trim();
    if (wa.isNotEmpty) return wa;
    final tel = (telephone ?? '').trim();
    return tel.isEmpty ? null : tel;
  }
}
