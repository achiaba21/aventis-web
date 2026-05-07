import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/badge/status_badge.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class AppartementStatusCard extends StatelessWidget {
  const AppartementStatusCard({
    super.key,
    required this.appartement,
    
    required this.onViewDetails,
  });

  final Appartement appartement;
  
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Espacement.gapSection),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(Espacement.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ImageNet(
                appartement.photos?.isNotEmpty == true
                    ? appartement.photos!.first.path ?? ""
                    : "",
                height: 200,
                width: double.infinity,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: StatusBadge(status: "status"),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(Espacement.paddingBloc),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  "${appartement.description ?? ""}",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.background,
                ),
                SizedBox(height: Espacement.gapSection / 2),
                TextSeed(
                  "${appartement.prix ?? 200} / Night",
                  fontSize: 14,
                  color: AppColors.background,
                ),
                SizedBox(height: Espacement.gapSection),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Espacement.radius),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: Espacement.paddingInput,
                        vertical: 8,
                      ),
                    ),
                    child: TextSeed(
                      "View details",
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}