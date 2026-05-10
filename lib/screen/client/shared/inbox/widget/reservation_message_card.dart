import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/reservation_card_payload.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card spéciale « Réservation » — `MessagingThreadScreen`.
///
/// Reproduit le proto `extras.jsx::MessagingThread` (lignes 224-232) :
/// Container `bgElev1 line lg` maxWidth 82% padding 12 + Row[ImgPh 56×56
/// radius 10 tone listing + Column eyebrow RÉSERVATION + titre 13 w600 +
/// dates 11 small + bookingCode mono 11 w600].
///
/// Tap = SnackBar « Détail réservation disponible prochainement ».
class ReservationMessageCard extends StatelessWidget {
  final ReservationCardPayload payload;
  final VoidCallback? onTap;

  const ReservationMessageCard({
    super.key,
    required this.payload,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.82;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgElev1,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.line, width: 1),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ImgPh(tone: payload.listing.tone, radius: 10),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'RÉSERVATION',
                          style: AppTextStyles.eyebrow.copyWith(fontSize: 9),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          payload.listing.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          payload.dates,
                          style: AppTextStyles.small.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          payload.bookingCode,
                          style: AppTextStyles.mono(const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
