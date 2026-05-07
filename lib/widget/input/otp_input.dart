import 'package:flutter/material.dart';
import 'package:asfar/widget/input/otp_box.dart';

class OtpInput extends StatefulWidget {
  final void Function(String code) onCompleted;
  final bool enabled;

  const OtpInput({
    super.key,
    required this.onCompleted,
    this.enabled = true,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() => _onDigitChanged(i));
    }
  }

  void _onDigitChanged(int index) {
    if (_controllers[index].text.length == 1) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        final code = _controllers.map((c) => c.text).join();
        if (code.length == 4) {
          widget.onCompleted(code);
        }
      }
    }
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: OtpBox(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              onBackspaceOnEmpty: () => _onBackspace(i),
            ),
          ),
        );
      }),
    );
  }
}
