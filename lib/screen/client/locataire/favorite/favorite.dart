import 'package:flutter/material.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Favorite extends StatelessWidget {
  static final String routeName = "/favoris";

  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: TextSeed("Favorite"));
  }
}
