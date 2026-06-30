import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/proprio_reservations_filter_cubit/proprio_reservations_filter_state.dart';
import 'package:asfar/util/calc/reservation_segment.dart';

/// Cubit local à `ProprioReservationsScreen` : pilote le segment actif et le
/// bien filtré.
///
/// Volontairement non global → chaque ouverture de l'écran repart sur
/// « À traiter », ce que le proprio doit voir en priorité.
class ProprioReservationsFilterCubit
    extends Cubit<ProprioReservationsFilterState> {
  ProprioReservationsFilterCubit()
      : super(ProprioReservationsFilterState.initial());

  /// Change le segment actif (À traiter / À venir / Historique).
  void selectSegment(ReservationSegment segment) {
    if (segment == state.segment) return;
    emit(state.copyWith(segment: segment));
  }

  /// Sélectionne un bien (`null` = tous les biens).
  void selectAppartement(int? appartementId) {
    emit(state.copyWith(
      appartementId: appartementId,
      clearAppartement: appartementId == null,
    ));
  }

  /// Réinitialise le filtre à son état par défaut.
  void reset() => emit(ProprioReservationsFilterState.initial());
}
