import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/router/router_manage.dart';
import 'package:web_flutter/widget/loader/circular_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Disponibilite extends StatefulWidget {
  static String routeName = "disponibilite";
  const Disponibilite({super.key});

  @override
  State<Disponibilite> createState() => _DisponibiliteState();
}

class _DisponibiliteState extends State<Disponibilite> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(
      Duration(seconds: 2),
      () => mounted ? RouterManage.goToSuccessfulPayement(context) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TextSeed("Disponibilité")),
      body: Padding(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        child: Column(
          children: [
            TextSeed('Demande de disponibilité du proprietaire'),
            TextSeed("Peut prendre un certains temps"),
            Center(child: CircularProgress()),
          ],
        ),
      ),
    );
  }
}
