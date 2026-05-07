/// DTO pour la création d'une demande de réservation par un démarcheur
class DemarcheurReservationReq {
  final int appartId;
  final DateTime debut;
  final int dure;
  final double montant;
  final double? montantCommission;
  final String clientNom;
  final String clientTelephone;

  DemarcheurReservationReq({
    required this.appartId,
    required this.debut,
    required this.dure,
    required this.montant,
    this.montantCommission,
    required this.clientNom,
    required this.clientTelephone,
  });

  Map<String, dynamic> toJson() => {
        'appartId': appartId,
        'debut': debut.toIso8601String(),
        'dure': dure,
        'montant': montant,
        if (montantCommission != null) 'montantCommission': montantCommission,
        'clientNom': clientNom,
        'clientTelephone': clientTelephone,
      };

  @override
  String toString() =>
      'DemarcheurReservationReq(appartId: $appartId, debut: $debut, dure: $dure, montant: $montant, montantCommission: $montantCommission)';
}
