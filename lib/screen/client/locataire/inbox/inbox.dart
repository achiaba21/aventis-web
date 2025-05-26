import 'package:flutter/material.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Inbox extends StatelessWidget {
  static final String routeName = "/inbox";
  const Inbox({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: TextSeed("Inbox"));
  }
}
