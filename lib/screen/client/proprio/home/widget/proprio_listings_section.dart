import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/screen/client/proprio/home/widget/proprio_listing_row.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Section « Mes annonces » du dashboard propriétaire.
///
/// SectionHeader + liste compacte de `ProprioListingRow` (ou EmptyState
/// si aucune annonce).
class ProprioListingsSection extends StatelessWidget {
  final List<PropertyPerf> perfs;
  final VoidCallback? onSeeAll;
  final void Function(Appartement appartement)? onListingTap;
  final String title;

  const ProprioListingsSection({
    super.key,
    required this.perfs,
    this.onSeeAll,
    this.onListingTap,
    this.title = 'Mes annonces',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          actionLabel: 'Tout voir',
          onActionTap: onSeeAll,
        ),
        const SizedBox(height: 4),
        if (perfs.isEmpty)
          EmptyState.inline(
            icon: Icons.home_work_outlined,
            title: 'Aucune annonce',
            body: 'Vos annonces apparaîtront ici.',
          )
        else
          for (var i = 0; i < perfs.length; i++) ...[
            ProprioListingRow(
              appartement: perfs[i].appartement,
              occupancyRate: perfs[i].occupancyRate,
              monthlyRevenue: perfs[i].monthlyRevenue,
              onTap: onListingTap == null
                  ? null
                  : () => onListingTap!(perfs[i].appartement),
            ),
            if (i != perfs.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}
