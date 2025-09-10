import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/bloc/user_bloc/user_bloc.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/home/explore.dart';
import 'package:web_flutter/screen/signup/widget/signup_form.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/custom_button.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/input/input_pass.dart';
import 'package:web_flutter/widget/logo.dart';
import 'package:web_flutter/widget/text/text_login.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Signup extends StatelessWidget {
  static final String routeName = "/signup";
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.containerColor3,
      body: BlocConsumer<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("image/logo/logo.png"),
                  opacity: 0.1,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Logo(),
                    TextSeed("Signup page"),
                    Gap(Espacement.gapSection),
                    SignupForm(),

                    TextLogin(),
                  ],
                ),
              ),
            ),
          );
        },
        listener: (context, state) {
          if (state is UserLoaded) {
            push(context, Explore.routeName);
          }
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
      ),
    );
  }
}
