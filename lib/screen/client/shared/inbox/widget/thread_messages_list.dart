import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/accepted_referral_card_payload.dart';
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/model/ui_only/reservation_card_payload.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_date_separator.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_message_item.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Liste scrollable des messages du `MessagingThreadScreen` avec
/// séparateur de date en tête. Renvoie un `EmptyState.inline` si la
/// conversation est vide.
class ThreadMessagesList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController? scrollController;
  final void Function(ReservationCardPayload payload)? onReservationTap;
  final void Function(AcceptedReferralCardPayload payload)? onReferralTap;

  const ThreadMessagesList({
    super.key,
    required this.messages,
    this.scrollController,
    this.onReservationTap,
    this.onReferralTap,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: EmptyState.inline(
          icon: Icons.chat_outlined,
          title: 'Démarrez la conversation',
          body: 'Envoyez un premier message pour briser la glace.',
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      itemCount: messages.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, index) {
        if (index == 0) return const ThreadDateSeparator();
        return ThreadMessageItem(
          message: messages[index - 1],
          onReservationTap: onReservationTap,
          onReferralTap: onReferralTap,
        );
      },
    );
  }
}
