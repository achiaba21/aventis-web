import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/screen/client/shared/partenariats/widget/partenariat_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card list verticale des `PartenariatRow` du `PartenariatsScreen`.
class PartenariatsListCard extends StatelessWidget {
  final List<DemandePartenariat> demandes;
  final bool isOwnerView;
  final void Function(DemandePartenariat d)? onAccept;
  final void Function(DemandePartenariat d)? onRefuse;

  const PartenariatsListCard({
    super.key,
    required this.demandes,
    this.isOwnerView = false,
    this.onAccept,
    this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < demandes.length; i++)
            PartenariatRow(
              demande: demandes[i],
              isLast: i == demandes.length - 1,
              isOwnerView: isOwnerView,
              onAccept: onAccept == null ? null : () => onAccept!(demandes[i]),
              onRefuse: onRefuse == null ? null : () => onRefuse!(demandes[i]),
            ),
        ],
      ),
    );
  }
}
