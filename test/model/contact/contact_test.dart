import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/model/contact/contact.dart';

void main() {
  group('Contact.hasPhone', () {
    test('true si téléphone non vide', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Propriétaire',
        telephone: '+22507123456',
      );
      expect(c.hasPhone, isTrue);
    });

    test('false si téléphone null', () {
      const c = Contact(displayName: 'Jean', roleLabel: 'Propriétaire');
      expect(c.hasPhone, isFalse);
    });

    test('false si téléphone vide', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Propriétaire',
        telephone: '',
      );
      expect(c.hasPhone, isFalse);
    });

    test('false si téléphone whitespace uniquement', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Propriétaire',
        telephone: '   ',
      );
      expect(c.hasPhone, isFalse);
    });
  });

  group('Contact.hasWhatsApp', () {
    test('true si whatsAppPhone renseigné explicitement', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Client',
        whatsAppPhone: '+22507000000',
      );
      expect(c.hasWhatsApp, isTrue);
    });

    test('fallback sur telephone si whatsAppPhone absent', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Client',
        telephone: '+22507123456',
      );
      expect(c.hasWhatsApp, isTrue);
    });

    test('false si aucun des deux', () {
      const c = Contact(displayName: 'Jean', roleLabel: 'Client');
      expect(c.hasWhatsApp, isFalse);
    });

    test('false si whatsAppPhone vide et telephone vide', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Client',
        whatsAppPhone: '',
        telephone: '',
      );
      expect(c.hasWhatsApp, isFalse);
    });
  });

  group('Contact.canChat', () {
    test('true si userId présent', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Propriétaire',
        userId: 42,
      );
      expect(c.canChat, isTrue);
    });

    test('false si userId null', () {
      const c = Contact(displayName: 'Jean', roleLabel: 'Client externe');
      expect(c.canChat, isFalse);
    });
  });

  group('Contact.effectiveWhatsAppPhone', () {
    test('whatsAppPhone si renseigné', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Client',
        whatsAppPhone: '+22507000000',
        telephone: '+22501234567',
      );
      expect(c.effectiveWhatsAppPhone, '+22507000000');
    });

    test('fallback telephone si whatsAppPhone vide', () {
      const c = Contact(
        displayName: 'Jean',
        roleLabel: 'Client',
        whatsAppPhone: '',
        telephone: '+22501234567',
      );
      expect(c.effectiveWhatsAppPhone, '+22501234567');
    });

    test('null si aucun', () {
      const c = Contact(displayName: 'Jean', roleLabel: 'Client');
      expect(c.effectiveWhatsAppPhone, isNull);
    });
  });
}
