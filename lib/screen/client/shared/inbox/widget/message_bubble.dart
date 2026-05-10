import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bubble texte du `MessagingThreadScreen`.
///
/// Reproduit fidèlement le proto `extras.jsx::MessagingThread`
/// (lignes 247-263) : maxWidth 78%, padding 10×14, accent or si `me` /
/// bgElev2 sinon, radius 18 sur 3 coins + 6 sur le coin opposé à la queue
/// (bottomRight 6 si `me`, bottomLeft 6 sinon), heure 10px en bas opacity 0.6.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? AppColors.accent : AppColors.bgElev2,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 6),
              bottomRight: Radius.circular(isMe ? 6 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text ?? '',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isMe ? AppColors.onAccent : AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: TextStyle(
                  fontSize: 10,
                  color: (isMe ? AppColors.onAccent : AppColors.text)
                      .withValues(alpha: 0.6),
                ),
                textAlign: isMe ? TextAlign.right : TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
