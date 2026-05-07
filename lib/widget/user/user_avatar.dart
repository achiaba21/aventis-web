import 'package:flutter/material.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/util/navigation.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    this.onTap,
    this.size = 40,
  });

  final User user;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToProfile(context),
      child: CircleAvatar(
        radius: size / 2,
        child: user.imgUrl == null || user.imgUrl!.isEmpty
            ? CircleIcon(image: Icons.person)
            : ClipOval(
                child: ImageNet(
                  user.imgUrl!,
                  size: size,
                  radius: size / 2,
                ),
              ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    // TODO: Créer la page profil et implémenter la navigation
    // Pour l'instant, on ne fait rien car il n'y a pas de widget spécifique à naviguer
    // L'utilisateur est déjà sur le dashboard approprié
  }
}