import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/calc/reservation_segment.dart';

/// Logique pure de filtrage / tri / comptage des réservations du propriétaire.
///
/// Source unique consommée par `ProprioReservationsScreen` : aucune dépendance
/// Flutter, entièrement testable (façon `ReservationActionsResolver`).
class ProprioReservationsFilter {
  ProprioReservationsFilter._();

  /// Filtre [all] sur le [segment] et le bien [appartementId] (null = tous),
  /// puis trie selon la logique d'urgence propre au segment.
  static List<Reservation> apply({
    required List<Reservation> all,
    required ReservationSegment segment,
    required DateTime now,
    int? appartementId,
  }) {
    final filtrees = all
        .where((r) => ReservationSegment.segmentOf(r, now: now) == segment)
        .where((r) => appartementId == null || r.appart?.id == appartementId)
        .toList();
    _trier(filtrees, segment);
    return filtrees;
  }

  /// Compteurs par segment, en respectant le filtre bien courant
  /// ([appartementId] null = tous les biens). Alimente les badges des chips.
  static Map<ReservationSegment, int> counts({
    required List<Reservation> all,
    required DateTime now,
    int? appartementId,
  }) {
    final result = <ReservationSegment, int>{
      for (final s in ReservationSegment.values) s: 0,
    };
    for (final r in all) {
      if (appartementId != null && r.appart?.id != appartementId) continue;
      final s = ReservationSegment.segmentOf(r, now: now);
      result[s] = result[s]! + 1;
    }
    return result;
  }

  /// Biens distincts présents dans [all], triés par titre — alimente le
  /// sélecteur « Tous les biens ▾ ». Seuls les biens ayant au moins une
  /// réservation apparaissent.
  static List<Appartement> distinctAppartements(List<Reservation> all) {
    final parId = <int, Appartement>{};
    for (final r in all) {
      final a = r.appart;
      final id = a?.id;
      if (a != null && id != null) parId.putIfAbsent(id, () => a);
    }
    final liste = parId.values.toList();
    liste.sort((a, b) => _nomBien(a).compareTo(_nomBien(b)));
    return liste;
  }

  /// Clé de tri d'un bien : titre, sinon numéro, en minuscules.
  static String _nomBien(Appartement a) =>
      (a.titre ?? a.numero ?? '').toLowerCase();

  /// Tri in-place selon l'intention du segment :
  /// - À traiter  : `createdAt` croissant (la demande qui patiente depuis le
  ///   plus longtemps remonte en premier — file d'attente équitable).
  /// - À venir    : `debut` croissant (l'arrivée la plus proche en haut).
  /// - Historique : `fin` décroissant (le plus récent en haut).
  static void _trier(List<Reservation> liste, ReservationSegment segment) {
    switch (segment) {
      case ReservationSegment.aTraiter:
        liste.sort(
            (a, b) => _compareDates(a.createdAt, b.createdAt, asc: true));
        break;
      case ReservationSegment.aVenir:
        liste.sort((a, b) => _compareDates(a.debut, b.debut, asc: true));
        break;
      case ReservationSegment.historique:
        liste.sort((a, b) => _compareDates(a.fin, b.fin, asc: false));
        break;
    }
  }

  /// Compare deux dates en plaçant les valeurs nulles en fin de liste, quel
  /// que soit le sens du tri.
  static int _compareDates(DateTime? a, DateTime? b, {required bool asc}) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return asc ? a.compareTo(b) : b.compareTo(a);
  }
}
