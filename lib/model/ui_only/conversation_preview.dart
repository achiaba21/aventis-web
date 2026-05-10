/// Rôle de l'interlocuteur dans une conversation.
///
/// Reproduit le mapping `c.role` du proto `extras.jsx::MessagingList`
/// (lignes 82-96) — utilisé pour afficher le badge à côté du nom.
enum ConversationRole {
  /// Hôte = propriétaire vu côté locataire ou démarcheur.
  host,

  /// Locataire vu côté propriétaire.
  tenant,

  /// Démarcheur vu côté propriétaire.
  demarcheur,

  /// Service Asfar (support officiel).
  asfar,

  /// Client final référé vu côté démarcheur.
  client,
}

/// Modèle UI-only d'une conversation affichée dans `MessagingListScreen`.
///
/// Reproduit la structure des `convosByRole` du proto
/// `extras.jsx::MessagingList` (lignes 80-97). Ne remplace pas le modèle
/// métier `Conversation` (V5 BLoC) — sert uniquement à typer les samples
/// V8 en attendant le branchement BLoC réel.
class ConversationPreview {
  final String id;
  final String who;
  final ConversationRole role;
  final String sub;
  final String lastMessage;
  final String time;
  final int unread;
  final bool certified;

  const ConversationPreview({
    required this.id,
    required this.who,
    required this.role,
    required this.sub,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.certified = false,
  });
}
