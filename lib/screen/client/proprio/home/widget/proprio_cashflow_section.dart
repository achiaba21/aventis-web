import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/cashflow_segment.dart';
import 'package:asfar/screen/client/proprio/home/widget/cashflow_split_card.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Section « Flux financier » du dashboard propriétaire.
///
/// SectionHeader + CashflowSplitCard (ou EmptyState si segments vides).
class ProprioCashflowSection extends StatelessWidget {
  final List<CashflowSegment> segments;
  final VoidCallback? onSeeDetails;
  final String title;

  const ProprioCashflowSection({
    super.key,
    required this.segments,
    this.onSeeDetails,
    this.title = 'Flux financier',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          actionLabel: 'Détails →',
          onActionTap: onSeeDetails,
        ),
        const SizedBox(height: 4),
        if (segments.isEmpty)
          EmptyState.inline(
            icon: Icons.account_balance_outlined,
            title: 'Pas encore de flux',
            body: 'Les revenus du mois apparaîtront ici.',
          )
        else
          CashflowSplitCard(segments: List.from(segments)),
      ],
    );
  }
}
