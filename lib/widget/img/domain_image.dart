import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:asfar/util/url/domain_url.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Widget image qui préfixe automatiquement le `$domain` aux paths relatifs
/// retournés par le backend, et retombe gracieusement sur un placeholder
/// (typiquement `ImgPh(tone)`) si l'image est absente ou échoue à charger.
///
/// PERF-01 : images servies via [CachedNetworkImage] — cache disque + mémoire,
/// plus aucun re-téléchargement au rebuild. Pendant le premier chargement,
/// skeleton pulsé [ShimmerCard] (UI validée, option A). `memCacheWidth` borne
/// le décodage mémoire à la taille d'affichage quand `width` est fournie.
///
/// API :
/// ```dart
/// DomainImage(
///   path: photo.path,                       // String? relatif ou absolu
///   placeholder: ImgPh(tone: appart.tone),  // Widget fallback identitaire
///   fit: BoxFit.cover,
///   borderRadius: BorderRadius.circular(12),
/// )
/// ```
///
/// 4 états visuels :
/// - `path` null/empty → `placeholder`
/// - chargement en cours → `ShimmerCard`
/// - chargement OK → image (cachée pour les prochains affichages)
/// - erreur réseau/404 → `placeholder` (silencieux)
class DomainImage extends StatelessWidget {
  final String? path;
  final Widget placeholder;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const DomainImage({
    super.key,
    required this.path,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = resolveDomainUrl(path);
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final Widget content = (url == null)
        ? placeholder
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            width: width,
            height: height,
            memCacheWidth:
                width != null ? (width! * devicePixelRatio).round() : null,
            placeholder: (_, __) =>
                ShimmerCard(width: width, height: height, radius: 0),
            errorWidget: (_, __, ___) => placeholder,
          );

    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}
