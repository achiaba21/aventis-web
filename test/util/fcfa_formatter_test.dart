import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Test de gel (golden/freeze test) du comportement de [FcfaFormatter].
///
/// FcfaFormatter est l'UNIQUE formateur de montants du projet (PRA-03).
/// Ces tests figent le rendu actuel : toute modification de séparateur,
/// d'arrondi ou de suffixe doit faire échouer ce test volontairement.
///
/// Rappel : le séparateur de milliers est l'espace insécable U+00A0 ;
/// l'espace avant "FCFA" / "M" / "k" est une espace normale U+0020.
void main() {
  // Espace insécable utilisée comme séparateur de milliers.
  const nbsp = ' ';

  group('FcfaFormatter.full', () {
    test('zéro', () {
      expect(FcfaFormatter.full(0), '0 FCFA');
    });

    test('valeurs < 1000 sans séparateur', () {
      expect(FcfaFormatter.full(850), '850 FCFA');
      expect(FcfaFormatter.full(999), '999 FCFA');
    });

    test('milliers groupés par espace insécable', () {
      expect(FcfaFormatter.full(1500), '1${nbsp}500 FCFA');
      expect(FcfaFormatter.full(25000), '25${nbsp}000 FCFA');
    });

    test('millions groupés par espace insécable', () {
      expect(FcfaFormatter.full(1250000), '1${nbsp}250${nbsp}000 FCFA');
      expect(FcfaFormatter.full(1900000), '1${nbsp}900${nbsp}000 FCFA');
    });

    test('négatifs : préfixe minus', () {
      expect(FcfaFormatter.full(-850), '-850 FCFA');
      expect(FcfaFormatter.full(-1500), '-1${nbsp}500 FCFA');
      expect(FcfaFormatter.full(-1250000), '-1${nbsp}250${nbsp}000 FCFA');
    });

    test('décimales arrondies à l\'entier', () {
      expect(FcfaFormatter.full(999.6), '1${nbsp}000 FCFA');
      expect(FcfaFormatter.full(850.4), '850 FCFA');
    });
  });

  group('FcfaFormatter.compact', () {
    test('zéro', () {
      expect(FcfaFormatter.compact(0), '0 FCFA');
    });

    test('valeurs < 1000 affichées telles quelles', () {
      expect(FcfaFormatter.compact(850), '850 FCFA');
      expect(FcfaFormatter.compact(999), '999 FCFA');
    });

    test('milliers : suffixe k, arrondi au millier', () {
      // 1500 / 1000 = 1.5 → .round() = 2 (comportement actuel figé).
      expect(FcfaFormatter.compact(1500), '2 k FCFA');
      expect(FcfaFormatter.compact(25000), '25 k FCFA');
    });

    test('millions : suffixe M, 1 décimale si non rond', () {
      expect(FcfaFormatter.compact(1250000), '1.3 M FCFA');
      expect(FcfaFormatter.compact(1900000), '1.9 M FCFA');
    });

    test('millions ronds : 0 décimale', () {
      expect(FcfaFormatter.compact(2000000), '2 M FCFA');
    });

    test('négatifs : préfixe minus', () {
      expect(FcfaFormatter.compact(-850), '-850 FCFA');
      expect(FcfaFormatter.compact(-1500), '-2 k FCFA');
      expect(FcfaFormatter.compact(-1900000), '-1.9 M FCFA');
    });
  });

  group('FcfaFormatter.groupThousands', () {
    test('zéro et valeurs < 1000', () {
      expect(FcfaFormatter.groupThousands(0), '0');
      expect(FcfaFormatter.groupThousands(850), '850');
      expect(FcfaFormatter.groupThousands(999), '999');
    });

    test('groupes de 3 séparés par espace insécable', () {
      expect(FcfaFormatter.groupThousands(1500), '1${nbsp}500');
      expect(FcfaFormatter.groupThousands(25000), '25${nbsp}000');
      expect(FcfaFormatter.groupThousands(1250000), '1${nbsp}250${nbsp}000');
      expect(FcfaFormatter.groupThousands(1900000), '1${nbsp}900${nbsp}000');
    });

    test('négatifs (comportement actuel figé)', () {
      expect(FcfaFormatter.groupThousands(-1500), '-1${nbsp}500');
      // Quirk connu : le signe est compté dans la longueur, donc un
      // séparateur s'insère après le minus pour 3n chiffres.
      expect(FcfaFormatter.groupThousands(-850), '-${nbsp}850');
    });
  });
}
