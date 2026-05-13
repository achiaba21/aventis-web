import 'package:flutter/material.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/photo_dots.dart';

/// Carrousel d'images générique du design Asfar Premium.
///
/// Standard partagé partout où on défile des images (galerie hero détail
/// annonce, cards plein largeur, photos d'utilisateur, etc.). Les paths
/// sont résolus automatiquement via `DomainImage` (préfixe `$domain` si
/// relatif).
///
/// Comportement :
/// - 0 path valide → `placeholder` plein largeur
/// - 1 path valide → image seule (pas de dots ni compteur)
/// - 2+ paths valides → `PageView.builder` swipeable + dots animés + compteur
///   `n / total` en bas-droite (visibilité paramétrable)
///
/// Ne définit **pas** d'AspectRatio interne — c'est au caller (1:1, 16:10,
/// 4:3 selon le contexte). N'embarque pas d'overlay (heart, badges) — à
/// empiler par le caller via un Stack externe.
class PhotoCarousel extends StatefulWidget {
  /// Liste de paths (les `null` et chaînes vides sont filtrés).
  final List<String?> paths;

  /// Widget affiché si aucun path n'est valide.
  /// Aussi utilisé comme `errorBuilder` de `DomainImage` (fallback en cas
  /// d'erreur réseau / 404).
  final Widget placeholder;

  /// Dots blancs animés (dot actif étiré 24px) centrés bottom 18px.
  final bool showDots;

  /// Compteur `n / total` bg noir 70 % bottom-right 18px.
  final bool showCounter;

  /// Rayon de clipping global de la zone carrousel.
  final BorderRadius? borderRadius;

  /// Fit du `Image.network` interne. `BoxFit.cover` par défaut.
  final BoxFit fit;

  const PhotoCarousel({
    super.key,
    required this.paths,
    required this.placeholder,
    this.showDots = true,
    this.showCounter = true,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  final PageController _controller = PageController();
  int _active = 0;

  List<String> get _validPaths => widget.paths
      .where((p) => p != null && p.trim().isNotEmpty)
      .cast<String>()
      .toList();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paths = _validPaths;

    final Widget content;
    if (paths.isEmpty) {
      content = widget.placeholder;
    } else if (paths.length == 1) {
      content = DomainImage(
        path: paths.first,
        placeholder: widget.placeholder,
        fit: widget.fit,
      );
    } else {
      content = Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: paths.length,
              onPageChanged: (i) => setState(() => _active = i),
              itemBuilder: (_, i) => DomainImage(
                path: paths[i],
                placeholder: widget.placeholder,
                fit: widget.fit,
              ),
            ),
          ),
          if (widget.showDots)
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: PhotoDots(
                active: _active,
                count: paths.length,
                animated: true,
              ),
            ),
          if (widget.showCounter)
            Positioned(
              bottom: 18,
              right: 18,
              child: _CounterBadge(
                active: _active,
                total: paths.length,
              ),
            ),
        ],
      );
    }

    if (widget.borderRadius == null) return content;
    return ClipRRect(borderRadius: widget.borderRadius!, child: content);
  }
}

class _CounterBadge extends StatelessWidget {
  final int active;
  final int total;

  const _CounterBadge({required this.active, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xB30A0A0B),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        '${active + 1} / $total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
