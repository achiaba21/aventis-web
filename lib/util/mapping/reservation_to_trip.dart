import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Données prêtes à l'affichage pour `TripCard` (LocataireTripsScreen).
///
/// Construit depuis une [Reservation] via [ReservationToTripMapper.mapOne].
class TripCardData {
  final ListingPreview listing;
  final String status;
  final String dates;
  final String code;
  final bool upcoming;
  final int reservationId;

  const TripCardData({
    required this.listing,
    required this.status,
    required this.dates,
    required this.code,
    required this.upcoming,
    required this.reservationId,
  });
}

/// Mappe `Reservation` (modèle métier) → données pour `TripCard` (V5).
///
/// - `status` est dérivé de `ReservationStatus` (libellé court FR)
/// - `dates` est formaté `12 nov - 15 nov` (ou `12 - 15 nov` si même mois)
/// - `code` provient de `codeReservation.code` ou `reference` en fallback
/// - `upcoming` = vrai si `debut` est dans le futur OU `statut` ∈ {enAttente,
///   confirmee, payee} (séjour non encore terminé)
class ReservationToTripMapper {
  ReservationToTripMapper._();

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  static String _statusLabel(ReservationStatus? s) {
    switch (s) {
      case ReservationStatus.enAttente:
        return 'En attente';
      case ReservationStatus.confirmee:
        return 'Confirmée';
      case ReservationStatus.payee:
        return 'Payée';
      case ReservationStatus.finalisee:
      case ReservationStatus.terminee:
        return 'Terminée';
      case ReservationStatus.refusee:
        return 'Refusée';
      case ReservationStatus.annulee:
        return 'Annulée';
      case null:
        return '—';
    }
  }

  static String _formatDates(DateTime? debut, DateTime? fin) {
    if (debut == null || fin == null) return '—';
    final d1 = debut.day;
    final d2 = fin.day;
    final m1 = _months[debut.month - 1];
    final m2 = _months[fin.month - 1];
    if (debut.month == fin.month && debut.year == fin.year) {
      return '$d1 - $d2 $m1';
    }
    return '$d1 $m1 - $d2 $m2';
  }

  static bool _isUpcoming(Reservation r) {
    final s = r.statut;
    if (s == ReservationStatus.refusee ||
        s == ReservationStatus.annulee ||
        s == ReservationStatus.terminee ||
        s == ReservationStatus.finalisee) {
      return false;
    }
    if (r.debut == null) return false;
    return r.debut!.isAfter(DateTime.now()) ||
        s == ReservationStatus.enAttente ||
        s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee;
  }

  static TripCardData mapOne(Reservation source) {
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

    return TripCardData(
      listing: listing,
      status: _statusLabel(source.statut),
      dates: _formatDates(source.debut, source.fin),
      code: source.codeReservation?.secretKey ??
          source.reference ??
          'RES-${source.id ?? 0}',
      upcoming: _isUpcoming(source),
      reservationId: source.id ?? 0,
    );
  }

  static List<TripCardData> mapMany(List<Reservation> sources) {
    return sources.map(mapOne).toList(growable: false);
  }
}
