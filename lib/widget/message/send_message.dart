import 'package:flutter/material.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';

class SendMessage extends StatefulWidget {
  const SendMessage({super.key});

  @override
  State<SendMessage> createState() => _SendMessageState();
}

class _SendMessageState extends State<SendMessage> {
  @override
  Widget build(BuildContext context) {
    return InputField(
      rightIcon: CircleIcon(image: Icons.send,),
      placeHolder: "Envoyer un message",
    );
  }
}