import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_event.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:asfar/service/repository/reservation_repository.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/function.dart';

/// BLoC dédié au cycle de vie d'UNE réservation (page détail).
///
/// Sépare l'état d'un détail (loading/action en cours) du `ReservationBloc`
/// liste. Notifie le BLoC liste après chaque action mutante pour garder les
/// surfaces synchronisées.
class ReservationDetailBloc
    extends Bloc<ReservationDetailEvent, ReservationDetailState> {
  final ReservationRepository _repository = ReservationRepository();
  final ReservationService _service = ReservationService();
  final ReservationBloc _listBloc;

  ReservationDetailBloc({required ReservationBloc listBloc})
      : _listBloc = listBloc,
        super(ReservationDetailInitial()) {
    on<LoadFromObject>(_onLoadFromObject);
    on<LoadByReference>(_onLoadByReference);
    on<RefreshFromApi>(_onRefreshFromApi);
    on<PerformAction>(_onPerformAction);
    on<UpdateFromApi>(_onUpdateFromApi);
  }

  void _onLoadFromObject(
    LoadFromObject event,
    Emitter<ReservationDetailState> emit,
  ) {
    emit(ReservationDetailLoaded(event.reservation, isStale: true));
    final ref = event.reservation.reference;
    if (ref != null && ref.isNotEmpty) {
      add(RefreshFromApi());
    }
  }

  Future<void> _onLoadByReference(
    LoadByReference event,
    Emitter<ReservationDetailState> emit,
  ) async {
    emit(ReservationDetailLoading(reservation: state.reservation));
    try {
      final result = await _repository.getByReference(
        event.reference,
        onApiData: (fresh) => add(UpdateFromApi(fresh)),
      );
      if (result.reservations.isEmpty) {
        emit(ReservationDetailError(
          'Réservation introuvable',
          reservation: state.reservation,
        ));
        return;
      }
      emit(ReservationDetailLoaded(
        result.reservations.first,
        isStale: result.isFromCache,
      ));
    } catch (e) {
      deboger(['[ReservationDetailBloc] LoadByReference: $e']);
      emit(ReservationDetailError(
        'Impossible de charger la réservation',
        reservation: state.reservation,
      ));
    }
  }

  Future<void> _onRefreshFromApi(
    RefreshFromApi event,
    Emitter<ReservationDetailState> emit,
  ) async {
    final ref = state.reservation?.reference;
    if (ref == null || ref.isEmpty) return;
    try {
      final fresh = await _service.getByReference(ref);
      emit(ReservationDetailLoaded(fresh, isStale: false));
    } catch (e) {
      deboger(['[ReservationDetailBloc] RefreshFromApi: $e']);
    }
  }

  void _onUpdateFromApi(
    UpdateFromApi event,
    Emitter<ReservationDetailState> emit,
  ) {
    emit(ReservationDetailLoaded(event.reservation, isStale: false));
  }

  Future<void> _onPerformAction(
    PerformAction event,
    Emitter<ReservationDetailState> emit,
  ) async {
    final current = state.reservation;
    if (current == null) return;
    final ref = current.reference;
    if (ref == null || ref.isEmpty) return;

    emit(ReservationDetailActionInProgress(event.action, reservation: current));

    try {
      await _execute(event, ref);
      emit(ReservationDetailActionSuccess(event.action, reservation: current));
      _notifyListBloc(current);
      add(RefreshFromApi());
    } on CustomException catch (e) {
      emit(ReservationDetailActionError(
        event.action,
        e.message,
        reservation: current,
      ));
    } on DioException catch (e) {
      emit(ReservationDetailActionError(
        event.action,
        e.response?.data?.toString() ?? 'Erreur réseau',
        reservation: current,
      ));
    } catch (e) {
      deboger(['[ReservationDetailBloc] PerformAction: $e']);
      emit(ReservationDetailActionError(
        event.action,
        'Une erreur est survenue',
        reservation: current,
      ));
    }
  }

  Future<void> _execute(PerformAction event, String ref) async {
    switch (event.action) {
      case ReservationDetailAction.cancel:
        await _service.cancelReservation(ref, motif: event.motif);
        return;
      case ReservationDetailAction.pay:
        await _service.payReservation(ref);
        return;
      case ReservationDetailAction.confirm:
        await _service.confirmReservation(ref);
        return;
      case ReservationDetailAction.refuse:
        await _service.refuseReservation(ref, motif: event.motif);
        return;
      case ReservationDetailAction.scanQr:
        final key = event.secretKey;
        if (key == null || key.isEmpty) {
          throw Exception('SecretKey manquant');
        }
        await _service.finalizeReservation(key);
        return;
      case ReservationDetailAction.edit:
        final req = event.editReq;
        if (req == null) throw Exception('Requête d\'édition manquante');
        final updated = await _service.updateManualReservation(ref, req);
        add(UpdateFromApi(updated));
        return;
      case ReservationDetailAction.viewQr:
      case ReservationDetailAction.contact:
        return;
    }
  }

  void _notifyListBloc(Reservation current) {
    final ownerEvents = const {
      ReservationDetailAction.confirm,
      ReservationDetailAction.refuse,
      ReservationDetailAction.scanQr,
      ReservationDetailAction.edit,
    };
    final userEvents = const {
      ReservationDetailAction.pay,
      ReservationDetailAction.cancel,
    };

    final lastAction = state is ReservationDetailActionSuccess
        ? (state as ReservationDetailActionSuccess).action
        : null;

    if (lastAction == null) return;

    if (ownerEvents.contains(lastAction)) {
      _listBloc.add(LoadProprietaireReservations());
    } else if (userEvents.contains(lastAction)) {
      _listBloc.add(LoadUserReservations());
    }
  }
}
