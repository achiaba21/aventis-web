import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charge_form_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ChargeDetailScreen extends StatelessWidget {
  final Charge charge;

  const ChargeDetailScreen({super.key, required this.charge});

  @override
  Widget build(BuildContext context) {
    final isPaid = charge.estPaye == true;
    final isLate = charge.estEnRetard;
    final isUpcoming = charge.echeanceProche;

    Color statusColor = AppColors.textMuted;
    String statusLabel = "En attente";
    if (isPaid) {
      statusColor = AppColors.success;
      statusLabel = "Payé";
    } else if (isLate) {
      statusColor = AppColors.error;
      statusLabel = "En retard";
    } else if (isUpcoming) {
      statusColor = AppColors.warning;
      statusLabel = "Échéance proche";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextSeed(
          "Détail de la charge",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          color: AppColors.textPrimary,
        ),
        actions: [
          IconButton(
            onPressed: () => _editCharge(context),
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.accent,
            tooltip: "Modifier",
          ),
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            tooltip: "Supprimer",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône et montant
            _HeaderSection(
              charge: charge,
              statusColor: statusColor,
              statusLabel: statusLabel,
            ),

            const SizedBox(height: 24),

            // Informations principales
            _InfoCard(
              title: "Informations",
              children: [
                _InfoRow(
                  icon: Icons.category_outlined,
                  label: "Type",
                  value: charge.typeCharge.label,
                  trailing: TextSeed(charge.typeCharge.icon, fontSize: 20),
                ),
                if (charge.libelle != null && charge.libelle!.isNotEmpty)
                  _InfoRow(
                    icon: Icons.label_outline,
                    label: "Libellé",
                    value: charge.libelle!,
                  ),
                _InfoRow(
                  icon: Icons.repeat,
                  label: "Fréquence",
                  value: charge.frequence.label,
                ),
                if (charge.estRecurrent == true)
                  _InfoRow(
                    icon: Icons.autorenew,
                    label: "Récurrent",
                    value: "Oui",
                    valueColor: AppColors.accent,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Localisation
            _InfoCard(
              title: "Localisation",
              children: [
                if (charge.residenceNom != null)
                  _InfoRow(
                    icon: Icons.apartment,
                    label: "Résidence",
                    value: charge.residenceNom!,
                  ),
                if (charge.appartementNom != null)
                  _InfoRow(
                    icon: Icons.door_front_door_outlined,
                    label: "Appartement",
                    value: charge.appartementNom!,
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Dates
            _InfoCard(
              title: "Dates",
              children: [
                if (charge.dateDebut != null)
                  _InfoRow(
                    icon: Icons.play_arrow_outlined,
                    label: "Date de début",
                    value: formatDateMonth(charge.dateDebut!),
                  ),
                if (charge.dateEcheance != null)
                  _InfoRow(
                    icon: Icons.event,
                    label: "Échéance",
                    value: formatDateWithStatusDetailed(charge.dateEcheance!, isLate: isLate, isUpcoming: isUpcoming),
                    valueColor: isLate ? AppColors.error : (isUpcoming ? AppColors.warning : null),
                  ),
                if (charge.datePaiement != null)
                  _InfoRow(
                    icon: Icons.check_circle_outline,
                    label: "Date de paiement",
                    value: formatDateMonth(charge.datePaiement!),
                    valueColor: AppColors.success,
                  ),
                if (charge.createdAt != null)
                  _InfoRow(
                    icon: Icons.access_time,
                    label: "Créée le",
                    value: formatDateMonth(charge.createdAt!),
                  ),
              ],
            ),

            // Notes
            if (charge.notes != null && charge.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _InfoCard(
                title: "Notes",
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextSeed(
                      charge.notes!,
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Bouton d'action principal
            if (!isPaid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markAsPaid(context),
                  icon: const Icon(Icons.check, color: AppColors.textOnAccent),
                  label: TextSeed(
                    "Marquer comme payé",
                    color: AppColors.textOnAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (isPaid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    TextSeed(
                      "Cette charge a été payée",
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Bouton modifier
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _editCharge(context),
                icon: Icon(Icons.edit_outlined, color: AppColors.accent),
                label: TextSeed(
                  "Modifier cette charge",
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _editCharge(BuildContext context) {
    pushScreen(context, ChargeFormScreen(chargeToEdit: charge));
  }

  void _markAsPaid(BuildContext context) {
    context.read<ChargeBloc>().add(MarkChargeAsPaid(chargeId: charge.id!));
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: TextSeed(
          "Supprimer la charge ?",
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        content: TextSeed(
          "Cette action est irréversible. La charge \"${charge.labelComplet}\" sera définitivement supprimée.",
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: TextSeed("Annuler", color: AppColors.textMuted),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChargeBloc>().add(DeleteCharge(chargeId: charge.id!));
              Navigator.pop(context);
            },
            child: TextSeed("Supprimer", color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

/// En-tête avec icône, montant et statut
class _HeaderSection extends StatelessWidget {
  final Charge charge;
  final Color statusColor;
  final String statusLabel;

  const _HeaderSection({
    required this.charge,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Icône du type
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextSeed(
              charge.typeCharge.icon,
              fontSize: 36,
            ),
          ),

          const SizedBox(height: 16),

          // Nom de la charge
          TextSeed(
            charge.labelComplet,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Montant
          TextSeed(
            formatMontant(charge.montant ?? 0),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),

          if (charge.frequence != FrequenceCharge.ponctuel) ...[
            const SizedBox(height: 4),
            TextSeed(
              "≈ ${formatMontant(charge.montantMensuel)}/mois",
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ],

          const SizedBox(height: 16),

          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextSeed(
              statusLabel,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'informations
class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(
            title,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Ligne d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  label,
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 2),
                TextSeed(
                  value,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
