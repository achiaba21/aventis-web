import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card row pleine largeur pour l'écran « Choisir un logement »
/// du démarcheur. Image carrée 88px à gauche, titre + lieu + prix + chip
/// commission accent à droite. Radio indicator en trailing : cercle vide
/// (non sélectionné) ou coche accent (sélectionné).
///
/// Quand sélectionnée + [calendarWidget] fourni : affiche le calendrier
/// de disponibilités en dessous de la row, dans le même conteneur.
class PartnerListingCard extends StatelessWidget {
  final Appartement appartement;
  final int estimatedCommission;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? calendarWidget;

  const PartnerListingCard({
    super.key,
    required this.appartement,
    required this.estimatedCommission,
    this.onTap,
    this.isSelected = false,
    this.calendarWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.line,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: DomainImage(
                      path: appartement.firstPhotoPath,
                      placeholder: ImgPh(tone: appartement.tone, radius: 12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appartement.titleSafe,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${appartement.areaName} · ${FcfaFormatter.compact(appartement.priceAmount)}/n',
                          style: AppTextStyles.small.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (appartement.proprietaire != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 12, color: AppColors.text3),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  appartement.proprietaire!.fullName,
                                  style: AppTextStyles.small.copyWith(
                                    fontSize: 11,
                                    color: AppColors.text3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                  _RadioIndicator(isSelected: isSelected),
                ],
              ),
              if (isSelected && calendarWidget != null) calendarWidget!,
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool isSelected;

  const _RadioIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.text3,
          width: isSelected ? 2 : 1.5,
        ),
      ),
      alignment: Alignment.center,
      // Vrai radio : pastille pleine centrée quand sélectionné (au lieu d'un
      // cercle plein + coche, qui se lisait comme une checkbox/toggle).
      child: isSelected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent,
              ),
            )
          : null,
    );
  }
}
