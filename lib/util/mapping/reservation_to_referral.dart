import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Mappe `Reservation` (modèle métier, côté démarcheur) → `ReferralPreview`
/// (V6 DTO de présentation).
///
/// Mapping `ReservationStatus` → `ReferralStatus` :
/// - `enAttente` → `pending`
/// - `confirmee` / `payee` → `accepted` (côté démarcheur, dès que confirmée
///   c'est acceptée par le proprio)
/// - `finalisee` / `terminee` → `completed`
/// - `refusee` / `annulee` → `refused`
class ReservationToReferralMapper {
  ReservationToReferralMapper._();

  static ReferralStatus _statusFor(ReservationStatus? s) {
    switch (s) {
      case ReservationStatus.confirmee:
      case ReservationStatus.payee:
        return ReferralStatus.accepted;
      case ReservationStatus.finalisee:
      case ReservationStatus.terminee:
        return ReferralStatus.completed;
      case ReservationStatus.refusee:
      case ReservationStatus.annulee:
        return ReferralStatus.refused;
      case ReservationStatus.enAttente:
      case null:
        return ReferralStatus.pending;
    }
  }

  static int _nightsBetween(DateTime? a, DateTime? b) {
    if (a == null || b == null) return 1;
    final diff = b.difference(a).inDays;
    return diff > 0 ? diff : 1;
  }

  static ReferralPreview mapOne(Reservation source) {
    final listing = source.appart != null
        ? AppartementToListingMapper.mapOne(source.appart!)
        : const ListingPreview(
            id: '0',
            tone: 1,
            title: 'Logement supprimé',
            area: '',
            city: '',
            price: 0,
          );

    final clientName = source.clientNom?.trim().isNotEmpty == true
        ? source.clientNom!
        : 'Client #${source.id ?? 0}';
    final clientPhone =
        source.clientExterneTelephone ?? source.locataire?.telephone ?? '';

    return ReferralPreview(
      id: source.codeReservation?.secretKey ??
          source.reference ??
          'REF-${source.id ?? 0}',
      clientName: clientName,
      clientPhone: clientPhone,
      listing: listing,
      nights: _nightsBetween(source.debut, source.fin),
      sentAt: source.createdAt ?? DateTime.now(),
      status: _statusFor(source.statut),
      commission: (source.montantCommission ?? 0).round(),
    );
  }

  static List<ReferralPreview> mapMany(List<Reservation> sources) {
    return sources.map(mapOne).toList(growable: false);
  }
}
