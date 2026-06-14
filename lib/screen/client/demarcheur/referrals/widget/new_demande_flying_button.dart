import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bouton « Nouvelle demande » unique de l'écran des demandes démarcheur.
///
/// Un seul bouton est présent à l'écran : il **vole et morphe** entre le centre
/// (état vide, allure bloc « + Nouvelle demande ») et le coin bas-droite (FAB
/// rond « + », le texte se résorbe) selon [centered], avec une transition de
/// type « hero » rejouée à chaque changement de filtre qui fait basculer la
/// liste vide ↔ non-vide. Remplace l'ancien doublon (FAB permanent + CTA
/// central de l'`EmptyState`).
///
/// Conçu pour être posé en `Positioned.fill` dans le `Stack` du body : il
/// occupe toute la zone et n'intercepte les taps que sur la pastille elle-même.
class NewDemandeFlyingButton extends StatefulWidget {
  /// Hauteur de la bande basse à réserver sous la liste lorsque le bouton est
  /// en FAB (coin bas-droite). La liste est paddée de cette valeur pour que son
  /// viewport s'arrête au-dessus du FAB — ainsi aucun item ne défile derrière
  /// lui. Footprint FAB (56) + marge bas (16) + respiration (8).
  static const double dockedStripHeight = 80;

  /// `true` quand la liste filtrée est vide → bouton centré (allure bloc).
  /// `false` → bouton calé en bas (allure FAB compact).
  final bool centered;

  /// Action d'ouverture du tunnel de nouvelle demande.
  final VoidCallback onTap;

  const NewDemandeFlyingButton({
    super.key,
    required this.centered,
    required this.onTap,
  });

  @override
  State<NewDemandeFlyingButton> createState() => _NewDemandeFlyingButtonState();
}

class _NewDemandeFlyingButtonState extends State<NewDemandeFlyingButton>
    with SingleTickerProviderStateMixin {
  /// Ancrage vertical de l'état centré (sous le texte de l'`EmptyState`).
  /// Réglage fin facile : remonter (< 0.72) ou descendre (> 0.72) au besoin.
  static const Alignment _centeredAlign = Alignment(0, 0.72);

  /// Diamètre du FAB rond (état liste pleine).
  static const double _fabSize = 56;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: widget.centered ? 1 : 0,
  );

  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void didUpdateWidget(covariant NewDemandeFlyingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.centered != oldWidget.centered) {
      _controller.animateTo(widget.centered ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Largeur de l'état bloc, une fois les marges latérales (28+28) retirées.
        final blockWidth = constraints.maxWidth - 56;
        return AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            // t = 0 → FAB rond bas-droite ; t = 1 → bloc centré.
            final t = _t.value;
            final align = Alignment.lerp(
              Alignment.bottomRight,
              _centeredAlign,
              t,
            )!;
            final width = lerpDouble(_fabSize, blockWidth, t)!;
            final height = lerpDouble(_fabSize, 52, t)!;
            final radius = lerpDouble(_fabSize / 2, 16, t)!;
            final rightPad = lerpDouble(16, 28, t)!;
            final bottomPad = lerpDouble(16, 0, t)!;
            return Padding(
              padding: EdgeInsets.only(left: 28, right: rightPad, bottom: bottomPad),
              child: Align(
                alignment: align,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: Material(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(radius),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: widget.onTap,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: AppColors.onAccent,
                            size: 22,
                          ),
                          // Le libellé se résorbe (largeur + opacité) à mesure
                          // que le bouton devient un FAB rond.
                          ClipRect(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              widthFactor: t,
                              child: Opacity(
                                opacity: t,
                                child: const Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Text(
                                      'Nouvelle demande',
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(
                                        color: AppColors.onAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
