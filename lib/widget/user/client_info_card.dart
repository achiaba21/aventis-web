import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/sensitive/sensitive_data_placeholder.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget qui affiche les informations détaillées du client/locataire
/// Gère le cas où les données sont masquées (réservation non payée)
class ClientInfoCard extends StatelessWidget {
  const ClientInfoCard({
    super.key,
    this.client,
    this.showMaskedPlaceholder = true,
  });

  final Locataire? client;

  /// Si true, affiche un placeholder quand les infos sont masquées
  /// Si false, affiche juste "Client" comme avant
  final bool showMaskedPlaceholder;

  @override
  Widget build(BuildContext context) {
    // Vérifier si les infos sensibles sont disponibles
    final hasInfo = client?.hasSensitiveInfo ?? false;

    // Si pas d'infos sensibles et qu'on doit afficher le placeholder
    if (!hasInfo && showMaskedPlaceholder) {
      return SensitiveDataPlaceholder.locataireAttente();
    }

    // Afficher les infos du client
    return _buildClientInfo();
  }

  Widget _buildClientInfo() {
    final displayName = (client?.hasSensitiveInfo ?? false)
        ? client!.fullName
        : "Client";

    return Row(
      children: [
        // Photo du client
        ImageNet(
          client?.imgUrl,
          size: 60,
          radius: 30,
        ),
        Gap(Espacement.gapSection),

        // Informations du client
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                displayName,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              if (client?.hasPhoneInfo ?? false) ...[
                Gap(Espacement.gapItem / 2),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    Gap(Espacement.gapItem / 2),
                    TextSeed(
                      client!.telephone!,
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
              if (client?.email != null && client!.email!.isNotEmpty) ...[
                Gap(Espacement.gapItem / 2),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    Gap(Espacement.gapItem / 2),
                    Expanded(
                      child: Text(
                        client!.email!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
