import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/document/document_status.dart';
import 'package:asfar/model/document/identity_document.dart';

void main() {
  group('IdentityDocument.fromJson', () {
    test('mappe etats → status pour les 3 valeurs', () {
      expect(
        IdentityDocument.fromJson({'etats': 'EN_ATTENTE'}).status,
        DocumentStatus.enAttente,
      );
      expect(
        IdentityDocument.fromJson({'etats': 'VERIFIER'}).status,
        DocumentStatus.verifier,
      );
      expect(
        IdentityDocument.fromJson({'etats': 'REFUSER'}).status,
        DocumentStatus.refuser,
      );
    });

    test('statut inconnu / null → fallback enAttente', () {
      expect(
        IdentityDocument.fromJson({'etats': 'WTF'}).status,
        DocumentStatus.enAttente,
      );
      expect(
        IdentityDocument.fromJson(const {}).status,
        DocumentStatus.enAttente,
      );
    });

    test('parse champs + type + motif', () {
      final doc = IdentityDocument.fromJson({
        'uuid': 'abc',
        'titre': 'CNI',
        'type': 'IMAGE',
        'etats': 'REFUSER',
        'path': 'img/image/x.jpg',
        'motif': 'Photo floue',
        'createdAt': '2026-05-30T13:24:58',
      });
      expect(doc.uuid, 'abc');
      expect(doc.titre, 'CNI');
      expect(doc.isImage, isTrue);
      expect(doc.motifRefus, 'Photo floue');
      expect(doc.createdAt, isNotNull);
    });

    test('fileUrl préfixe le domaine', () {
      final doc = IdentityDocument.fromJson({
        'path': 'img/image/x.jpg',
        'type': 'IMAGE',
        'etats': 'VERIFIER',
      });
      expect(doc.fileUrl('http://x'), 'http://x/img/image/x.jpg');
    });

    test('type PDF → isImage false', () {
      final doc = IdentityDocument.fromJson({
        'type': 'PDF',
        'etats': 'EN_ATTENTE',
        'path': 'img/pdf/x.pdf',
      });
      expect(doc.isImage, isFalse);
    });
  });
}
