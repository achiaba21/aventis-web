import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_statut.dart';
import 'package:asfar/util/calc/charge_status_display.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

Charge _c({bool? estPaye, DateTime? dateEcheance}) {
  final c = Charge();
  c.estPaye = estPaye;
  c.dateEcheance = dateEcheance;
  return c;
}

void main() {
  group('ChargeStatusDisplay.statutOf', () {
    test('estPaye=true → payee', () {
      expect(
        ChargeStatusDisplay.statutOf(_c(estPaye: true)),
        ChargeStatut.payee,
      );
    });

    test('non payée + échéance passée → enRetard', () {
      final past = DateTime.now().subtract(const Duration(days: 5));
      expect(
        ChargeStatusDisplay.statutOf(_c(estPaye: false, dateEcheance: past)),
        ChargeStatut.enRetard,
      );
    });

    test('non payée + échéance dans 3 jours → echeanceProche', () {
      final near = DateTime.now().add(const Duration(days: 3));
      expect(
        ChargeStatusDisplay.statutOf(_c(estPaye: false, dateEcheance: near)),
        ChargeStatut.echeanceProche,
      );
    });

    test('non payée + échéance dans 30 jours → impayee', () {
      final far = DateTime.now().add(const Duration(days: 30));
      expect(
        ChargeStatusDisplay.statutOf(_c(estPaye: false, dateEcheance: far)),
        ChargeStatut.impayee,
      );
    });

    test('non payée + pas d\'échéance → impayee', () {
      expect(
        ChargeStatusDisplay.statutOf(_c(estPaye: false)),
        ChargeStatut.impayee,
      );
    });

    test('estPaye=true PRIME sur tout (même si échéance passée)', () {
      final past = DateTime.now().subtract(const Duration(days: 10));
      expect(
        ChargeStatusDisplay.statutOf(_c(estPaye: true, dateEcheance: past)),
        ChargeStatut.payee,
      );
    });
  });

  group('ChargeStatusDisplay - mapping exhaustif', () {
    test('chaque statut a un libellé non vide', () {
      for (final s in ChargeStatut.values) {
        expect(ChargeStatusDisplay.labelOf(s), isNotEmpty);
      }
    });

    test('chaque statut a une icône définie', () {
      for (final s in ChargeStatut.values) {
        expect(ChargeStatusDisplay.iconOf(s), isNotNull);
      }
    });

    test('mapping tone : payee=success, enRetard=danger, echeanceProche=warn, impayee=neutral', () {
      expect(ChargeStatusDisplay.toneOf(ChargeStatut.payee), BadgeTone.success);
      expect(ChargeStatusDisplay.toneOf(ChargeStatut.enRetard), BadgeTone.danger);
      expect(ChargeStatusDisplay.toneOf(ChargeStatut.echeanceProche), BadgeTone.warn);
      expect(ChargeStatusDisplay.toneOf(ChargeStatut.impayee), BadgeTone.neutral);
    });
  });
}
