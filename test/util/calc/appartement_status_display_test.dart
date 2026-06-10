import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/util/calc/appartement_status_display.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppartementStatusDisplay.badgeTone', () {
    test('EN_COURS → warn', () {
      expect(AppartementStatusDisplay.badgeTone(AppartementStatus.EN_COURS),
          BadgeTone.warn);
    });

    test('EN_LIGNE → success', () {
      expect(AppartementStatusDisplay.badgeTone(AppartementStatus.EN_LIGNE),
          BadgeTone.success);
    });

    test('HORS_LIGNE → neutral (retrait volontaire proprio)', () {
      expect(AppartementStatusDisplay.badgeTone(AppartementStatus.HORS_LIGNE),
          BadgeTone.neutral);
    });

    test('REFUSER → danger', () {
      expect(AppartementStatusDisplay.badgeTone(AppartementStatus.REFUSER),
          BadgeTone.danger);
    });

    test('null → neutral', () {
      expect(AppartementStatusDisplay.badgeTone(null), BadgeTone.neutral);
    });
  });

  group('AppartementStatusDisplay.badgeLabel', () {
    test('libellés neutres par statut', () {
      expect(AppartementStatusDisplay.badgeLabel(AppartementStatus.EN_COURS),
          '● En validation');
      expect(AppartementStatusDisplay.badgeLabel(AppartementStatus.EN_LIGNE),
          '● En ligne');
      expect(AppartementStatusDisplay.badgeLabel(AppartementStatus.HORS_LIGNE),
          '● Hors ligne');
      expect(AppartementStatusDisplay.badgeLabel(AppartementStatus.REFUSER),
          '● Refusée');
      expect(AppartementStatusDisplay.badgeLabel(null), '● Annonce');
    });
  });

  group('AppartementStatusDisplay.eyebrowLabel', () {
    test('libellés eyebrow par statut', () {
      expect(AppartementStatusDisplay.eyebrowLabel(AppartementStatus.EN_COURS),
          'EN COURS DE VALIDATION');
      expect(AppartementStatusDisplay.eyebrowLabel(AppartementStatus.EN_LIGNE),
          'ANNONCE EN LIGNE');
      expect(
          AppartementStatusDisplay.eyebrowLabel(AppartementStatus.HORS_LIGNE),
          'ANNONCE HORS LIGNE');
      expect(AppartementStatusDisplay.eyebrowLabel(AppartementStatus.REFUSER),
          'ANNONCE REFUSÉE');
      expect(AppartementStatusDisplay.eyebrowLabel(null), 'ANNONCE');
    });
  });
}
