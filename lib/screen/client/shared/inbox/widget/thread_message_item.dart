import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/accepted_referral_card_payload.dart';
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/model/ui_only/reservation_card_payload.dart';
import 'package:asfar/screen/client/shared/inbox/widget/accepted_referral_message_card.dart';
import 'package:asfar/screen/client/shared/inbox/widget/message_bubble.dart';
import 'package:asfar/screen/client/shared/inbox/widget/reservation_message_card.dart';

/// Dispatcher d'un message dans la liste du `MessagingThreadScreen` —
/// rend `MessageBubble`, `ReservationMessageCard` ou
/// `AcceptedReferralMessageCard` selon `message.kind`. Fallback bubble si
/// le payload spécial est absent.
class ThreadMessageItem extends StatelessWidget {
  final ChatMessage message;
  final void Function(ReservationCardPayload payload)? onReservationTap;
  final void Function(AcceptedReferralCardPayload payload)? onReferralTap;

  const ThreadMessageItem({
    super.key,
    required this.message,
    this.onReservationTap,
    this.onReferralTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.kind) {
      case MessageKind.text:
        return MessageBubble(message: message);
      case MessageKind.reservationCard:
        final payload = message.reservation;
        if (payload == null) {
          return MessageBubble(message: message);
        }
        return ReservationMessageCard(
          payload: payload,
          onTap: onReservationTap == null
              ? null
              : () => onReservationTap!(payload),
        );
      case MessageKind.acceptedReferralCard:
        final payload = message.acceptedReferral;
        if (payload == null) {
          return MessageBubble(message: message);
        }
        return AcceptedReferralMessageCard(
          payload: payload,
          onTap:
              onReferralTap == null ? null : () => onReferralTap!(payload),
        );
    }
  }
}
