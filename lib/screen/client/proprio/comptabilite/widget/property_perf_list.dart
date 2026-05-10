import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/property_perf_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Card "Performance par bien" du `ProprioFinancesScreen`.
///
/// Liste verticale de `PropertyPerfRow` (ou `EmptyState.inline` si aucun
/// bien analysable).
class PropertyPerfList extends StatelessWidget {
  final List<PropertyPerf> perfs;

  const PropertyPerfList({super.key, required this.perfs});

  @override
  Widget build(BuildContext context) {
    if (perfs.isEmpty) {
      return EmptyState.inline(
        icon: Icons.home_work_outlined,
        title: 'Aucun bien à analyser',
        body: 'Vos performances par bien apparaîtront ici.',
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < perfs.length; i++)
            PropertyPerfRow(
              perf: perfs[i],
              isLast: i == perfs.length - 1,
            ),
        ],
      ),
    );
  }
}
