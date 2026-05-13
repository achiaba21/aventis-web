import 'package:flutter/material.dart';
import 'package:asfar/util/url/domain_url.dart';

/// Widget image qui préfixe automatiquement le `$domain` aux paths relatifs
/// retournés par le backend, et retombe gracieusement sur un placeholder
/// (typiquement `ImgPh(tone)`) si l'image est absente ou échoue à charger.
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
/// 3 états visuels :
/// - `path` null/empty → `placeholder`
/// - `path` valide + chargement OK → `Image.network(domainUrl, fit: ...)`
/// - `path` valide + erreur réseau/404 → `placeholder` (silencieux)
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
    final Widget content = (url == null)
        ? placeholder
        : Image.network(
            url,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, __, ___) => placeholder,
          );

    if (borderRadius == null) return content;
    return ClipRRect(borderRadius: borderRadius!, child: content);
  }
}
