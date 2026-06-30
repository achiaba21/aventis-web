import 'package:asfar/model/reservation/reservation.dart';

/// Segment « par intention » d'une réservation côté propriétaire.
///
/// Regroupe les statuts backend bruts (`ReservationStatus`) selon ce que le
/// proprio doit *faire*, plutôt que selon l'état technique :
/// - [aTraiter]   : décision immédiate attendue (confirmer / refuser).
/// - [aVenir]     : séjour confirmé/payé, en cours ou à venir.
/// - [historique] : terminé, annulé, ou passé non clôturé — hors du chemin.
///
/// Source unique du mapping statut → segment (helper pur, testable).
enum ReservationSegment {
  aTraiter('À traiter'),
  aVenir('À venir'),
  historique('Historique');

  const ReservationSegment(this.label);

  /// Libellé court affiché sur le chip de filtre.
  final String label;

  /// Détermine le segment d'une réservation à l'instant [now].
  ///
  /// Règles (contrat métier validé 2026-06-30) :
  /// - `enAttente` → [aTraiter] (quelle que soit la date).
  /// - `confirmée`/`payée` avec `fin >= aujourd'hui` → [aVenir].
  /// - tout le reste (finalisée, annulée, confirmée/payée *passée*, statut
  ///   inconnu) → [historique].
  ///
  /// La comparaison se fait au jour près (heures ignorées) : une réservation
  /// qui se termine aujourd'hui reste « À venir ».
  static ReservationSegment segmentOf(Reservation r, {required DateTime now}) {
    final statut = r.statut;
    if (statut == ReservationStatus.enAttente) {
      return ReservationSegment.aTraiter;
    }

    final estActive = statut == ReservationStatus.confirmee ||
        statut == ReservationStatus.payee;
    if (estActive && !_estPassee(r.fin, now)) {
      return ReservationSegment.aVenir;
    }

    return ReservationSegment.historique;
  }

  /// `true` si [fin] est antérieure à aujourd'hui (comparaison au jour près).
  ///
  /// Une `fin` nulle est considérée comme non passée : la réservation reste
  /// visible dans « À venir » plutôt que de disparaître silencieusement.
  static bool _estPassee(DateTime? fin, DateTime now) {
    if (fin == null) return false;
    final jourFin = DateTime(fin.year, fin.month, fin.day);
    final aujourdHui = DateTime(now.year, now.month, now.day);
    return jourFin.isBefore(aujourdHui);
  }
}
