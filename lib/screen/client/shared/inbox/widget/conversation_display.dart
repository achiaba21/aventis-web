import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/user/user.dart';

/// Rôle de l'interlocuteur dans une conversation — UI uniquement.
///
/// Calculé par `Conversation.roleFor(currentUser)` selon les types des
/// deux parties.
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

/// Extension de présentation sur `Conversation` pour la liste/header inbox.
///
/// Tous les getters dépendent du `currentUser` connecté pour déterminer
/// la « partie opposée » et son rôle.
extension ConversationDisplay on Conversation {
  /// L'autre participant de la conversation par rapport à [me].
  User? otherPartyFor(User? me) {
    if (me == null) return proprietaire ?? locataire;
    if (me.id != null && proprietaire?.id == me.id) return locataire;
    if (me.id != null && locataire?.id == me.id) return proprietaire;
    return proprietaire ?? locataire;
  }

  /// Rôle affiché pour le badge à côté du nom.
  ConversationRole roleFor(User? me) {
    if (me == null) return ConversationRole.host;
    final myType = (me.type ?? '').toLowerCase();
    final other = otherPartyFor(me);
    final otherType = (other?.type ?? '').toLowerCase();

    // Conv mixte proprio↔démarcheur supportée. Le rôle affiché est celui
    // de l'INTERLOCUTEUR.
    if (myType == 'proprietaire') {
      if (otherType == 'demarcheur') return ConversationRole.demarcheur;
      return ConversationRole.tenant;
    }
    if (myType == 'demarcheur') {
      // Démarcheur voit proprio (= host) ou client final.
      return ConversationRole.host;
    }
    return ConversationRole.host;
  }

  /// Nom de l'interlocuteur (fallback « Interlocuteur »).
  String whoFor(User? me) {
    final other = otherPartyFor(me);
    final name = other?.fullName.trim();
    return (name?.isNotEmpty ?? false) ? name! : 'Interlocuteur';
  }

  /// Sous-texte du row (« Réservation #42 » ou « Discussion »).
  String get subLabel =>
      bookingId != null ? 'Réservation #$bookingId' : 'Discussion';

  /// Aperçu du dernier message pour le row.
  String get lastMessagePreviewText {
    final c = lastMessage?.contenu;
    return (c?.isNotEmpty ?? false) ? c! : 'Démarrez la conversation…';
  }

  /// Format affiché dans la `ConversationRow` (« 14:30 », « Hier », « 3 j. »).
  String get timeLabel {
    final dt = lastUpdated ?? lastMessage?.createdAt;
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (_isSameDay(dt, now)) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return '${diff.inDays} j.';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  int get unreadCountSafe => unreadCount ?? 0;

  /// Téléphone de l'interlocuteur (pour le bouton phone du header thread).
  String? phoneFor(User? me) => otherPartyFor(me)?.telephone;
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
