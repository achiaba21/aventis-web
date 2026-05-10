import 'package:asfar/model/ui_only/conversation_preview.dart';

/// Données mock des conversations par rôle — alignées sur `convosByRole`
/// du proto `extras.jsx::MessagingList` (lignes 80-97).
///
/// Le `MessagingListScreen` lit `user.type` et appelle [forRole] pour
/// charger la bonne liste. Fallback locataire si rôle inconnu (proto:98).
class SampleConversations {
  SampleConversations._();

  static const Map<String, List<ConversationPreview>> _byRole = {
    'locataire': [
      ConversationPreview(
        id: 'L1',
        who: 'Aminata K.',
        role: ConversationRole.host,
        sub: 'Loft Plateau',
        lastMessage: 'Bienvenue ! Le code wifi est…',
        time: '14:32',
        unread: 1,
        certified: true,
      ),
      ConversationPreview(
        id: 'L2',
        who: 'Service Asfar',
        role: ConversationRole.asfar,
        sub: 'Support',
        lastMessage: 'Votre paiement a été reçu ✓',
        time: 'Hier',
      ),
      ConversationPreview(
        id: 'L3',
        who: 'Kofi A.',
        role: ConversationRole.host,
        sub: 'Studio Cocody',
        lastMessage: 'Merci pour votre séjour !',
        time: '12 oct',
      ),
    ],
    'proprietaire': [
      ConversationPreview(
        id: 'P1',
        who: 'Rachid B.',
        role: ConversationRole.tenant,
        sub: 'Loft Plateau · 12-15 nov',
        lastMessage: 'À quelle heure puis-je arriver ?',
        time: '14:32',
        unread: 2,
      ),
      ConversationPreview(
        id: 'P2',
        who: 'Diallo M.',
        role: ConversationRole.demarcheur,
        sub: 'Démarcheur · REF-D8H3K',
        lastMessage: "J'ai un client pour Vue lagune…",
        time: '13:08',
        unread: 1,
      ),
      ConversationPreview(
        id: 'P3',
        who: 'Mariam T.',
        role: ConversationRole.tenant,
        sub: 'Studio Cocody · terminé',
        lastMessage: 'Tout était parfait, merci !',
        time: 'Hier',
      ),
      ConversationPreview(
        id: 'P4',
        who: 'Hassan O.',
        role: ConversationRole.tenant,
        sub: 'Penthouse Almadies',
        lastMessage: 'Le prix est-il négociable ?',
        time: 'Hier',
      ),
    ],
    'demarcheur': [
      ConversationPreview(
        id: 'D1',
        who: 'Aminata K.',
        role: ConversationRole.host,
        sub: 'REF-D8H3K · acceptée',
        lastMessage: 'OK, dis à ton client qu\'il peut payer',
        time: '14:00',
        certified: true,
      ),
      ConversationPreview(
        id: 'D2',
        who: 'Rachid B.',
        role: ConversationRole.client,
        sub: 'Client · Loft Plateau',
        lastMessage: 'Je confirme, j\'envoie le paiement',
        time: '12:15',
        unread: 1,
      ),
      ConversationPreview(
        id: 'D3',
        who: 'M. Konaté',
        role: ConversationRole.host,
        sub: 'Propriétaire · Vue lagune',
        lastMessage: 'Tu peux m\'envoyer plus de clients ?',
        time: 'Hier',
      ),
    ],
  };

  /// Retourne la liste de conversations pour un rôle donné.
  /// Fallback locataire si le rôle est inconnu ou null.
  static List<ConversationPreview> forRole(String? role) {
    final key = (role ?? '').toLowerCase();
    return _byRole[key] ?? _byRole['locataire']!;
  }
}
