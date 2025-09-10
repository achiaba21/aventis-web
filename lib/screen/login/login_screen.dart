import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/bloc/user_bloc/user_bloc.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/home/explore.dart';
import 'package:web_flutter/screen/login/login_form.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/custom_button.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/input/input_pass.dart';
import 'package:web_flutter/widget/item/login_social.dart';
import 'package:web_flutter/widget/logo.dart';
import 'package:web_flutter/widget/separate.dart';
import 'package:web_flutter/widget/text/text_seed.dart';
import 'package:web_flutter/widget/text/text_singup.dart';

class LoginScreen extends StatelessWidget {
  static final String routeName = "/login";

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.containerColor3,

      body: BlocConsumer<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return LoginForm();
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
