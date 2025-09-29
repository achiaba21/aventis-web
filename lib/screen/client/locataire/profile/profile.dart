import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/bloc/user_bloc/user_bloc.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/bloc/user_bloc/user_event.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/profile/account_information.dart';
import 'package:web_flutter/screen/client/locataire/profile/feed.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/client/profil_user.dart';
import 'package:web_flutter/widget/list/list_tile_custom.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Profile extends StatelessWidget {
  static final String routeName = "/profile";

  const Profile({super.key});

  String complet() {
    String asset = "";
    try {
      final isMobile = Platform.isAndroid || Platform.isIOS;
      if (isMobile) {
        asset = "assets/";
      }
    } catch (e) {
      deboger(e);
    }
    return asset;
  }

  @override
  Widget build(BuildContext context) {
    final racine = complet();
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoaded) {
          final client = state.user;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: Espacement.gapItem,
              children: [
                TextSeed("Profile"),
                ProfilUser(client),
                Divider(),
                //Eran money
                Gap(Espacement.gapSection),
                TextSeed("Parametre de compte"),
                Gap(Espacement.gapItem),
                ListTileCustom(
                  texte: "Information",
                  svgPathLeft: "${racine}icon/profil/account.svg",
                  onTap: () => relativePush(context, AccountInformation.routeName),
                ),
                ListTileCustom(texte: "Securité", svgPathLeft: "${racine}icon/profil/security.svg"),
                Gap(Espacement.gapSection),
                TextSeed("Support"),
                Gap(Espacement.gapItem),
                ListTileCustom(texte: "FAQS", svgPathLeft: "${racine}icon/profil/question.svg"),
                ListTileCustom(
                  texte: "Envoyé des avis",
                  svgPathLeft: "${racine}icon/profil/feed.svg",
                  onTap: () => relativePush(context, Feed.routeName),
                ),
                Gap(Espacement.gapSection),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(LogoutUser(client));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Se déconnecter",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Text(
            "Connecté vous pour avoir acces à votre profile",
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
