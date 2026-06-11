import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/user/avatar_initials.dart';

/// Avatar utilisateur du design system Asfar Premium.
///
/// Cercle gradient or chaud (`accentDark → ombre brune`) avec initiales
/// auto-extraites du nom. Reproduit `.avatar` du prototype.
///
/// `imageUrl` optionnelle : si fourni et chargement réussi, affiche l'image,
/// sinon fallback sur les initiales.
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 36,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initials = AvatarInitials.from(name);
    final fontSize = size * 0.4;
    final initialsLabel = Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.avatarGradientStart,
            AppColors.avatarGradientEnd,
          ],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      // PERF-01 : avatar caché (disque + mémoire) via DomainImage
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? DomainImage(
              path: imageUrl,
              fit: BoxFit.cover,
              width: size,
              height: size,
              placeholder: initialsLabel,
            )
          : initialsLabel,
    );
  }
}
