import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_event.dart' as events;
import 'package:web_flutter/bloc/conversation_bloc/conversation_state.dart';

class SendMessage extends StatefulWidget {
  const SendMessage({
    super.key,
    this.conversationId,
    this.onMessageSent,
  });

  final int? conversationId;
  final VoidCallback? onMessageSent;

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty || widget.conversationId == null) return;

    setState(() {
      _isSending = true;
    });

    // Envoyer via ConversationBloc
    context.read<ConversationBloc>().add(
      events.SendMessage(
        conversationId: widget.conversationId!,
        contenu: message,
      ),
    );

    // Vider le champ
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is MessageSent || state is MessageSendError) {
          setState(() {
            _isSending = false;
          });

          if (state is MessageSent) {
            widget.onMessageSent?.call();
          } else if (state is MessageSendError) {
            // Afficher erreur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }
      },
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Envoyer un message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              enabled: !_isSending,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isSending ? Colors.grey : Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}