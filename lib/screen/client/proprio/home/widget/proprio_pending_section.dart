import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pending_request.dart';
import 'package:asfar/screen/client/proprio/home/widget/pending_request_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Section « Demandes en attente » du dashboard propriétaire.
///
/// SectionHeader + liste de `PendingRequestRow` (ou EmptyState si vide) +
/// astuce de bas de section.
class ProprioPendingSection extends StatelessWidget {
  final List<PendingRequest> pending;
  final VoidCallback? onSeeAll;
  final void Function(PendingRequest request)? onPendingTap;

  const ProprioPendingSection({
    super.key,
    required this.pending,
    this.onSeeAll,
    this.onPendingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Demandes en attente',
          actionLabel: 'Voir tout',
          onActionTap: onSeeAll,
        ),
        const SizedBox(height: 4),
        if (pending.isEmpty)
          EmptyState.inline(
            icon: Icons.inbox_outlined,
            title: 'Aucune demande en attente',
            body: 'Les nouvelles demandes de réservation apparaîtront ici.',
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElev1,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < pending.length; i++)
                  PendingRequestRow(
                    request: pending[i],
                    isLast: i == pending.length - 1,
                    onTap: onPendingTap == null
                        ? null
                        : () => onPendingTap!(pending[i]),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'Astuce : répondre vite augmente votre taux d\'acceptation.',
          style: AppTextStyles.small.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
