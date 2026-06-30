import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/util/calc/charges_total.dart';
import 'package:flutter_test/flutter_test.dart';

Charge _charge(double? montant) => Charge(montant: montant);

void main() {
  group('ChargesTotal.sum', () {
    test('liste vide → 0', () {
      expect(ChargesTotal.sum([]), 0);
    });

    test('somme les montants', () {
      final list = [_charge(10000), _charge(25000), _charge(5000)];
      expect(ChargesTotal.sum(list), 40000);
    });

    test('les montants nuls comptent pour 0', () {
      final list = [_charge(10000), _charge(null), _charge(5000)];
      expect(ChargesTotal.sum(list), 15000);
    });

    test('arrondit le total', () {
      final list = [_charge(10000.4), _charge(5000.1)];
      expect(ChargesTotal.sum(list), 15001);
    });
  });
}
