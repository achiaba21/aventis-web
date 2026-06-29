import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/inbox/widget/chat_send_button.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/blur_container.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Barre de saisie sticky bottom du `MessagingThreadScreen`.
///
/// Reproduit le proto `extras.jsx::MessagingThread` (lignes 270-285) :
/// borderTop `line`, padding `10×14×30` (bottom = safe area iOS),
/// Row[IconBoutton plus + InputField flex 1 + ChatSendButton].
class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onPlusTap;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onPlusTap,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() => _canSend = canSend);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlurContainer(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.onPlusTap != null) ...[
                  IconBoutton(
                    icon: Icons.add,
                    onPressed: widget.onPlusTap,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: InputField(
                    controller: _controller,
                    hintText: 'Message…',
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 10),
                ChatSendButton(
                  enabled: _canSend,
                  onTap: _handleSend,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
