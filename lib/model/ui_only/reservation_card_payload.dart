import 'package:asfar/widget/card/listing_preview.dart';

/// Payload d'un message `MessageKind.reservationCard` — Card « Réservation »
/// dans le `MessagingThreadScreen`.
///
/// Reproduit le mock du proto `extras.jsx::MessagingThread` (lignes 224-232) :
/// img listing 56×56 + eyebrow RÉSERVATION + titre + dates + code mono.
class ReservationCardPayload {
  final ListingPreview listing;
  final String dates;
  final String bookingCode;

  const ReservationCardPayload({
    required this.listing,
    required this.dates,
    required this.bookingCode,
  });
}
