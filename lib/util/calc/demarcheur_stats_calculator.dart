import 'package:asfar/model/reservation/reservation.dart';

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
    return _sumCommissionsForMonth(reservations, now.year, now.month);
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

  /// Commission totale (toutes périodes confondues, statuts gagnants).
  static int totalCommission(List<Reservation> reservations) {
    int total = 0;
    for (final r in reservations) {
      if (!_isWon(r.statut)) continue;
      total += (r.montantCommission ?? 0).round();
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
        total += (r.montantCommission ?? 0).round();
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

  /// Compteur des réservations `enAttente` (badge « En attente » des pills).
  static int pendingCount(List<Reservation> reservations) {
    return reservations
        .where((r) => r.statut == ReservationStatus.enAttente)
        .length;
  }

  /// Compteur des réservations acceptées (`confirmee`/`payee`/`finalisee`/
  /// `terminee`).
  static int acceptedCount(List<Reservation> reservations) {
    return reservations.where((r) => _isWon(r.statut)).length;
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

  static int _sumCommissionsForMonth(
      List<Reservation> reservations, int year, int month) {
    int total = 0;
    for (final r in reservations) {
      if (r.debut == null || !_isWon(r.statut)) continue;
      if (r.debut!.year != year || r.debut!.month != month) continue;
      total += (r.montantCommission ?? 0).round();
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
/// à pousser » du dashboard et au tunnel `NewReferralScreen`.
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
