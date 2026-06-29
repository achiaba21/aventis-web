import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:asfar/service/repository/reservation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements ReservationRepository {}

class _MockService extends Mock implements ReservationService {}

Reservation _resa(String ref) =>
    Reservation.fromJson({'id': 1, 'reference': ref, 'type': 'PLATEFORME'});

/// Régression du bug « calcul compta proprio vidé après un événement temps
/// réel » : `RefreshReservations` doit recharger la liste du BON rôle via le
/// repository (API→Hive→état), et JAMAIS l'endpoint locataire pour un proprio.
void main() {
  late _MockRepo repo;
  late _MockService service;

  setUp(() {
    repo = _MockRepo();
    service = _MockService();
  });

  ReservationBloc buildBloc() =>
      ReservationBloc(service: service, repository: repo);

  group('ReservationBloc — RefreshReservations route selon le rôle', () {
    test('isProprietaire: true → getProprietaireReservations (jamais user)',
        () async {
      when(() => repo.getProprietaireReservations(forceRefresh: true))
          .thenAnswer((_) async => ReservationResult(
                reservations: [_resa('R-OWNER')],
                isFromCache: false,
              ));

      final bloc = buildBloc();
      bloc.add(RefreshReservations(isProprietaire: true));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state, isA<ReservationLoaded>());
      expect(bloc.state.reservations.single.reference, 'R-OWNER');
      verify(() => repo.getProprietaireReservations(forceRefresh: true))
          .called(1);
      verifyNever(() => repo.getUserReservations(forceRefresh: true));
      await bloc.close();
    });

    test('isProprietaire: false → getUserReservations (jamais owner)',
        () async {
      when(() => repo.getUserReservations(forceRefresh: true))
          .thenAnswer((_) async => ReservationResult(
                reservations: [_resa('R-USER')],
                isFromCache: false,
              ));

      final bloc = buildBloc();
      bloc.add(RefreshReservations());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state, isA<ReservationLoaded>());
      expect(bloc.state.reservations.single.reference, 'R-USER');
      verify(() => repo.getUserReservations(forceRefresh: true)).called(1);
      verifyNever(() => repo.getProprietaireReservations(forceRefresh: true));
      await bloc.close();
    });
  });
}
