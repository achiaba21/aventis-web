import 'package:asfar/widget/card/listing_preview.dart';

/// Statuts d'une référence démarcheur.
///
/// Aligne sur les 4 chips de filtre du proto (`app.jsx::ReferralsScreen`) :
/// En attente / Acceptées / Terminées / Refusées.
enum ReferralStatus { pending, accepted, completed, refused }

/// Modèle UI-only pour une référence démarcheur.
///
/// Reproduit la structure du proto `demarcheur.jsx::DemarcheurDashboard`
/// (mock `mockReferrals`). Ce modèle ne remplace pas les modèles métier
/// (`Reservation`, `PartenariatDemandeProprio`) — il sert uniquement à
/// typer les samples Vague 6 en attendant le branchement BLoC réel.
class ReferralPreview {
  final String id;
  final String clientName;
  final String clientPhone;
  final ListingPreview listing;
  final int nights;
  final DateTime sentAt;
  final ReferralStatus status;
  final int commission;

  const ReferralPreview({
    required this.id,
    required this.clientName,
    required this.clientPhone,
    required this.listing,
    required this.nights,
    required this.sentAt,
    required this.status,
    required this.commission,
  });

  /// Sous-total séjour (prix nuit × nuits).
  int get subtotal => listing.price * nights;
}
