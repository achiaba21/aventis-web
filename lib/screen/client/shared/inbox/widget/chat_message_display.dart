import 'dart:convert';

import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/model/ui_only/accepted_partenariat_card_payload.dart';
import 'package:asfar/model/ui_only/reservation_card_payload.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/util/function.dart';

/// Type d'un message — détermine le rendu visuel.
///
/// Logique de présentation pure : la détection combine `isSystem == true`
/// (côté backend) ET la présence d'un préfixe `[ASFAR_CARD:type]` au début
/// du contenu. En cas d'erreur de parse, fallback gracieux en `text`.
enum MessageKind {
  /// Bubble texte standard.
  text,

  /// Card spéciale « Réservation » (proto `extras.jsx:223-232`).
  reservationCard,

  /// Card spéciale « Demande de partenariat acceptée » — V9.2.
  acceptedPartenariatCard,
}

const _reservationPrefix = '[ASFAR_CARD:reservation]';
const _partenariatPrefix = '[ASFAR_CARD:partenariat]';

/// Extension de présentation sur `ChatMessage` pour le thread inbox —
/// usage UI uniquement.
extension ChatMessageDisplay on ChatMessage {
  /// Détecte le type de rendu (text vs card système).
  MessageKind get kind {
    if (!(isSystem ?? false)) return MessageKind.text;
    final c = contenu ?? '';
    if (c.startsWith(_reservationPrefix)) return MessageKind.reservationCard;
    if (c.startsWith(_partenariatPrefix)) {
      return MessageKind.acceptedPartenariatCard;
    }
    return MessageKind.text;
  }

  /// Le message est-il envoyé par [me] ?
  bool isMineFor(User? me) {
    if (me?.id == null) return false;
    return expediteur?.id == me!.id;
  }

  /// Texte à afficher dans une bubble (null si c'est une card système).
  String? get bubbleText {
    if (kind == MessageKind.text) return contenu ?? '';
    return null;
  }

  /// Format `HH:MM` pour l'horodatage de bubble.
  String get timeLabel {
    final dt = createdAt;
    if (dt == null) return '';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  /// Identifiant stable pour les widgets `key` (tempId pour les optimistic
  /// sends, sinon id serveur).
  String get displayId => tempId ?? '${id ?? 0}';

  /// Parse le payload de card « Réservation » — `null` si parse échoue.
  ReservationCardPayload? get reservationPayload {
    if (kind != MessageKind.reservationCard) return null;
    try {
      final jsonStr = (contenu ?? '').substring(_reservationPrefix.length);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final ref = map['ref'] as String?;
      if (ref == null || ref.isEmpty) return null;
      return ReservationCardPayload(reference: ref);
    } catch (e) {
      deboger('ChatMessage.reservationPayload: $e');
      return null;
    }
  }

  /// Parse le payload de card « Partenariat acceptée » — `null` si échoue.
  AcceptedPartenariatCardPayload? get acceptedPartenariatPayload {
    if (kind != MessageKind.acceptedPartenariatCard) return null;
    try {
      final jsonStr = (contenu ?? '').substring(_partenariatPrefix.length);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      final mid = map['id'];
      if (mid is! int) return null;
      return AcceptedPartenariatCardPayload(demandeId: mid);
    } catch (e) {
      deboger('ChatMessage.acceptedPartenariatPayload: $e');
      return null;
    }
  }
}
