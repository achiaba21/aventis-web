import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/screen/client/proprio/home/widget/proprio_listing_row.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Section « Mes annonces » du dashboard propriétaire.
///
/// SectionHeader + liste compacte de `ProprioListingRow` (ou EmptyState
/// si aucune annonce).
class ProprioListingsSection extends StatelessWidget {
  final List<PropertyPerf> perfs;
  final VoidCallback? onSeeAll;
  final void Function(ListingPreview listing)? onListingTap;

  const ProprioListingsSection({
    super.key,
    required this.perfs,
    this.onSeeAll,
    this.onListingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Mes annonces',
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
              listing: perfs[i].listing,
              occupancyRate: perfs[i].occupancyRate,
              monthlyRevenue: perfs[i].monthlyRevenue,
              onTap: onListingTap == null
                  ? null
                  : () => onListingTap!(perfs[i].listing),
            ),
            if (i != perfs.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}
