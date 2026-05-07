import 'package:asfar/model/occupation/occupation_period.dart';
import 'package:asfar/model/reservation/reservation.dart';

/// Helper pour transformer des réservations en périodes d'occupation
///
/// Utilisé pour éviter les appels API redondants côté propriétaires,
/// qui ont déjà toutes leurs réservations chargées dans le ReservationBloc.
class OccupationHelper {
  /// Transforme une liste de réservations en périodes d'occupation
  ///
  /// Filtre uniquement les réservations CONFIRMÉES (statut CONFIRMER)
  /// qui correspondent aux critères d'occupation réelle.
  ///
  /// Paramètres :
  /// - [reservations] : Liste des réservations à transformer
  /// - [appartementId] : (Optionnel) Filtrer pour un appartement spécifique
  /// - [appartementIds] : (Optionnel) Filtrer pour une liste d'appartements
  ///
  /// Retourne une liste de [OccupationPeriod] prête à être affichée
  /// dans le calendrier d'occupation.
  static List<OccupationPeriod> reservationsToOccupationPeriods(
    List<Reservation> reservations, {
    int? appartementId,
    List<int>? appartementIds,
  }) {
    // Filtrer les réservations pertinentes
    final filteredReservations =
        reservations.where((r) {
          // Vérifier le statut (uniquement CONFIRMER)

          if (![
            ReservationStatus.confirmee,
            ReservationStatus.payee,
            ReservationStatus.finalisee,
          ].contains(r.statut)) {
            return false;
          }

          // Vérifier l'appartement si spécifié
          if (appartementId != null) {
            return r.appart?.id == appartementId;
          }

          // Vérifier la liste d'appartements si spécifiée
          if (appartementIds != null && appartementIds.isNotEmpty) {
            return r.appart?.id != null &&
                appartementIds.contains(r.appart!.id);
          }

          return true;
        }).toList();

    // Transformer en OccupationPeriod
    return filteredReservations
        .where((r) => r.debut != null && r.fin != null && r.appart?.id != null)
        .map(
          (r) => OccupationPeriod(
            appartementId: r.appart!.id!,
            reservationId: r.id,
            startDate: r.debut!,
            endDate: r.fin!,
            appartementName: r.appart?.titre,
          ),
        )
        .toList();
  }
}
