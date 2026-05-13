import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card cliquable du logement dans la page détail réservation.
///
/// ImgPh tone 56×56 + Column titre h3 + adresse small text3 + chevron à droite.
class ReservationDetailAppartCard extends StatelessWidget {
  final Appartement? appart;
  final VoidCallback? onTap;

  const ReservationDetailAppartCard({
    super.key,
    required this.appart,
    this.onTap,
  });

  String _address() {
    final a = appart;
    if (a == null) return '';
    final area = a.areaName;
    final city = a.cityName;
    if (area.isNotEmpty && city.isNotEmpty) return '$area, $city';
    if (city.isNotEmpty) return city;
    return area;
  }

  @override
  Widget build(BuildContext context) {
    final tone = appart?.tone ?? 1;
    final title = appart?.titleSafe ?? 'Logement';
    final addr = _address();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            border: Border.all(color: AppColors.line, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: DomainImage(
                  path: appart?.firstPhotoPath,
                  placeholder: ImgPh(tone: tone, radius: AppRadii.sm),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (addr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        addr,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 12,
                          color: AppColors.text3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
