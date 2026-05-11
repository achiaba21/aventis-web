import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/screen/client/shared/inbox/widget/accepted_partenariat_message_card.dart';
import 'package:asfar/screen/client/shared/inbox/widget/message_bubble.dart';
import 'package:asfar/screen/client/shared/inbox/widget/reservation_message_card.dart';

/// Dispatcher d'un message dans la liste du `MessagingThreadScreen` —
/// rend `MessageBubble`, `ReservationMessageCard` ou
/// `AcceptedPartenariatMessageCard` selon `message.kind`. Fallback bubble si
/// le payload spécial est absent.
///
/// V9.2 : signatures de callback portent désormais l'objet chargé lazy
/// (`Reservation?` / `DemandePartenariat?`) au lieu du payload brut — le
/// parent décide quoi pousser selon le résultat du fetch.
class ThreadMessageItem extends StatelessWidget {
  final ChatMessage message;
  final void Function(Reservation? loaded)? onReservationTap;
  final void Function(DemandePartenariat? loaded)? onPartenariatTap;

  const ThreadMessageItem({
    super.key,
    required this.message,
    this.onReservationTap,
    this.onPartenariatTap,
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
          onTap: onReservationTap,
        );
      case MessageKind.acceptedPartenariatCard:
        final payload = message.acceptedPartenariat;
        if (payload == null) {
          return MessageBubble(message: message);
        }
        return AcceptedPartenariatMessageCard(
          payload: payload,
          onTap: onPartenariatTap,
        );
    }
  }
}
