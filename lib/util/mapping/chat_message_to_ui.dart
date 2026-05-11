import 'dart:convert';

import 'package:asfar/model/conversation/chat_message.dart' as model;
import 'package:asfar/model/ui_only/accepted_partenariat_card_payload.dart';
import 'package:asfar/model/ui_only/chat_message.dart' as ui;
import 'package:asfar/model/ui_only/reservation_card_payload.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/util/function.dart';

/// Mappe `ChatMessage` (modèle métier persisté) → `ChatMessage` (UI-only)
/// consommé par `MessagingThreadScreen`.
///
/// V9.2 : détection des cards système combinée — `isSystem == true` ET
/// préfixe `[ASFAR_CARD:type]`. Le payload est désormais minimaliste
/// (`{"ref":"ASF-XXX"}` ou `{"id":12}`), parsé via `jsonDecode`. En cas
/// d'erreur de parse, fallback gracieux en `MessageKind.text` pour ne pas
/// casser l'affichage des conversations.
class ChatMessageToUiMapper {
  ChatMessageToUiMapper._();

  static const _reservationPrefix = '[ASFAR_CARD:reservation]';
  static const _partenariatPrefix = '[ASFAR_CARD:partenariat]';

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
    final isSystem = source.isSystem ?? false;
    final kind = _detectKind(contenu, isSystem);

    return ui.ChatMessage(
      id: source.tempId ?? '${source.id ?? 0}',
      sender: isMe ? ui.MessageSender.me : ui.MessageSender.them,
      text: kind == ui.MessageKind.text ? contenu : null,
      time: _formatTime(source.createdAt),
      kind: kind,
      reservation: kind == ui.MessageKind.reservationCard
          ? _parseReservation(contenu)
          : null,
      acceptedPartenariat: kind == ui.MessageKind.acceptedPartenariatCard
          ? _parseAcceptedPartenariat(contenu)
          : null,
    );
  }

  static ui.MessageKind _detectKind(String contenu, bool isSystem) {
    if (!isSystem) return ui.MessageKind.text;
    if (contenu.startsWith(_reservationPrefix)) {
      return ui.MessageKind.reservationCard;
    }
    if (contenu.startsWith(_partenariatPrefix)) {
      return ui.MessageKind.acceptedPartenariatCard;
    }
    return ui.MessageKind.text;
  }

  /// Parse `[ASFAR_CARD:reservation]{"ref":"ASF-7K2N9"}` → `ReservationCardPayload`.
  /// Retourne `null` si parse échoue (fallback text côté caller).
  static ReservationCardPayload? _parseReservation(String contenu) {
    try {
      final jsonStr = contenu.substring(_reservationPrefix.length);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final ref = map['ref'] as String?;
      if (ref == null || ref.isEmpty) return null;
      return ReservationCardPayload(reference: ref);
    } catch (e) {
      deboger('ChatMessageToUiMapper.parseReservation: $e');
      return null;
    }
  }

  /// Parse `[ASFAR_CARD:partenariat]{"id":12}` → `AcceptedPartenariatCardPayload`.
  static AcceptedPartenariatCardPayload? _parseAcceptedPartenariat(
    String contenu,
  ) {
    try {
      final jsonStr = contenu.substring(_partenariatPrefix.length);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final id = map['id'];
      if (id is! int) return null;
      return AcceptedPartenariatCardPayload(demandeId: id);
    } catch (e) {
      deboger('ChatMessageToUiMapper.parsePartenariat: $e');
      return null;
    }
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
