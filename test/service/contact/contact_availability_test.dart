import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/contact/contact.dart';
import 'package:asfar/service/contact/contact_availability.dart';

void main() {
  const fullContact = Contact(
    displayName: 'Jean Dupont',
    roleLabel: 'Propriétaire',
    telephone: '+22507123456',
    whatsAppPhone: '+22507000000',
    userId: 42,
  );

  const phoneOnlyContact = Contact(
    displayName: 'Jean Dupont',
    roleLabel: 'Client',
    telephone: '+22507123456',
  );

  const emptyContact = Contact(
    displayName: 'Inconnu',
    roleLabel: 'Client externe',
  );

  group('Démarcheur viewer — toujours actif (statut ignoré)', () {
    test('statut non terminal → dispo selon contact', () {
      final av = ContactAvailability.from(
        contact: fullContact,
        isTerminalStatus: false,
        isDemarcheurViewer: true,
      );
      expect(av.callEnabled, isTrue);
      expect(av.whatsAppEnabled, isTrue);
      expect(av.chatEnabled, isTrue);
      expect(av.contactButtonEnabled, isTrue);
    });

    test('statut terminal → reste actif (ignore statut)', () {
      final av = ContactAvailability.from(
        contact: fullContact,
        isTerminalStatus: true,
        isDemarcheurViewer: true,
      );
      expect(av.callEnabled, isTrue);
      expect(av.whatsAppEnabled, isTrue);
      expect(av.chatEnabled, isTrue);
    });

    test('contact sans phone → call désactivé mais reste démarcheur', () {
      const noPhone = Contact(displayName: 'X', roleLabel: 'Client', userId: 1);
      final av = ContactAvailability.from(
        contact: noPhone,
        isTerminalStatus: true,
        isDemarcheurViewer: true,
      );
      expect(av.callEnabled, isFalse);
      expect(av.whatsAppEnabled, isFalse);
      expect(av.chatEnabled, isTrue);
      expect(av.contactButtonEnabled, isTrue);
    });
  });

  group('Proprio / locataire viewer — désactivé si statut terminal', () {
    test('statut non terminal + contact complet → tout actif', () {
      final av = ContactAvailability.from(
        contact: fullContact,
        isTerminalStatus: false,
        isDemarcheurViewer: false,
      );
      expect(av.callEnabled, isTrue);
      expect(av.whatsAppEnabled, isTrue);
      expect(av.chatEnabled, isTrue);
    });

    test('statut terminal → tout désactivé', () {
      final av = ContactAvailability.from(
        contact: fullContact,
        isTerminalStatus: true,
        isDemarcheurViewer: false,
      );
      expect(av.callEnabled, isFalse);
      expect(av.whatsAppEnabled, isFalse);
      expect(av.chatEnabled, isFalse);
      expect(av.contactButtonEnabled, isFalse);
    });

    test('contact phone-only → call+whatsapp ok, chat ko', () {
      final av = ContactAvailability.from(
        contact: phoneOnlyContact,
        isTerminalStatus: false,
        isDemarcheurViewer: false,
      );
      expect(av.callEnabled, isTrue);
      expect(av.whatsAppEnabled, isTrue); // fallback sur telephone
      expect(av.chatEnabled, isFalse);
      expect(av.contactButtonEnabled, isTrue);
    });

    test('contact sans rien → tout désactivé', () {
      final av = ContactAvailability.from(
        contact: emptyContact,
        isTerminalStatus: false,
        isDemarcheurViewer: false,
      );
      expect(av.callEnabled, isFalse);
      expect(av.whatsAppEnabled, isFalse);
      expect(av.chatEnabled, isFalse);
      expect(av.contactButtonEnabled, isFalse);
    });
  });

  group('contactButtonEnabled — au moins une option suffit', () {
    test('seul chat actif → bouton actif', () {
      const av = ContactAvailability(
        callEnabled: false,
        whatsAppEnabled: false,
        chatEnabled: true,
      );
      expect(av.contactButtonEnabled, isTrue);
    });

    test('seul call actif → bouton actif', () {
      const av = ContactAvailability(
        callEnabled: true,
        whatsAppEnabled: false,
        chatEnabled: false,
      );
      expect(av.contactButtonEnabled, isTrue);
    });

    test('aucun → bouton désactivé', () {
      const av = ContactAvailability.allDisabled();
      expect(av.contactButtonEnabled, isFalse);
    });
  });
}
