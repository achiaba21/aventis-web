import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_event.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_state.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_item.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/loader/circular_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/config/app_propertie.dart';

class OwnerAppartementsScreen extends StatelessWidget {
  static final routeName = "/owner-appartements";
  const OwnerAppartementsScreen(this.proprietaireId, this.proprietaireNom, {super.key});

  final int proprietaireId;
  final String proprietaireNom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Style.containerColor3,
      appBar: AppBar(
        backgroundColor: Style.containerColor3,
        elevation: 0,
        leading: IconBoutton(
          onPressed: () => back(context),
          icon: Icons.arrow_back,
          size: 18,
          bgColor: Style.containerColor2,
        ),
        title: TextSeed(
          "Appartements de $proprietaireNom",
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<AppartementBloc, AppartementState>(
          listenWhen: (previous, current) => previous is AppartementInitial,
          listener: (context, state) {
            if (state is AppartementInitial) {
              context.read<AppartementBloc>().add(LoadAppartementsByOwner(proprietaireId));
            }
          },
          child: Padding(
            padding: EdgeInsets.all(Espacement.paddingBloc),
            child: BlocBuilder<AppartementBloc, AppartementState>(
              builder: (context, state) {
                if (state is AppartementInitial) {
                  context.read<AppartementBloc>().add(LoadAppartementsByOwner(proprietaireId));
                  return const Center(child: CircularProgress());
                } else if (state is AppartementLoading) {
                  return const Center(child: CircularProgress());
                } else if (state is AppartementsByOwnerLoaded && state.proprietaireId == proprietaireId) {
                  if (state.appartements.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                            SizedBox(height: 24),
                            TextSeed(
                              "Aucun appartement trouvé",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 8),
                            TextSeed(
                              "Ce propriétaire n'a pas d'appartements disponibles actuellement",
                              textAlign: TextAlign.center,
                              color: Colors.grey[600],
                            ),
                            SizedBox(height: 32),
                            PlainButton(
                              value: "Retour",
                              onPress: () => back(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: Espacement.paddingInput),
                          child: TextSeed(
                            "${state.appartements.length} appartement${state.appartements.length > 1 ? 's' : ''} trouvé${state.appartements.length > 1 ? 's' : ''}",
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        ...state.appartements.map((e) => AppartItem(e)),
                      ],
                    ),
                  );
                } else if (state is AppartementError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
                          SizedBox(height: 24),
                          TextSeed(
                            "Erreur de chargement",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(height: 8),
                          TextSeed(
                            state.message,
                            textAlign: TextAlign.center,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 32),
                          PlainButton(
                            value: "Réessayer",
                            onPress: () => context.read<AppartementBloc>().add(LoadAppartementsByOwner(proprietaireId)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgress());
              },
            ),
          ),
        ),
      ),
    );
  }
}