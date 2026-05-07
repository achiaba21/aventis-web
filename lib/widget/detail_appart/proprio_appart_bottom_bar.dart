import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/container/block2.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bottom bar pour propriétaire avec bouton "Éditer"
class ProprioAppartBottomBar extends StatelessWidget {
  const ProprioAppartBottomBar({
    super.key,
    required this.appartement,
    this.onEditPressed,
  });

  final Appartement appartement;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final prixBase = appartement.prix ?? 0;
    final prixFormate = helpAmountFormate(prixBase, decim: false);
    final color = AppColors.background;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 60,
        maxHeight: 100,
      ),
      child: Block2(
        padding: EdgeInsetsDirectional.only(
          top: 12,
          bottom: 12 + bottomPadding,
          start: 8,
          end: 8,
        ),
        child: Row(
          children: [
            // Informations de prix
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSeed(
                    "$prixFormate FCFA / nuit",
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  TextSeed(
                    "Prix de base",
                    color: color,
                    fontSize: 12,
                  ),
                ],
              ),
            ),
            Spacer(),

            // Bouton éditer (inactif pour le moment)
            PlainButton(
              value: "Éditer",
              onPress: onEditPressed,
              // Si onEditPressed est null, le bouton sera désactivé
            ),
          ],
        ),
      ),
    );
  }
}
