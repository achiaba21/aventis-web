import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/screen/client/shared/inbox/widget/accepted_referral_message_card.dart';
import 'package:asfar/screen/client/shared/inbox/widget/message_bubble.dart';
import 'package:asfar/screen/client/shared/inbox/widget/reservation_message_card.dart';

/// Dispatcher d'un message dans la liste du `MessagingThreadScreen` —
/// rend `MessageBubble`, `ReservationMessageCard` ou
/// `AcceptedReferralMessageCard` selon `message.kind`. Fallback bubble si
/// le payload spécial est absent.
class ThreadMessageItem extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onReservationTap;
  final VoidCallback? onReferralTap;

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
        if (message.reservation == null) {
          return MessageBubble(message: message);
        }
        return ReservationMessageCard(
          payload: message.reservation!,
          onTap: onReservationTap,
        );
      case MessageKind.acceptedReferralCard:
        if (message.acceptedReferral == null) {
          return MessageBubble(message: message);
        }
        return AcceptedReferralMessageCard(
          payload: message.acceptedReferral!,
          onTap: onReferralTap,
        );
    }
  }
}
