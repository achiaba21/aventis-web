import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/bloc/user_bloc/user_bloc.dart';
import 'package:web_flutter/bloc/user_bloc/user_event.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/dto/user_req.dart';
import 'package:web_flutter/model/user/user.dart';
import 'package:web_flutter/screen/client/locataire/home/explore.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/custom_button.dart';
import 'package:web_flutter/widget/input/input_date.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/input/input_pass.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserReq();
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                placeHolder: "Ex :07",
                libelle: "Telephone",
                keyboardType: TextInputType.number,
                onChange: (value) => user.telephone = value,
              ),
              Gap(Espacement.gapItem),
              InputField(
                placeHolder: "mail",
                libelle: "Email",
                onChange: (value) => user.email = value,
              ),
              InputField(
                placeHolder: "Ex : Dopo",
                libelle: "Nom",
                onChange: (value) => user.nom = value,
              ),
              InputField(
                placeHolder: "Yan",
                libelle: "Prenom",
                onChange: (value) => user.prenom = value,
              ),
              InputDateField(
                libelle: "Date de naissance",
                onDateSelected: (value) => user.age = value,
              ),
              Gap(Espacement.gapItem),
              InputPass(libelle: "Mot de passe", onchange: (value) => user.password = value),
              Gap(Espacement.gapItem),
              InputPass(
                libelle: "Confirmer mot de passe",
                onchange: (value) => user.confirmPassword = value,
              ),
              Gap(Espacement.gapSection),
              CustomButton(
                text: "Continue",
                onPressed: () {
                  context.read<UserBloc>().add(SignupUser(user));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
