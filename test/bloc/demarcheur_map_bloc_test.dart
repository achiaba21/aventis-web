import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_bloc.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_event.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_state.dart';

/// Tests focalisés sur le cycle de vie du BLoC sans réseau.
///
/// Les handlers `_onLoadAppartements` et `_onSearchPlace` font des appels
/// `MapService` réels ; ils sont couverts via des tests d'intégration séparés.
/// Ici on vérifie : état initial, reset, getters, et le chaînage local de
/// `UpdateDemarcheurMapCenter` qui n'a pas de dépendance réseau directe.
void main() {
  group('DemarcheurMapBloc — État initial et reset', () {
    test('état initial = DemarcheurMapInitial', () {
      final bloc = DemarcheurMapBloc();
      expect(bloc.state, isA<DemarcheurMapInitial>());
      expect(bloc.currentCenter, isNull);
      expect(bloc.currentRadius, 10.0);
      bloc.close();
    });

    test('ResetDemarcheurMapState ramène à Initial', () async {
      final bloc = DemarcheurMapBloc();
      bloc.add(const ResetDemarcheurMapState());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state, isA<DemarcheurMapInitial>());
      expect(bloc.currentCenter, isNull);
      expect(bloc.currentRadius, 10.0);
      await bloc.close();
    });
  });

  group('DemarcheurMapBloc — UpdateDemarcheurMapCenter', () {
    test('émet DemarcheurMapCenterUpdated avec le centre fourni', () async {
      final bloc = DemarcheurMapBloc();
      final emittedStates = <DemarcheurMapState>[];
      final sub = bloc.stream.listen(emittedStates.add);

      const newCenter = LatLng(5.345, -4.024);
      bloc.add(const UpdateDemarcheurMapCenter(newCenter));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final centerUpdated = emittedStates.whereType<DemarcheurMapCenterUpdated>();
      expect(centerUpdated, isNotEmpty);
      expect(centerUpdated.first.center, newCenter);
      expect(bloc.currentCenter, newCenter);

      await sub.cancel();
      await bloc.close();
    });
  });

  group('DemarcheurMapBloc — RefreshDemarcheurMap', () {
    test('no-op si aucun centre n\'a été défini auparavant', () async {
      final bloc = DemarcheurMapBloc();
      final initialState = bloc.state;
      bloc.add(const RefreshDemarcheurMap());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Aucun changement d'état attendu (early return du handler).
      expect(bloc.state, initialState);
      await bloc.close();
    });
  });
}
