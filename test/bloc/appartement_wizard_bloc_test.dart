import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';

/// Tests focalisés sur `_applyField('typeLocation')` qui doit
/// auto-recalculer `nbChambres` via la `TypeLocationChambresPolicy`.
///
/// On utilise un `AppartementWizardBloc` réel — les helpers
/// (draftStorage, geoService, validator) sont fournis par défaut.
/// Pour les tests qui ne touchent ni Hive ni géoloc, ça suffit.
void main() {
  group('AppartementWizardBloc — _applyField typeLocation', () {
    test('Studio remet nbChambres à 1 (était 5)', () async {
      final bloc = AppartementWizardBloc();
      // Préparer un draft avec nbChambres=5
      bloc.add(UpdateField('nbChambres', 5));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.draft.nbChambres, 5);

      // Changer le type en Studio → doit forcer nbChambres à 1
      bloc.add(UpdateField('typeLocation', AppartementTypeLocation.studio));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.draft.typeLocation, AppartementTypeLocation.studio);
      expect(bloc.state.draft.nbChambres, 1);

      await bloc.close();
    });

    test('3 pièces force nbChambres à 2', () async {
      final bloc = AppartementWizardBloc();
      bloc.add(UpdateField('nbChambres', 5));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(
          UpdateField('typeLocation', AppartementTypeLocation.troisPieces));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.draft.nbChambres, 2);
      await bloc.close();
    });

    test('5+ pièces avec nbChambres=2 force à 4 (min)', () async {
      final bloc = AppartementWizardBloc();
      bloc.add(UpdateField('nbChambres', 2));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(UpdateField('typeLocation', AppartementTypeLocation.cinqPlus));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.draft.typeLocation, AppartementTypeLocation.cinqPlus);
      expect(bloc.state.draft.nbChambres, 4);
      await bloc.close();
    });

    test('5+ pièces avec nbChambres=6 préserve la valeur', () async {
      final bloc = AppartementWizardBloc();
      bloc.add(UpdateField('nbChambres', 6));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(UpdateField('typeLocation', AppartementTypeLocation.cinqPlus));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.draft.nbChambres, 6);
      await bloc.close();
    });

    test('typeLocation = null ne touche pas nbChambres', () async {
      final bloc = AppartementWizardBloc();
      bloc.add(UpdateField('nbChambres', 3));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(UpdateField('typeLocation', null));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.draft.typeLocation, isNull);
      expect(bloc.state.draft.nbChambres, 3);
      await bloc.close();
    });
  });
}
