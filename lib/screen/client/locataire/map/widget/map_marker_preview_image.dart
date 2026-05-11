import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Image preview lazy du `MapMarkerBottomSheet` — V9.7b option A.
///
/// 3 états visuels (AspectRatio 16:9, radius `AppRadii.md`) :
/// - **loading** : `ImgPh(tone)` base + `_ShimmerOverlay` accent or animé.
/// - **loaded** (`imgUrl != null`) : `Image.network` `fit: cover`,
///   `errorBuilder` retombe silencieusement sur `ImgPh(tone)`.
/// - **error / no imgUrl** : `ImgPh(tone)` silencieux (sans icône broken_image).
///
/// L'erreur est volontairement silencieuse pour préserver l'expérience
/// "Pristine luxe" — l'utilisateur perçoit un placeholder identitaire, pas
/// un état d'échec.
class MapMarkerPreviewImage extends StatelessWidget {
  final int tone;
  final String? imgUrl;
  final bool isLoading;

  const MapMarkerPreviewImage({
    super.key,
    required this.tone,
    required this.imgUrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (isLoading) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          ImgPh(tone: tone, radius: AppRadii.md),
          const _ShimmerOverlay(),
        ],
      );
    } else if (imgUrl != null && imgUrl!.isNotEmpty) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Image.network(
          imgUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ImgPh(tone: tone, radius: AppRadii.md),
        ),
      );
    } else {
      content = ImgPh(tone: tone, radius: AppRadii.md);
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: content,
    );
  }
}

/// Overlay shimmer or qui glisse de gauche à droite (1200ms repeat).
///
/// Bande translucide accent (`AppColors.accentSoft`) animée via un
/// `LinearGradient` dont les `Alignment.begin/end` se déplacent sur l'axe X.
/// Encapsulé dans un `ClipRRect` aux mêmes coins que le placeholder parent.
class _ShimmerOverlay extends StatefulWidget {
  const _ShimmerOverlay();

  @override
  State<_ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<_ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final dx = -1.0 + (t * 2.8);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(dx - 0.4, -0.4),
                end: Alignment(dx + 0.4, 0.4),
                colors: const [
                  Colors.transparent,
                  AppColors.accentSoft,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
