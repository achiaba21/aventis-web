import 'package:flutter/material.dart';
import 'package:web_flutter/screen/login/login_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed:
              () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => LoginScreen())),
          child: Text("Next"),
        ),
      ),
    );
  }
}
