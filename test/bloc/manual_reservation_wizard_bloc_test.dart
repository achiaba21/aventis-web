import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_bloc.dart';
import 'package:asfar/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/model/residence/appart.dart';

Appartement _appart() {
  return Appartement(id: 1, titre: 'Loft Plateau', prix: 50000);
}

void main() {
  group('ManualReservationWizardBloc — Init + UpdateField', () {
    test('Init avec appart → state.appartement set', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.appartement?.id, 1);
      expect(bloc.state.currentStep, 1);
      await bloc.close();
    });

    test('UpdateField debut + fin → nbNuits calculé', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(UpdateWizardField('debut', DateTime(2026, 5, 15)));
      bloc.add(UpdateWizardField('fin', DateTime(2026, 5, 18)));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.nbNuits, 3);
      expect(bloc.state.totalClient, 150000);
      await bloc.close();
    });

    test('Changement de source vers clientDirect → champs apporteur effacés',
        () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Set apporteur externe + champs associés
      bloc.add(UpdateWizardField(
          'source', ReservationManuelleSource.apporteurExterne));
      bloc.add(UpdateWizardField('apporteurNom', 'Mamadou Cissé'));
      bloc.add(UpdateWizardField('apporteurTelephone', '+22507000000'));
      bloc.add(UpdateWizardField('montantCommission', 7500.0));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.apporteurNom, 'Mamadou Cissé');
      expect(bloc.state.montantCommission, 7500.0);

      // Switch vers client direct → champs effacés
      bloc.add(UpdateWizardField(
          'source', ReservationManuelleSource.clientDirect));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.source, ReservationManuelleSource.clientDirect);
      expect(bloc.state.apporteurNom, isNull);
      expect(bloc.state.apporteurTelephone, isNull);
      expect(bloc.state.montantCommission, isNull);
      await bloc.close();
    });
  });

  group('ManualReservationWizardBloc — NextStep validation', () {
    test('Step 1 sans dates → errors, pas d\'avance', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(NextWizardStep());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.currentStep, 1); // pas avancé
      expect(bloc.state.errors, isNotEmpty);
      await bloc.close();
    });

    test('Step 1 avec dates valides → avance à step 2', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(UpdateWizardField('debut', DateTime(2026, 5, 15)));
      bloc.add(UpdateWizardField('fin', DateTime(2026, 5, 18)));
      bloc.add(NextWizardStep());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.currentStep, 2);
      expect(bloc.state.errors, isEmpty);
      await bloc.close();
    });

    test('Step 2 sans nom/tel → errors', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      bloc.add(UpdateWizardField('debut', DateTime(2026, 5, 15)));
      bloc.add(UpdateWizardField('fin', DateTime(2026, 5, 18)));
      bloc.add(NextWizardStep()); // to step 2
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(NextWizardStep()); // tente avancer sans data
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.currentStep, 2);
      expect(bloc.state.errors['nom'], isNotNull);
      expect(bloc.state.errors['telephone'], isNotNull);
      expect(bloc.state.errors['source'], isNotNull);
      expect(bloc.state.errors['moyenPaiement'], isNotNull);
      await bloc.close();
    });
  });

  group('ManualReservationWizardBloc — totaux', () {
    test('Source clientDirect → pas de commission, recu = total', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      bloc.add(UpdateWizardField('debut', DateTime(2026, 5, 15)));
      bloc.add(UpdateWizardField('fin', DateTime(2026, 5, 17)));
      bloc.add(UpdateWizardField(
          'source', ReservationManuelleSource.clientDirect));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.totalClient, 100000);
      expect(bloc.state.totalRecuProprio, 100000);
      await bloc.close();
    });

    test('Source apporteur externe + commission 10000 → recu = total - 10000',
        () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      bloc.add(UpdateWizardField('debut', DateTime(2026, 5, 15)));
      bloc.add(UpdateWizardField('fin', DateTime(2026, 5, 17)));
      bloc.add(UpdateWizardField(
          'source', ReservationManuelleSource.apporteurExterne));
      bloc.add(UpdateWizardField('montantCommission', 10000.0));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.totalClient, 100000);
      expect(bloc.state.totalRecuProprio, 90000);
      await bloc.close();
    });
  });

  group('ManualReservationWizardBloc — PrevStep', () {
    test('Step 2 → Prev → Step 1', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(InitManualReservationWizard(appartement: _appart()));
      bloc.add(UpdateWizardField('debut', DateTime(2026, 5, 15)));
      bloc.add(UpdateWizardField('fin', DateTime(2026, 5, 18)));
      bloc.add(NextWizardStep());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.currentStep, 2);

      bloc.add(PrevWizardStep());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.currentStep, 1);
      await bloc.close();
    });
  });

  group('ManualReservationWizardBloc — ReservationCreatedSuccess', () {
    test('Success → currentStep=3, isPublishing=false', () async {
      final bloc = ManualReservationWizardBloc(reservationBloc: ReservationBloc());
      bloc.add(ReservationCreatedSuccess(null));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.state.currentStep, 3);
      expect(bloc.state.isPublishing, isFalse);
      await bloc.close();
    });
  });
}
