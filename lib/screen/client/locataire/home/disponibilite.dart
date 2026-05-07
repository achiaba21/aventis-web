import 'dart:async';

import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/locataire/home/success_payement.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/loader/circular_progress.dart';
import 'package:asfar/widget/text/text_seed.dart';

class Disponibilite extends StatefulWidget {
  const Disponibilite({super.key});

  @override
  State<Disponibilite> createState() => _DisponibiliteState();
}

class _DisponibiliteState extends State<Disponibilite> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration(seconds: 2),
      () => mounted ? pushScreenAndReplace(context, SuccessPayement()) : null,
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
