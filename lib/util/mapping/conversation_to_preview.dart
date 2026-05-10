import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';

/// Mappe `Conversation` (modèle métier) → `ConversationPreview` (UI-only V8).
///
/// Le rôle affiché est calculé depuis le `currentUser` :
/// - si `currentUser` est proprietaire → l'interlocuteur est le locataire
///   (badge `tenant`)
/// - si `currentUser` est locataire    → l'interlocuteur est le proprio
///   (badge `host`)
/// - les rôles `demarcheur`/`asfar`/`client` ne sont pas portés par le modèle
///   métier (Conversation ne stocke que proprio/locataire), donc on retombe
///   sur `host`/`tenant` selon le sens.
class ConversationToPreviewMapper {
  ConversationToPreviewMapper._();

  static List<ConversationPreview> mapMany(
    List<Conversation> conversations, {
    User? currentUser,
  }) {
    return conversations
        .map((c) => mapOne(c, currentUser: currentUser))
        .toList(growable: false);
  }

  static ConversationPreview mapOne(
    Conversation source, {
    User? currentUser,
  }) {
    final other = _otherParty(source, currentUser);
    final role = _roleFor(source, currentUser);
    final last = source.lastMessage;
    return ConversationPreview(
      id: '${source.id ?? 0}',
      who: other?.fullName.trim().isNotEmpty == true
          ? other!.fullName
          : 'Interlocuteur',
      role: role,
      sub: source.bookingId != null
          ? 'Réservation #${source.bookingId}'
          : 'Discussion',
      lastMessage: (last?.contenu?.isNotEmpty == true)
          ? last!.contenu!
          : 'Démarrez la conversation…',
      time: _relativeTime(source.lastUpdated ?? last?.createdAt),
      unread: source.unreadCount ?? 0,
    );
  }

  static User? _otherParty(Conversation c, User? me) {
    if (me == null) return c.proprietaire ?? c.locataire;
    if (me.id != null && c.proprietaire?.id == me.id) return c.locataire;
    if (me.id != null && c.locataire?.id == me.id) return c.proprietaire;
    return c.proprietaire ?? c.locataire;
  }

  static ConversationRole _roleFor(Conversation c, User? me) {
    if (me == null) return ConversationRole.host;
    final myType = (me.type ?? '').toLowerCase();
    if (myType == 'proprietaire') return ConversationRole.tenant;
    if (myType == 'demarcheur') return ConversationRole.host;
    return ConversationRole.host;
  }

  /// Format affiché dans la `ConversationRow` (« 14:30 », « Hier »,
  /// « 3 j. »).
  static String _relativeTime(DateTime? dt) {
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

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
