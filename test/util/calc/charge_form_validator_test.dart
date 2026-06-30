import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/util/calc/charge_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final aujourdHui = DateTime(2026, 6, 30);
  final demain = DateTime(2026, 7, 1);

  group('ChargeFormValidator.validate', () {
    test('cas valide ponctuel → isValid + montant parsé', () {
      final r = ChargeFormValidator.validate(
        appartementId: 1,
        montantText: '25 000',
        dateDebut: aujourdHui,
        dateEcheance: null,
        frequence: FrequenceCharge.ponctuel,
      );
      expect(r.isValid, isTrue);
      expect(r.montantValue, 25000);
    });

    test('appartement manquant', () {
      final r = ChargeFormValidator.validate(
        appartementId: null,
        montantText: '25000',
        dateDebut: aujourdHui,
        dateEcheance: null,
        frequence: FrequenceCharge.mensuel,
      );
      expect(r.isValid, isFalse);
      expect(r.appartement, isNotNull);
    });

    test('montant nul ou non numérique → invalide', () {
      for (final txt in ['', '0', 'abc']) {
        final r = ChargeFormValidator.validate(
          appartementId: 1,
          montantText: txt,
          dateDebut: aujourdHui,
          dateEcheance: null,
          frequence: FrequenceCharge.mensuel,
        );
        expect(r.montant, isNotNull, reason: 'montant "$txt" doit être rejeté');
        expect(r.montantValue, isNull);
      }
    });

    test('date début obligatoire (ponctuel et récurrent)', () {
      final ponctuel = ChargeFormValidator.validate(
        appartementId: 1,
        montantText: '25000',
        dateDebut: null,
        dateEcheance: null,
        frequence: FrequenceCharge.ponctuel,
      );
      expect(ponctuel.date, contains('paiement'));

      final recurrent = ChargeFormValidator.validate(
        appartementId: 1,
        montantText: '25000',
        dateDebut: null,
        dateEcheance: null,
        frequence: FrequenceCharge.mensuel,
      );
      expect(recurrent.date, contains('début'));
    });

    test('échéance avant le début → erreur (récurrent)', () {
      final r = ChargeFormValidator.validate(
        appartementId: 1,
        montantText: '25000',
        dateDebut: demain,
        dateEcheance: aujourdHui,
        frequence: FrequenceCharge.mensuel,
      );
      expect(r.isValid, isFalse);
      expect(r.date, isNotNull);
    });

    test('ordre des dates ignoré pour une charge ponctuelle', () {
      final r = ChargeFormValidator.validate(
        appartementId: 1,
        montantText: '25000',
        dateDebut: demain,
        dateEcheance: aujourdHui,
        frequence: FrequenceCharge.ponctuel,
      );
      expect(r.isValid, isTrue);
    });
  });
}
