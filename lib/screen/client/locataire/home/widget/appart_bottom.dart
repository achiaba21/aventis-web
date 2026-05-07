import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/util/price_calculator.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/container/block2.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AppartBottom extends StatelessWidget {
  const AppartBottom({
    super.key,
    this.appartement,
    this.reservation,
    this.validationText,
    this.onPress,
  });
  final Appartement? appartement;
  final void Function()? onPress;
  final Reservation? reservation;
  final String? validationText;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        final req = state.currentReq;
        final plage = reservation?.plage ?? req?.plage;

        // Prix de base
        final prixBase =
            (reservation?.prix ??
                    appartement?.prix ??
                    req?.appartement?.prix ??
                    0)
                .toDouble();
        final nombreJours = plage?.duration.inDays ?? 0;

        // Utiliser DiscountDetails pour tous les calculs
        final discountDetails = DiscountDetails.calculate(
          prixBase,
          appartement?.remises,
          nombreJours,
        );

        final prixParNuit = discountDetails.discountedPrice.toInt();
        final prixBaseInt = prixBase.toInt();
        final hasDiscount = discountDetails.hasDiscount;

        // Formater les prix
        final prixFormate = helpAmountFormate(prixParNuit, decim: false);
        final prixBaseFormate = helpAmountFormate(prixBaseInt, decim: false);

        // Calculer le total et l'économie
        String? prixTotalTexte;
        String? economieTexte;

        if (plage != null && nombreJours > 0) {
          final prixTotal = prixParNuit * nombreJours;
          final prixTotalFormate = helpAmountFormate(prixTotal, decim: false);
          prixTotalTexte = "Total : $prixTotalFormate F";

          // Économie totale si réduction
          if (hasDiscount) {
            final economieTotal =
                (prixBase - discountDetails.discountedPrice) * nombreJours;
            final economieFormate = helpAmountFormate(
              economieTotal.toInt(),
              decim: false,
            );
            economieTexte = "Économisez $economieFormate F";
          }
        }

        final textColor = AppColors.textPrimary;
        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return Block2(
          color: AppColors.textPrimary,
          padding: EdgeInsetsDirectional.only(
            top: 12,
            bottom: bottomPadding,
            start: 12,
            end: 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix par nuit avec prix barré si réduction
                    Row(
                      children: [
                        TextSeed(
                          "$prixFormate F/nuit",
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        if (hasDiscount) ...[
                          Gap(6),
                          Text(
                            "$prixBaseFormate F",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Gap(4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextSeed(
                              "-${discountDetails.percentage.round()}%",
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Prix total (si plage sélectionnée)
                    if (prixTotalTexte != null) ...[
                      Gap(2),
                      TextSeed(
                        prixTotalTexte,
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ],

                    // Économie réalisée (en vert)
                    if (economieTexte != null) ...[
                      Gap(2),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 14,
                          ),
                          Gap(4),
                          TextSeed(
                            economieTexte,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                    ],

                    // Plage de dates
                    if (plage != null) ...[
                      Gap(2),
                      TextSeed(
                        formateRangeTimeShort(plage),
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ],
                  ],
                ),
              ),
              Gap(12),
              PlainButton(
                value: validationText ?? "Réserver",
                onPress: onPress,
              ),
            ],
          ),
        );
      },
    );
  }
}
