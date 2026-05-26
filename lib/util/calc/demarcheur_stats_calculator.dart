import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_counted.dart';

/// Calcule les KPI affichés sur le `DemarcheurDashboard` (WalletHeroCard +
/// StatusPillsRow) depuis la liste des réservations référencées par le
/// démarcheur connecté.
///
/// Convention : `montantCommission` est porté par chaque `Reservation`
/// (déjà calculé côté serveur, en général 10% du `prix`).
class DemarcheurStatsCalculator {
  DemarcheurStatsCalculator._();

  /// Commission gagnée sur le mois courant — réservations confirmées,
  /// payées, finalisées ou terminées dont la date `debut` tombe ce mois-ci.
  static int monthCommission(List<Reservation> reservations) {
    final now = DateTime.now();
    return commissionForMonth(reservations, now.year, now.month);
  }

  /// Commission gagnée pour un mois donné (`debut` tombe dans `[year, month]`
  /// et statut « gagnant »).
  static int commissionForMonth(
      List<Reservation> reservations, int year, int month) {
    return _sumCommissionsForMonth(reservations, year, month);
  }

  /// Commission gagnée le mois précédent.
  static int previousMonthCommission(List<Reservation> reservations) {
    final now = DateTime.now();
    final prev = DateTime(now.year, now.month - 1, 1);
    return _sumCommissionsForMonth(reservations, prev.year, prev.month);
  }

  /// Δ en % entre `monthCommission` et `previousMonthCommission`.
  /// Renvoie 0 si le mois précédent est nul (évite la division par zéro).
  static int deltaPercent(List<Reservation> reservations) {
    final cur = monthCommission(reservations);
    final prev = previousMonthCommission(reservations);
    if (prev == 0) return 0;
    return (((cur - prev) / prev) * 100).round();
  }

  /// Δ en % entre la commission du mois `[year, month]` et celle du mois
  /// précédent. Renvoie 0 si le mois précédent est nul.
  static int deltaPercentForMonth(
      List<Reservation> reservations, int year, int month) {
    final prev = DateTime(year, month - 1, 1);
    final cur = _sumCommissionsForMonth(reservations, year, month);
    final prv = _sumCommissionsForMonth(reservations, prev.year, prev.month);
    if (prv == 0) return 0;
    return (((cur - prv) / prv) * 100).round();
  }

  /// Commission totale (toutes périodes confondues, statuts gagnants).
  static int totalCommission(List<Reservation> reservations) {
    int total = 0;
    for (final r in reservations) {
      if (!_isWon(r.statut)) continue;
      total += r.demarcheurCommissionAmount.round();
    }
    return total;
  }

  /// Commission en attente — réservations encore `enAttente` ou `confirmee`
  /// non encore payées.
  static int pendingCommission(List<Reservation> reservations) {
    int total = 0;
    for (final r in reservations) {
      if (r.statut == ReservationStatus.enAttente ||
          r.statut == ReservationStatus.confirmee) {
        total += r.demarcheurCommissionAmount.round();
      }
    }
    return total;
  }

  /// Commission en attente pour le mois `[year, month]` — résa `enAttente`
  /// ou `confirmee` dont la date `debut` tombe dans ce mois.
  static int pendingCommissionForMonth(
      List<Reservation> reservations, int year, int month) {
    int total = 0;
    for (final r in reservations) {
      if (!_fallsInMonth(r.debut, year, month)) continue;
      if (r.statut == ReservationStatus.enAttente ||
          r.statut == ReservationStatus.confirmee) {
        total += r.demarcheurCommissionAmount.round();
      }
    }
    return total;
  }

  /// Nombre de clients distincts référencés (basé sur `clientNom` non vide).
  static int clientsCount(List<Reservation> reservations) {
    final names = <String>{};
    for (final r in reservations) {
      final name = r.clientNom?.trim();
      if (name != null && name.isNotEmpty) names.add(name);
    }
    return names.length;
  }

  /// Nombre de clients distincts dont une résa débute dans le mois donné.
  static int clientsCountForMonth(
      List<Reservation> reservations, int year, int month) {
    final names = <String>{};
    for (final r in reservations) {
      if (!_fallsInMonth(r.debut, year, month)) continue;
      final name = r.clientNom?.trim();
      if (name != null && name.isNotEmpty) names.add(name);
    }
    return names.length;
  }

  /// Compteur des réservations `enAttente` (badge « En attente » des pills).
  static int pendingCount(List<Reservation> reservations) {
    return reservations
        .where((r) => r.statut == ReservationStatus.enAttente)
        .length;
  }

  /// Compteur des `enAttente` dont la date `debut` tombe dans le mois donné.
  static int pendingCountForMonth(
      List<Reservation> reservations, int year, int month) {
    return reservations
        .where((r) =>
            _fallsInMonth(r.debut, year, month) &&
            r.statut == ReservationStatus.enAttente)
        .length;
  }

  /// Compteur des réservations acceptées (`confirmee`/`payee`/`finalisee`/
  /// `terminee`).
  static int acceptedCount(List<Reservation> reservations) {
    return reservations.where((r) => _isWon(r.statut)).length;
  }

  /// Compteur des résa acceptées dont `debut` tombe dans le mois donné.
  static int acceptedCountForMonth(
      List<Reservation> reservations, int year, int month) {
    return reservations
        .where((r) => _fallsInMonth(r.debut, year, month) && _isWon(r.statut))
        .length;
  }

  /// Taux d'acceptation = acceptées / (acceptées + refusées + annulées).
  /// Renvoie 0 si aucune réservation décidée.
  static int acceptanceRate(List<Reservation> reservations) {
    final accepted = acceptedCount(reservations);
    final refused = reservations
        .where((r) =>
            r.statut == ReservationStatus.refusee ||
            r.statut == ReservationStatus.annulee)
        .length;
    final decided = accepted + refused;
    if (decided == 0) return 0;
    return ((accepted / decided) * 100).round();
  }

  /// Taux d'acceptation restreint aux résa dont `debut` tombe dans le mois.
  static int acceptanceRateForMonth(
      List<Reservation> reservations, int year, int month) {
    final accepted = acceptedCountForMonth(reservations, year, month);
    final refused = reservations
        .where((r) =>
            _fallsInMonth(r.debut, year, month) &&
            (r.statut == ReservationStatus.refusee ||
                r.statut == ReservationStatus.annulee))
        .length;
    final decided = accepted + refused;
    if (decided == 0) return 0;
    return ((accepted / decided) * 100).round();
  }

  static bool _fallsInMonth(DateTime? d, int year, int month) {
    return d != null && d.year == year && d.month == month;
  }

  static int _sumCommissionsForMonth(
      List<Reservation> reservations, int year, int month) {
    int total = 0;
    for (final r in reservations) {
      if (r.debut == null || !_isWon(r.statut)) continue;
      if (r.debut!.year != year || r.debut!.month != month) continue;
      total += r.demarcheurCommissionAmount.round();
    }
    return total;
  }

  static bool _isWon(ReservationStatus? s) {
    return s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }
}

/// Helper pur pour estimer la commission qu'un démarcheur peut gagner s'il
/// référence un séjour sur un logement donné. Sert au carrousel « Logements
/// partenaires » du dashboard et au tunnel `NewReferralScreen`.
class ReferralCommissionHelper {
  ReferralCommissionHelper._();

  /// Taux de commission démarcheur (10% du séjour brut). Source : décision
  /// produit Asfar — visible dans l'`InfoBanner` du `NewReferralScreen`
  /// (« 10 % du séjour · versée après paiement client »).
  static const double rate = 0.10;

  /// Nombre de nuits par défaut pour l'estimation (séjour court standard).
  static const int defaultNights = 3;

  /// Commission estimée pour un séjour à `pricePerNight` × `nights`.
  static int estimate({required int pricePerNight, int nights = defaultNights}) {
    return (pricePerNight * nights * rate).round();
  }
}
