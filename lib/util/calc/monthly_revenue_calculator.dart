import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';

/// Calcule les revenus mensuels du proprio depuis l'historique des
/// réservations.
///
/// Règles métier :
/// - **Statuts comptés** : `payee`, `finalisee`, `terminee` uniquement
///   (`confirmee` est exclue : engagement non encore encaissé).
/// - **Revenu net** : `r.prix - r.frais` (frais Asfar soustraits).
/// - **Date de comptabilisation** : mois de `r.debut` (date de séjour).
///
/// Toutes les méthodes acceptent un `DateTime targetMonth` optionnel pour
/// permettre la navigation dans le temps (par défaut = mois courant).
class MonthlyRevenueCalculator {
  MonthlyRevenueCalculator._();

  static const _monthsShort = [
    'Jan', 'Fév', 'Mars', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
  ];

  static const _monthsFull = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  /// Libellé court (3 lettres + point) — pour la sparkbar.
  static String shortLabel(DateTime month) => _monthsShort[month.month - 1];

  /// Libellé complet — pour le label « vs. octobre · X FCFA ».
  static String fullLabel(DateTime month) => _monthsFull[month.month - 1];

  /// Normalise un `DateTime` au 1er jour du mois (00:00).
  static DateTime normalize(DateTime d) => DateTime(d.year, d.month, 1);

  /// 6 derniers mois se terminant par `targetMonth` (anciens → cible).
  ///
  /// Chaque mois porte son encaissé (`amount`) ET son pipeline (`pipeline`).
  static List<MonthlyRevenue> last6Months(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final ref = normalize(targetMonth ?? DateTime.now());
    return [
      for (var i = 5; i >= 0; i--)
        () {
          final m = DateTime(ref.year, ref.month - i, 1);
          return MonthlyRevenue(
            month: m,
            monthShort: _monthsShort[m.month - 1],
            amount: _sumForMonth(reservations, m),
            pipeline: _pipelineForMonth(reservations, m),
          );
        }(),
    ];
  }

  /// Revenu net d'un mois donné (défaut = mois courant).
  static int revenueFor(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    return _sumForMonth(reservations, normalize(targetMonth ?? DateTime.now()));
  }

  /// Revenu du mois précédant `targetMonth`.
  static int previousRevenue(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final ref = normalize(targetMonth ?? DateTime.now());
    final prev = DateTime(ref.year, ref.month - 1, 1);
    return _sumForMonth(reservations, prev);
  }

  /// Mois précédant `targetMonth` — utile pour l'eyebrow dynamique.
  static DateTime previousMonth({DateTime? targetMonth}) {
    final ref = normalize(targetMonth ?? DateTime.now());
    return DateTime(ref.year, ref.month - 1, 1);
  }

  /// Delta % entre `targetMonth` et le mois précédent. Retourne 0 si le
  /// précédent vaut 0 (sauf si target > 0 → +100).
  static int deltaPercent(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final cur = revenueFor(reservations, targetMonth: targetMonth);
    final prev = previousRevenue(reservations, targetMonth: targetMonth);
    if (prev == 0) return cur == 0 ? 0 : 100;
    return (((cur - prev) / prev) * 100).round();
  }

  /// Montant **engagé** d'un mois donné : somme nette des réservations en
  /// statut `confirmee` (proprio a accepté, locataire pas encore payé).
  ///
  /// Utile pour afficher une trace du « pipeline » côté Dashboard, distinct
  /// du revenu réellement encaissé retourné par [revenueFor].
  static int pipelineFor(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    return _pipelineForMonth(
      reservations,
      normalize(targetMonth ?? DateTime.now()),
    );
  }

  static int _pipelineForMonth(List<Reservation> reservations, DateTime month) {
    int total = 0;
    for (final r in reservations) {
      if (r.debut == null || r.prix == null) continue;
      if (r.debut!.year != month.year || r.debut!.month != month.month) {
        continue;
      }
      if (r.statut != ReservationStatus.confirmee) continue;
      final brut = r.prix!.round();
      final frais = (r.frais ?? 0).round();
      total += (brut - frais);
    }
    return total;
  }

  /// Moyenne glissante 3 mois se terminant par `targetMonth` (inclus).
  static int average3MonthsEnding(
    List<Reservation> reservations, {
    DateTime? targetMonth,
  }) {
    final ref = normalize(targetMonth ?? DateTime.now());
    int total = 0;
    for (var i = 0; i < 3; i++) {
      final m = DateTime(ref.year, ref.month - i, 1);
      total += _sumForMonth(reservations, m);
    }
    return (total / 3).round();
  }

  static int _sumForMonth(List<Reservation> reservations, DateTime month) {
    int total = 0;
    for (final r in reservations) {
      if (r.debut == null || r.prix == null) continue;
      if (r.debut!.year != month.year || r.debut!.month != month.month) {
        continue;
      }
      if (!_isCounted(r.statut)) continue;
      final brut = r.prix!.round();
      final frais = (r.frais ?? 0).round();
      total += (brut - frais);
    }
    return total;
  }

  static bool _isCounted(ReservationStatus? s) {
    return s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee ||
        s == ReservationStatus.terminee;
  }
}
