import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ChargeListSection extends StatelessWidget {
  final List<Charge> charges;
  final Function(Charge) onTap;
  final Function(Charge) onEdit;
  final Function(Charge) onDelete;
  final Function(Charge) onMarkPaid;

  const ChargeListSection({
    super.key,
    required this.charges,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSeed(
              "Détail des charges",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            if (charges.isNotEmpty)
              TextSeed(
                "${charges.length} charge(s)",
                fontSize: 13,
                color: AppColors.textMuted,
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (charges.isEmpty)
          _EmptyChargesView()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: charges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return ChargeListItem(
                charge: charges[index],
                onTap: () => onTap(charges[index]),
                onEdit: () => onEdit(charges[index]),
                onDelete: () => onDelete(charges[index]),
                onMarkPaid: () => onMarkPaid(charges[index]),
              );
            },
          ),
      ],
    );
  }
}

class _EmptyChargesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          TextSeed(
            "Aucune charge enregistrée",
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 8),
          TextSeed(
            "Ajoutez vos premières charges pour suivre votre comptabilité",
            textAlign: TextAlign.center,
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class ChargeListItem extends StatelessWidget {
  final Charge charge;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkPaid;

  const ChargeListItem({
    super.key,
    required this.charge,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkPaid,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = charge.estPaye == true;
    final isLate = charge.estEnRetard;
    final isUpcoming = charge.echeanceProche;

    Color statusColor = AppColors.textMuted;
    if (isPaid) {
      statusColor = AppColors.success;
    } else if (isLate) {
      statusColor = AppColors.error;
    } else if (isUpcoming) {
      statusColor = AppColors.warning;
    }

    return Dismissible(
      key: Key('charge_${charge.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: AppColors.textOnAccent),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: TextSeed("Supprimer ?", fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            content: TextSeed("Supprimer la charge \"${charge.labelComplet}\" ?", color: AppColors.textSecondary),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: TextSeed("Annuler", color: AppColors.textMuted),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: TextSeed("Supprimer", color: AppColors.error),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: isLate || isUpcoming ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icône du type de charge
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextSeed(
                      charge.typeCharge.icon,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Infos de la charge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextSeed(
                                charge.labelComplet,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (isPaid)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextSeed(
                                  "Payé",
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            TextSeed(
                              charge.frequence.label,
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            if (charge.dateEcheance != null) ...[
                              TextSeed(
                                " • ",
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                              TextSeed(
                                formatDateRelative(charge.dateEcheance!),
                                fontSize: 12,
                                color: isLate ? AppColors.error : (isUpcoming ? AppColors.warning : AppColors.textMuted),
                                fontWeight: isLate || isUpcoming ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Montant et actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextSeed(
                        formatMontantCourt(charge.montant ?? 0),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                      const SizedBox(height: 4),
                      if (!isPaid)
                        GestureDetector(
                          onTap: onMarkPaid,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextSeed(
                              "Marquer payé",
                              fontSize: 10,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
