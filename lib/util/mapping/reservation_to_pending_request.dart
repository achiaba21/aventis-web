import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/pending_request.dart';

/// Mappe `Reservation` (côté proprio, statut EN_ATTENTE) → `PendingRequest`
/// (V7 DTO de la section « Demandes en attente » du Dashboard proprio).
///
/// Utilisé par `ProprioDashboard` pour brancher la liste des demandes en
/// attente sur le `ReservationBloc` (filtré statut == enAttente côté
/// proprietaire reservations).
class ReservationToPendingRequestMapper {
  ReservationToPendingRequestMapper._();

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  static String _formatDates(DateTime? d, DateTime? f) {
    if (d == null || f == null) return '';
    final m = _months[d.month - 1];
    final nights = f.difference(d).inDays;
    return '${d.day}-${f.day} $m · $nights nuit${nights > 1 ? 's' : ''}';
  }

  static PendingRequestKind _kindFor(ReservationType? type) {
    if (type == ReservationType.demarcheur) {
      return PendingRequestKind.fromDemarcheur;
    }
    return PendingRequestKind.direct;
  }

  static String _whoLabel(Reservation r) {
    final base = r.clientNom?.trim().isNotEmpty == true
        ? r.clientNom!
        : 'Client #${r.id ?? 0}';
    if (r.type == ReservationType.demarcheur) {
      return '$base (démarcheur)';
    }
    return 'Direct: $base';
  }

  static String _typeLabel(Reservation r) {
    if (r.type == ReservationType.demarcheur) {
      return 'Réservation pour client';
    }
    return 'Demande de réservation';
  }

  static PendingRequest mapOne(Reservation source) {
    final apartTitle = source.appart?.titre ?? 'Logement';
    final dates = _formatDates(source.debut, source.fin);
    return PendingRequest(
      who: _whoLabel(source),
      typeLabel: _typeLabel(source),
      contextLabel: dates.isEmpty ? apartTitle : '$apartTitle · $dates',
      kind: _kindFor(source.type),
      isNew: source.statut == ReservationStatus.enAttente,
    );
  }

  /// Filtre les réservations en attente puis mappe.
  static List<PendingRequest> mapPending(List<Reservation> sources) {
    return sources
        .where((r) => r.statut == ReservationStatus.enAttente)
        .map(mapOne)
        .toList(growable: false);
  }
}
