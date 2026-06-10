import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppartementStatusExtension.fromString', () {
    test('mappe les 4 valeurs backend exactes', () {
      expect(AppartementStatusExtension.fromString('EN_COURS'),
          AppartementStatus.EN_COURS);
      expect(AppartementStatusExtension.fromString('EN_LIGNE'),
          AppartementStatus.EN_LIGNE);
      expect(AppartementStatusExtension.fromString('HORS_LIGNE'),
          AppartementStatus.HORS_LIGNE);
      expect(AppartementStatusExtension.fromString('REFUSER'),
          AppartementStatus.REFUSER);
    });

    test('est insensible à la casse', () {
      expect(AppartementStatusExtension.fromString('en_ligne'),
          AppartementStatus.EN_LIGNE);
      expect(AppartementStatusExtension.fromString('Hors_Ligne'),
          AppartementStatus.HORS_LIGNE);
    });

    test('tolère les espaces parasites', () {
      expect(AppartementStatusExtension.fromString('  EN_COURS  '),
          AppartementStatus.EN_COURS);
    });

    test('retourne null pour null, vide ou valeur inconnue', () {
      expect(AppartementStatusExtension.fromString(null), isNull);
      expect(AppartementStatusExtension.fromString(''), isNull);
      expect(AppartementStatusExtension.fromString('   '), isNull);
      expect(AppartementStatusExtension.fromString('DISPONIBLE'), isNull);
      expect(AppartementStatusExtension.fromString('n_importe_quoi'), isNull);
    });

    test('value renvoie le name (compatible sérialisation backend)', () {
      expect(AppartementStatus.EN_COURS.value, 'EN_COURS');
      expect(AppartementStatus.EN_LIGNE.value, 'EN_LIGNE');
      expect(AppartementStatus.HORS_LIGNE.value, 'HORS_LIGNE');
      expect(AppartementStatus.REFUSER.value, 'REFUSER');
    });
  });
}
