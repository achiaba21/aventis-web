import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card_kpi.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Body texte d'une `ListingFullCard` : titre + prix + sub + 3 KPIs inline.
class ListingFullCardBody extends StatelessWidget {
  final Appartement appartement;
  final double occupancyRate;
  final int monthlyRevenue;

  const ListingFullCardBody({
    super.key,
    required this.appartement,
    required this.occupancyRate,
    required this.monthlyRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final occupancyPct = (occupancyRate * 100).round();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appartement.titleSafe,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${FcfaFormatter.compact(appartement.priceAmount)}/n',
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${appartement.areaName} · ${appartement.surfaceM2} m²',
            style: AppTextStyles.small.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ListingFullCardKpi(
                  label: 'OCCUP.',
                  value: '$occupancyPct%',
                ),
              ),
              Expanded(
                child: ListingFullCardKpi(
                  label: 'NOTE',
                  value: appartement.rating.toStringAsFixed(2),
                  withStar: true,
                ),
              ),
              Expanded(
                child: ListingFullCardKpi(
                  label: 'REV. MOIS',
                  value: FcfaFormatter.compact(monthlyRevenue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
