import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_statut.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/util/calc/charge_status_display.dart';

/// Filtres de statut exposés sur l'écran liste des charges.
enum ChargeStatutFilter {
  tous,
  payee,
  impayee,
  enRetard,
}

/// État des filtres in-memory de l'écran `ChargesListScreen`.
///
/// La liste complète des charges est gérée par `ChargeBloc` — ce cubit ne
/// stocke que les sélections de filtres et fournit le helper `apply()` pour
/// filtrer la liste fournie par le BLoC parent.
class ChargeFilterState {
  final ChargeStatutFilter statut;
  final int? appartementId;
  final TypeCharge? typeCharge;

  /// Période sélectionnée : `month == 0` signifie "toute l'année".
  final int year;
  final int month;

  const ChargeFilterState({
    this.statut = ChargeStatutFilter.tous,
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
      statut != ChargeStatutFilter.tous ||
      appartementId != null ||
      typeCharge != null ||
      month != 0;

  ChargeFilterState copyWith({
    ChargeStatutFilter? statut,
    int? appartementId,
    bool clearAppartement = false,
    TypeCharge? typeCharge,
    bool clearType = false,
    int? year,
    int? month,
  }) {
    return ChargeFilterState(
      statut: statut ?? this.statut,
      appartementId: clearAppartement ? null : (appartementId ?? this.appartementId),
      typeCharge: clearType ? null : (typeCharge ?? this.typeCharge),
      year: year ?? this.year,
      month: month ?? this.month,
    );
  }

  /// Applique les filtres à une liste de charges (in-memory).
  List<Charge> apply(List<Charge> all) {
    return all.where((c) {
      if (!_matchesStatut(c)) return false;
      if (appartementId != null && c.appartementId != appartementId) {
        return false;
      }
      if (typeCharge != null && c.typeCharge != typeCharge) return false;
      if (!_matchesPeriod(c)) return false;
      return true;
    }).toList();
  }

  bool _matchesStatut(Charge c) {
    if (statut == ChargeStatutFilter.tous) return true;
    final cs = ChargeStatusDisplay.statutOf(c);
    switch (statut) {
      case ChargeStatutFilter.payee:
        return cs == ChargeStatut.payee;
      case ChargeStatutFilter.impayee:
        return cs != ChargeStatut.payee;
      case ChargeStatutFilter.enRetard:
        return cs == ChargeStatut.enRetard;
      case ChargeStatutFilter.tous:
        return true;
    }
  }

  bool _matchesPeriod(Charge c) {
    final pivot = c.datePaiement ?? c.dateEcheance;
    if (pivot == null) return true;
    if (pivot.year != year) return false;
    if (month == 0) return true;
    return pivot.month == month;
  }
}

/// Cubit gérant les filtres in-memory de la liste des charges.
class ChargeFilterCubit extends Cubit<ChargeFilterState> {
  ChargeFilterCubit() : super(ChargeFilterState.initial());

  void setStatut(ChargeStatutFilter v) => emit(state.copyWith(statut: v));

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
