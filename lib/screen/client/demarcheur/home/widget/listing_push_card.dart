import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card 200 px du carrousel « Logements à pousser » du Dashboard démarcheur.
///
/// Consomme directement [Appartement]. Img tone 4:3 + titre + lieu + commission
/// estimée accent or. Design proto `demarcheur.jsx::DemarcheurDashboard`.
class ListingPushCard extends StatelessWidget {
  final Appartement appartement;
  final int estimatedCommission;
  final VoidCallback? onTap;

  const ListingPushCard({
    super.key,
    required this.appartement,
    required this.estimatedCommission,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgElev1,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: DomainImage(
                    path: appartement.firstPhotoPath,
                    placeholder: ImgPh(tone: appartement.tone, radius: 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appartement.titleSafe,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${appartement.areaName} · ${FcfaFormatter.compact(appartement.priceAmount)}/n',
                        style: AppTextStyles.small.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.payments_outlined,
                                size: 12, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              FcfaFormatter.compact(estimatedCommission),
                              style: AppTextStyles.mono(const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
