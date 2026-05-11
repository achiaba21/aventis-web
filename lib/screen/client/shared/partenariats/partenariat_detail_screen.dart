import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/screen/client/shared/partenariats/widget/partenariat_detail_party_card.dart';
import 'package:asfar/screen/client/shared/partenariats/widget/partenariat_detail_status_section.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran détail d'une demande de partenariat — transverse proprio/démarcheur.
///
/// V9.2 : push depuis `AcceptedPartenariatMessageCard.onTap` quand le user
/// tape sur la card système reçue dans le chat. Affiche le statut, les
/// dates, et les 2 parties (démarcheur + proprio) avec leur téléphone
/// cliquable (`tel:` via `url_launcher`).
class PartenariatDetailScreen extends StatelessWidget {
  final DemandePartenariat demande;

  const PartenariatDetailScreen({
    super.key,
    required this.demande,
  });

  String _nomProprietaire() {
    final prenom = demande.proprietaire['prenom'] as String? ?? '';
    final nom = demande.proprietaire['nom'] as String? ?? '';
    final full = '$prenom $nom'.trim();
    return full.isNotEmpty ? full : 'Propriétaire';
  }

  String _telephoneProprietaire() {
    return demande.proprietaire['telephone'] as String? ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Demande de partenariat',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PartenariatDetailStatusSection(
                statut: demande.statut,
                createdAt: demande.createdAt,
                repondueAt: demande.repondueAt,
              ),
              const SizedBox(height: 24),
              Text('PARTIES', style: AppTextStyles.eyebrow),
              const SizedBox(height: 10),
              PartenariatDetailPartyCard(
                role: 'Démarcheur',
                nom: demande.nomDemarcheur,
                telephone: demande.telephoneDemarcheur,
              ),
              const SizedBox(height: 12),
              PartenariatDetailPartyCard(
                role: 'Propriétaire',
                nom: _nomProprietaire(),
                telephone: _telephoneProprietaire(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
