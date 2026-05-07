import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart' as events;
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/theme/app_colors.dart';

class SendMessage extends StatefulWidget {
  const SendMessage({
    super.key,
    this.conversationId,
    this.onMessageSent,
    this.onSend,
  });

  final int? conversationId;
  final VoidCallback? onMessageSent;
  final Function(String)? onSend;

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    if (widget.onSend != null) {
      widget.onSend!(message);
      _controller.clear();
      return;
    }

    if (widget.conversationId == null) return;

    setState(() => _isSending = true);

    context.read<ConversationBloc>().add(
      events.SendMessage(
        conversationId: widget.conversationId!,
        contenu: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is MessageSent &&
            widget.conversationId != null &&
            state.conversationId == widget.conversationId) {
          _controller.clear();
          setState(() => _isSending = false);
          widget.onMessageSent?.call();
        } else if (state is MessageSendError &&
            widget.conversationId != null &&
            state.conversationId == widget.conversationId) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Champ de texte
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Input
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: !_isSending,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Écrire un message...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton envoyer
              _SendButton(
                onPressed: _sendMessage,
                isEnabled: _hasText && !_isSending,
                isSending: _isSending,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton d'envoi animé
class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.onPressed,
    required this.isEnabled,
    required this.isSending,
  });

  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isEnabled || isSending
            ? AppColors.accent
            : AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                : AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isEnabled ? -0.125 : 0, // Légère rotation
                    child: Icon(
                      Icons.send_rounded,
                      color: isEnabled ? AppColors.white : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
