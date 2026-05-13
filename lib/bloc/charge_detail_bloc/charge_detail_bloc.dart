import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_event.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_state.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';
import 'package:asfar/repository/charge_data_manager.dart';
import 'package:asfar/util/function.dart';

/// BLoC dédié au cycle de vie d'UNE charge (page détail).
///
/// Sémantique post-2026-05-13 : chaque charge = un paiement déjà enregistré.
/// Les actions `markPaid` / `markUnpaid` ont été retirées (endpoint backend
/// supprimé). Seules `edit` et `delete` subsistent.
class ChargeDetailBloc extends Bloc<ChargeDetailEvent, ChargeDetailState> {
  final ChargeDataManager _repository = ChargeDataManager();
  final ChargeBloc _listBloc;

  ChargeDetailBloc({required ChargeBloc listBloc})
      : _listBloc = listBloc,
        super(ChargeDetailInitial()) {
    on<LoadCharge>(_onLoadCharge);
    on<UpdateChargeAction>(_onUpdate);
    on<DeleteChargeAction>(_onDelete);
    on<UpdateChargeFromApi>(_onUpdateFromApi);
  }

  void _onLoadCharge(LoadCharge event, Emitter<ChargeDetailState> emit) {
    emit(ChargeDetailLoaded(event.charge));
  }

  void _onUpdateFromApi(
    UpdateChargeFromApi event,
    Emitter<ChargeDetailState> emit,
  ) {
    emit(ChargeDetailLoaded(event.charge));
  }

  Future<void> _onUpdate(
    UpdateChargeAction event,
    Emitter<ChargeDetailState> emit,
  ) async {
    final c = state.charge;
    emit(ChargeDetailActionInProgress(
      ChargeDetailAction.edit,
      charge: c,
    ));
    try {
      final updated = await _repository.updateCharge(event.updated);
      emit(ChargeDetailLoaded(updated));
      emit(ChargeDetailActionSuccess(
        ChargeDetailAction.edit,
        charge: updated,
      ));
      _listBloc.add(RefreshCharges());
    } catch (e) {
      deboger(['[ChargeDetailBloc] Update: $e']);
      emit(ChargeDetailActionError(
        ChargeDetailAction.edit,
        'Échec de la modification',
        charge: c,
      ));
    }
  }

  Future<void> _onDelete(
    DeleteChargeAction event,
    Emitter<ChargeDetailState> emit,
  ) async {
    final c = state.charge;
    if (c == null || c.id == null) return;
    emit(ChargeDetailActionInProgress(
      ChargeDetailAction.delete,
      charge: c,
    ));
    try {
      await _repository.deleteCharge(c.id!);
      emit(ChargeDetailActionSuccess(
        ChargeDetailAction.delete,
        charge: c,
      ));
      _listBloc.add(RefreshCharges());
    } catch (e) {
      deboger(['[ChargeDetailBloc] Delete: $e']);
      emit(ChargeDetailActionError(
        ChargeDetailAction.delete,
        'Échec de la suppression',
        charge: c,
      ));
    }
  }
}
