import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/model/ui_only/property_perf.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Ligne de performance d'un bien — section « Performance par bien » du
/// `ProprioFinancesScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 277-302) : ImgPh 44×44 tone + titre + barre progress 4px (occupation
/// fill accent) + label `${pct}% occupation` + revenus alignés à droite +
/// delta success.
class PropertyPerfRow extends StatelessWidget {
  final PropertyPerf perf;
  final bool isLast;

  const PropertyPerfRow({
    super.key,
    required this.perf,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyPct = (perf.occupancyRate * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.line, width: 1),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: DomainImage(
              path: perf.appartement.firstPhotoPath,
              placeholder: ImgPh(tone: perf.appartement.tone, radius: 10),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perf.appartement.titleSafe,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 4,
                    child: Stack(
                      children: [
                        Container(color: AppColors.bgElev3),
                        FractionallySizedBox(
                          widthFactor: perf.occupancyRate,
                          child: Container(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$occupancyPct% occupation',
                  style: AppTextStyles.small.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FcfaFormatter.compact(perf.monthlyRevenue),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
              const SizedBox(height: 2),
              Text(
                '+${perf.deltaPercent}%',
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
