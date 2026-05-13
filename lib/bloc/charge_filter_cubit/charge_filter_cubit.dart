import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';

/// État des filtres in-memory de l'écran `ChargesListScreen`.
///
/// Sémantique post-2026-05-13 : chaque charge en base = un paiement déjà
/// enregistré. Le filtre par statut (payée/impayée/en retard) a été retiré.
///
/// La liste complète des charges est gérée par `ChargeBloc` — ce cubit ne
/// stocke que les sélections de filtres et fournit le helper `apply()` pour
/// filtrer la liste fournie par le BLoC parent.
class ChargeFilterState {
  final int? appartementId;
  final TypeCharge? typeCharge;

  /// Période sélectionnée : `month == 0` signifie "toute l'année".
  final int year;
  final int month;

  const ChargeFilterState({
    this.appartementId,
    this.typeCharge,
    required this.year,
    required this.month,
  });

  factory ChargeFilterState.initial() {
    final now = DateTime.now();
    return ChargeFilterState(year: now.year, month: now.month);
  }

  bool get hasActiveFilters =>
      appartementId != null || typeCharge != null || month != 0;

  ChargeFilterState copyWith({
    int? appartementId,
    bool clearAppartement = false,
    TypeCharge? typeCharge,
    bool clearType = false,
    int? year,
    int? month,
  }) {
    return ChargeFilterState(
      appartementId:
          clearAppartement ? null : (appartementId ?? this.appartementId),
      typeCharge: clearType ? null : (typeCharge ?? this.typeCharge),
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  /// Applique les filtres à une liste de charges (in-memory).
  List<Charge> apply(List<Charge> all) {
    return all.where((c) {
      if (appartementId != null && c.appartementId != appartementId) {
        return false;
      }
      if (typeCharge != null && c.typeCharge != typeCharge) return false;
      if (!_matchesPeriod(c)) return false;
      return true;
    }).toList();
  }

  bool _matchesPeriod(Charge c) {
    final pivot = c.dateDebut ?? c.dateEcheance ?? c.createdAt;
    if (pivot == null) return true;
    if (pivot.year != year) return false;
    if (month == 0) return true;
    return pivot.month == month;
  }
}

/// Cubit gérant les filtres in-memory de la liste des charges.
class ChargeFilterCubit extends Cubit<ChargeFilterState> {
  ChargeFilterCubit() : super(ChargeFilterState.initial());

  void setAppartement(int? id) {
    emit(state.copyWith(
      appartementId: id,
      clearAppartement: id == null,
    ));
  }

  void setType(TypeCharge? t) {
    emit(state.copyWith(typeCharge: t, clearType: t == null));
  }

  void setPeriod({required int year, required int month}) {
    emit(state.copyWith(year: year, month: month));
  }

  void reset() => emit(ChargeFilterState.initial());
}
