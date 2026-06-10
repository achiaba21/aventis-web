import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/calc/listing_status_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Appartement _appart(AppartementStatus? status) => Appartement(status: status);

void main() {
  final list = [
    _appart(AppartementStatus.EN_LIGNE),
    _appart(AppartementStatus.EN_LIGNE),
    _appart(AppartementStatus.EN_COURS),
    _appart(AppartementStatus.HORS_LIGNE),
    _appart(AppartementStatus.REFUSER),
    _appart(null),
  ];

  group('ListingStatusFilter.count', () {
    test('tout compte toutes les annonces', () {
      expect(ListingStatusFilter.count(list, ListingFilter.tout), 6);
    });

    test('compte par statut', () {
      expect(ListingStatusFilter.count(list, ListingFilter.enLigne), 2);
      expect(ListingStatusFilter.count(list, ListingFilter.enValidation), 1);
      expect(ListingStatusFilter.count(list, ListingFilter.horsLigne), 1);
      expect(ListingStatusFilter.count(list, ListingFilter.refusee), 1);
    });
  });

  group('ListingStatusFilter.apply', () {
    test('tout renvoie la liste complète', () {
      expect(ListingStatusFilter.apply(list, ListingFilter.tout).length, 6);
    });

    test('ne garde que les annonces du statut ciblé', () {
      final enLigne = ListingStatusFilter.apply(list, ListingFilter.enLigne);
      expect(enLigne.length, 2);
      expect(enLigne.every((a) => a.status == AppartementStatus.EN_LIGNE),
          isTrue);
    });

    test('renvoie une liste vide si aucun match', () {
      final empty = ListingStatusFilter.apply(
        [_appart(AppartementStatus.EN_LIGNE)],
        ListingFilter.horsLigne,
      );
      expect(empty, isEmpty);
    });
  });

  group('ListingStatusFilter.label / fromLabel', () {
    test('label inclut le compteur', () {
      expect(ListingStatusFilter.label(list, ListingFilter.enLigne),
          'En ligne (2)');
      expect(ListingStatusFilter.label(list, ListingFilter.refusee),
          'Refusée (1)');
      expect(ListingStatusFilter.label(list, ListingFilter.tout), 'Tout (6)');
    });

    test('fromLabel est l\'inverse de label', () {
      for (final f in ListingFilter.values) {
        final label = ListingStatusFilter.label(list, f);
        expect(ListingStatusFilter.fromLabel(list, label), f);
      }
    });

    test('fromLabel retombe sur tout si libellé inconnu', () {
      expect(ListingStatusFilter.fromLabel(list, 'Bidon (9)'),
          ListingFilter.tout);
    });
  });
}
