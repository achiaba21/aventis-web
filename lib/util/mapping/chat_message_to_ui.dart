import 'package:asfar/model/conversation/chat_message.dart' as model;
import 'package:asfar/model/ui_only/chat_message.dart' as ui;
import 'package:asfar/model/user/user.dart';

/// Mappe `ChatMessage` (modèle métier persisté) → `ChatMessage` (UI-only V8)
/// consommé par `MessagingThreadScreen`.
///
/// Détection du `MessageKind` : aujourd'hui le BLoC ne porte que des
/// messages texte. La détection de cards spéciales (`reservationCard` /
/// `acceptedReferralCard`) repose sur des préfixes convention sur `contenu` :
/// - `[ASFAR_CARD:reservation]` → futur payload réservation
/// - `[ASFAR_CARD:referral]`    → futur payload référence acceptée
///
/// Tant que le serveur n'émet pas ces préfixes, tous les messages sont
/// rendus en `MessageKind.text`. Le mapper est néanmoins prêt pour quand
/// la fonctionnalité sera livrée côté backend.
class ChatMessageToUiMapper {
  ChatMessageToUiMapper._();

  static const _reservationPrefix = '[ASFAR_CARD:reservation]';
  static const _referralPrefix = '[ASFAR_CARD:referral]';

  static List<ui.ChatMessage> mapMany(
    List<model.ChatMessage> messages, {
    User? currentUser,
  }) {
    return messages
        .map((m) => mapOne(m, currentUser: currentUser))
        .toList(growable: false);
  }

  static ui.ChatMessage mapOne(
    model.ChatMessage source, {
    User? currentUser,
  }) {
    final isMe = currentUser?.id != null &&
        source.expediteur?.id == currentUser!.id;
    final contenu = source.contenu ?? '';
    final kind = _detectKind(contenu);
    return ui.ChatMessage(
      id: source.tempId ?? '${source.id ?? 0}',
      sender: isMe ? ui.MessageSender.me : ui.MessageSender.them,
      text: kind == ui.MessageKind.text ? contenu : null,
      time: _formatTime(source.createdAt),
      kind: kind,
      reservation: null,
      acceptedReferral: null,
    );
  }

  static ui.MessageKind _detectKind(String contenu) {
    if (contenu.startsWith(_reservationPrefix)) {
      return ui.MessageKind.reservationCard;
    }
    if (contenu.startsWith(_referralPrefix)) {
      return ui.MessageKind.acceptedReferralCard;
    }
    return ui.MessageKind.text;
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
