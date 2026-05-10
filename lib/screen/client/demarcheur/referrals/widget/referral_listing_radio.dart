import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/listing_radio_indicator.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card radio de sélection d'un logement — étape 1 du tunnel
/// `NewReferralScreen`.
class ReferralListingRadio extends StatelessWidget {
  final ListingPreview listing;
  final int estimatedCommission;
  final bool selected;
  final VoidCallback? onTap;

  const ReferralListingRadio({
    super.key,
    required this.listing,
    required this.estimatedCommission,
    required this.selected,
    this.onTap,
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
            color: selected ? AppColors.accentSoft : AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: ImgPh(tone: listing.tone, radius: 12),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${listing.area} · ${FcfaFormatter.compact(listing.price)}/n',
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Commission ≈ ${FcfaFormatter.compact(estimatedCommission)}',
                      style: AppTextStyles.mono(const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ListingRadioIndicator(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}
