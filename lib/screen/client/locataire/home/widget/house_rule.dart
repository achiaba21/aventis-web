import 'package:flutter/material.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class HouseRule extends StatelessWidget {
  const HouseRule({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [TextSeed("Règles"), TextSeed("Pas d'interdiction")],
    );
  }
}
