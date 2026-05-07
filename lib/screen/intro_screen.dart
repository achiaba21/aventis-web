import 'package:asfar/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:asfar/screen/login/login_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: TextButton(
            onPressed: () => pushScreen(context, LoginScreen()),
            child: Text("Next"),
          ),
        ),
      ),
    );
  }
}
