import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/util/chat_message_merger.dart';

ChatMessage _optimistic({
  required String tempId,
  required int senderId,
  required String contenu,
}) {
  return ChatMessage(
    tempId: tempId,
    expediteur: User(id: senderId),
    contenu: contenu,
    conversationId: 1,
    isSending: true,
    isRead: true,
  );
}

ChatMessage _server({
  required int id,
  required int senderId,
  required String contenu,
}) {
  return ChatMessage(
    id: id,
    expediteur: User(id: senderId),
    contenu: contenu,
    conversationId: 1,
    isSending: false,
    isRead: true,
  );
}

void main() {
  group('ChatMessageMerger.upsert', () {
    test('confirmation d\'envoi : remplace l\'optimiste par tempId (1 bulle)',
        () {
      final optimistic = _optimistic(tempId: 'A', senderId: 7, contenu: 'salut');
      final server = _server(id: 42, senderId: 7, contenu: 'salut');

      final result = ChatMessageMerger.upsert([optimistic], server, tempId: 'A');

      expect(result.length, 1);
      expect(result.single.id, 42);
      expect(result.single.isSending, false);
    });

    test('écho APRÈS HTTP : déjà confirmé → mise à jour en place (1 bulle)', () {
      final server = _server(id: 42, senderId: 7, contenu: 'salut');
      final echo = _server(id: 42, senderId: 7, contenu: 'salut');

      final result = ChatMessageMerger.upsert([server], echo);

      expect(result.length, 1);
      expect(result.single.id, 42);
    });

    test('écho AVANT HTTP : réconcilie l\'optimiste puis la confirmation '
        'ne crée pas de doublon (1 bulle)', () {
      final optimistic = _optimistic(tempId: 'A', senderId: 7, contenu: 'salut');
      final echo = _server(id: 42, senderId: 7, contenu: 'salut');

      // L'écho arrive d'abord (ce canal ne connaît pas le tempId).
      final afterEcho = ChatMessageMerger.upsert([optimistic], echo);
      expect(afterEcho.length, 1);
      expect(afterEcho.single.id, 42);

      // Puis la réponse HTTP confirme avec le tempId d'origine.
      final afterHttp = ChatMessageMerger.upsert(afterEcho, echo, tempId: 'A');
      expect(afterHttp.length, 1);
      expect(afterHttp.single.id, 42);
    });

    test('écho dupliqué via plusieurs canaux : idempotent (1 bulle)', () {
      final server = _server(id: 42, senderId: 7, contenu: 'salut');
      final echo = _server(id: 42, senderId: 7, contenu: 'salut');

      var result = ChatMessageMerger.upsert([server], echo);
      result = ChatMessageMerger.upsert(result, echo);
      result = ChatMessageMerger.upsert(result, echo);

      expect(result.length, 1);
    });

    test('course écho-avant-HTTP non réconciliée par contenu : '
        'le doublon de même id est supprimé à la confirmation', () {
      // L'écho s'est ajouté comme bulle distincte (contenu non identique),
      // l'optimiste est toujours présent avec son tempId.
      final optimistic = _optimistic(tempId: 'A', senderId: 7, contenu: 'salut');
      final echo = _server(id: 42, senderId: 7, contenu: 'salut edité');
      final withBoth = [optimistic, echo];

      final server = _server(id: 42, senderId: 7, contenu: 'salut');
      final result = ChatMessageMerger.upsert(withBoth, server, tempId: 'A');

      expect(result.length, 1);
      expect(result.single.id, 42);
    });

    test('échec HTTP puis écho : l\'écho réconcilie l\'optimiste '
        '(message ni perdu ni doublé)', () {
      final optimistic = _optimistic(tempId: 'A', senderId: 7, contenu: 'salut');
      final echo = _server(id: 42, senderId: 7, contenu: 'salut');

      // Le POST a échoué → pas de confirmation par tempId, seul l'écho arrive.
      final result = ChatMessageMerger.upsert([optimistic], echo);

      expect(result.length, 1);
      expect(result.single.id, 42);
      expect(result.single.isSending, false);
    });

    test('message d\'un autre utilisateur : simple ajout', () {
      final mine = _server(id: 42, senderId: 7, contenu: 'salut');
      final other = _server(id: 43, senderId: 9, contenu: 'bonjour');

      final result = ChatMessageMerger.upsert([mine], other);

      expect(result.length, 2);
      expect(result.last.id, 43);
    });

    test('ne réconcilie pas deux optimistes à expéditeur null', () {
      final a = ChatMessage(
        tempId: 'A',
        contenu: 'salut',
        conversationId: 1,
        isSending: true,
      );
      final b = ChatMessage(
        contenu: 'salut',
        conversationId: 1,
        isSending: true,
      );

      final result = ChatMessageMerger.upsert([a], b);

      expect(result.length, 2);
    });

    test('préserve l\'ordre chronologique à la réconciliation', () {
      final older = _server(id: 40, senderId: 9, contenu: 'avant');
      final optimistic = _optimistic(tempId: 'A', senderId: 7, contenu: 'salut');
      final echo = _server(id: 42, senderId: 7, contenu: 'salut');

      final result = ChatMessageMerger.upsert([older, optimistic], echo);

      expect(result.length, 2);
      expect(result.first.id, 40);
      expect(result.last.id, 42);
    });

    test('n\'altère pas la liste d\'entrée (pureté)', () {
      final optimistic = _optimistic(tempId: 'A', senderId: 7, contenu: 'salut');
      final input = [optimistic];
      final server = _server(id: 42, senderId: 7, contenu: 'salut');

      ChatMessageMerger.upsert(input, server, tempId: 'A');

      expect(input.length, 1);
      expect(input.single.id, isNull);
    });
  });
}
