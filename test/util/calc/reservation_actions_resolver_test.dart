import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';
import 'package:asfar/model/reservation/reservation_plateforme.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';

Reservation _r(
  ReservationStatus statut, {
  Reservation? base,
}) {
  final r = base ?? ReservationPlateforme();
  r.statut = statut;
  return r;
}

void main() {
  group('ReservationActionsResolver - Locataire', () {
    test('enAttente → cancel + contact', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.locataire,
        reservation: _r(ReservationStatus.enAttente),
      );
      expect(actions, [
        ReservationDetailAction.cancel,
        ReservationDetailAction.contact,
      ]);
    });

    test('confirmee → pay + cancel + contact', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.locataire,
        reservation: _r(ReservationStatus.confirmee),
      );
      expect(actions, [
        ReservationDetailAction.pay,
        ReservationDetailAction.cancel,
        ReservationDetailAction.contact,
      ]);
    });

    test('payee → viewQr + contact', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.locataire,
        reservation: _r(ReservationStatus.payee),
      );
      expect(actions, [
        ReservationDetailAction.viewQr,
        ReservationDetailAction.contact,
      ]);
    });

    test('finalisee → viewQr + contact', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.locataire,
        reservation: _r(ReservationStatus.finalisee),
      );
      expect(actions, contains(ReservationDetailAction.viewQr));
    });

    test('terminee/refusee/annulee → contact seulement', () {
      for (final s in [
        ReservationStatus.terminee,
        ReservationStatus.refusee,
        ReservationStatus.annulee,
      ]) {
        final actions = ReservationActionsResolver.actionsFor(
          role: ReservationViewerRole.locataire,
          reservation: _r(s),
        );
        expect(actions, [ReservationDetailAction.contact],
            reason: 'statut = $s');
      }
    });
  });

  group('ReservationActionsResolver - Propriétaire (plateforme)', () {
    test('enAttente → confirm + refuse + contact', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.enAttente),
      );
      expect(actions, [
        ReservationDetailAction.confirm,
        ReservationDetailAction.refuse,
        ReservationDetailAction.contact,
      ]);
    });

    test('confirmee → contact seulement', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.confirmee),
      );
      expect(actions, [ReservationDetailAction.contact]);
    });

    test('payee → scanQr + contact', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.payee),
      );
      expect(actions, [
        ReservationDetailAction.scanQr,
        ReservationDetailAction.contact,
      ]);
    });
  });

  group('ReservationActionsResolver - Propriétaire (manuelle)', () {
    test('enAttente manuelle → edit + cancel + contact', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.enAttente, base: ReservationManuelle()),
      );
      expect(actions, [
        ReservationDetailAction.edit,
        ReservationDetailAction.cancel,
        ReservationDetailAction.contact,
      ]);
    });

    test('confirmee manuelle → cancel + contact (édition verrouillée car encaissée)', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.confirmee, base: ReservationManuelle()),
      );
      expect(actions, [
        ReservationDetailAction.cancel,
        ReservationDetailAction.contact,
      ]);
      expect(actions, isNot(contains(ReservationDetailAction.edit)));
    });

    test('payee manuelle → édition verrouillée (RM4)', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.payee, base: ReservationManuelle()),
      );
      expect(actions, isNot(contains(ReservationDetailAction.edit)));
      expect(actions, contains(ReservationDetailAction.scanQr));
    });

    test('finalisee manuelle → édition verrouillée (RM4)', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.finalisee, base: ReservationManuelle()),
      );
      expect(actions, isNot(contains(ReservationDetailAction.edit)));
    });
  });

  group('ReservationActionsResolver - Propriétaire (démarcheur)', () {
    test('enAttente démarcheur → confirm + refuse (pas d\'édition)', () {
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.proprietaire,
        reservation: _r(ReservationStatus.enAttente, base: ReservationDemarcheur()),
      );
      expect(actions, [
        ReservationDetailAction.confirm,
        ReservationDetailAction.refuse,
        ReservationDetailAction.contact,
      ]);
    });
  });

  group('ReservationActionsResolver - Démarcheur (viewer)', () {
    test('quel que soit le statut → contact seulement', () {
      for (final s in ReservationStatus.values) {
        final actions = ReservationActionsResolver.actionsFor(
          role: ReservationViewerRole.demarcheur,
          reservation: _r(s),
        );
        expect(actions, [ReservationDetailAction.contact],
            reason: 'statut = $s');
      }
    });
  });

  group('ReservationActionsResolver - statut null', () {
    test('retourne uniquement contact', () {
      final r = ReservationPlateforme();
      final actions = ReservationActionsResolver.actionsFor(
        role: ReservationViewerRole.locataire,
        reservation: r,
      );
      expect(actions, [ReservationDetailAction.contact]);
    });
  });

  group('ReservationActionsResolver.labelOf', () {
    test('chaque action a un libellé non vide', () {
      for (final a in ReservationDetailAction.values) {
        expect(ReservationActionsResolver.labelOf(a), isNotEmpty);
      }
    });
  });
}
