/// DTO pour la création d'une réservation manuelle par le propriétaire
///
/// Permet d'enregistrer une réservation effectuée en dehors de la plateforme
/// pour un suivi complet des appartements.
class ReservationManuelleReq {
  /// ID de l'appartement concerné
  final int appartId;

  /// Date de début de la réservation
  final DateTime debut;

  /// Durée en jours
  final int duree;

  /// Nom du client externe
  final String clientNom;

  /// Téléphone du client externe
  final String clientTelephone;

  /// Email du client externe (optionnel)
  final String? clientEmail;

  /// Montant total de la réservation
  final double montant;

  ReservationManuelleReq({
    required this.appartId,
    required this.debut,
    required this.duree,
    required this.clientNom,
    required this.clientTelephone,
    this.clientEmail,
    required this.montant,
  });

  Map<String, dynamic> toJson() => {
        'appartId': appartId,
        'debut': debut.toIso8601String(),
        'dure': duree, // Note: "dure" sans 'e' selon spec serveur
        'clientNom': clientNom,
        'clientTelephone': clientTelephone,
        if (clientEmail != null && clientEmail!.isNotEmpty)
          'clientEmail': clientEmail,
        'montant': montant,
      };

  @override
  String toString() {
    return 'ReservationManuelleReq(appartId: $appartId, debut: $debut, duree: $duree, clientNom: $clientNom, montant: $montant)';
  }
}
