import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/document/document_status.dart';
import 'package:asfar/model/document/identity_document.dart';
import 'package:asfar/util/calc/kyc_status_resolver.dart';

IdentityDocument _doc(DocumentStatus status) => IdentityDocument(
      uuid: 'u',
      titre: 'CNI',
      type: 'IMAGE',
      path: 'img/x.jpg',
      status: status,
    );

void main() {
  group('KycStatusResolver', () {
    test('liste vide → none + non vérifié', () {
      expect(KycStatusResolver.resolve(const []), KycGlobalStatus.none);
      expect(KycStatusResolver.isVerified(const []), isFalse);
    });

    test('que EN_ATTENTE / REFUSER → pending + non vérifié', () {
      final docs = [
        _doc(DocumentStatus.enAttente),
        _doc(DocumentStatus.refuser),
      ];
      expect(KycStatusResolver.resolve(docs), KycGlobalStatus.pending);
      expect(KycStatusResolver.isVerified(docs), isFalse);
    });

    test('au moins un VERIFIER → verified + vérifié', () {
      final docs = [
        _doc(DocumentStatus.refuser),
        _doc(DocumentStatus.verifier),
      ];
      expect(KycStatusResolver.resolve(docs), KycGlobalStatus.verified);
      expect(KycStatusResolver.isVerified(docs), isTrue);
    });
  });
}
