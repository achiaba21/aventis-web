import 'package:flutter/material.dart';
import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/shared/inbox/widget/accepted_partenariat_message_card.dart';
import 'package:asfar/screen/client/shared/inbox/widget/chat_message_display.dart';
import 'package:asfar/screen/client/shared/inbox/widget/message_bubble.dart';
import 'package:asfar/screen/client/shared/inbox/widget/reservation_message_card.dart';

/// Dispatcher d'un message dans la liste du `MessagingThreadScreen` —
/// rend `MessageBubble`, `ReservationMessageCard` ou
/// `AcceptedPartenariatMessageCard` selon `message.kind`. Fallback bubble si
/// le payload spécial est absent.
class ThreadMessageItem extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final void Function(Reservation? loaded)? onReservationTap;
  final void Function(DemandePartenariat? loaded)? onPartenariatTap;

  const ThreadMessageItem({
    super.key,
    required this.message,
    required this.isMe,
    this.onReservationTap,
    this.onPartenariatTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (message.kind) {
      case MessageKind.text:
        return MessageBubble(message: message, isMe: isMe);
      case MessageKind.reservationCard:
        final payload = message.reservationPayload;
        if (payload == null) {
          return MessageBubble(message: message, isMe: isMe);
        }
        return ReservationMessageCard(
          payload: payload,
          onTap: onReservationTap,
        );
      case MessageKind.acceptedPartenariatCard:
        final payload = message.acceptedPartenariatPayload;
        if (payload == null) {
          return MessageBubble(message: message, isMe: isMe);
        }
        return AcceptedPartenariatMessageCard(
          payload: payload,
          onTap: onPartenariatTap,
        );
    }
  }
}
