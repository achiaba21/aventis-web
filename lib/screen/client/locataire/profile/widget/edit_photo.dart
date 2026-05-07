import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/img/image_app.dart';
import 'package:asfar/widget/item/circle_icon.dart';

class EditPhoto extends StatelessWidget {
  const EditPhoto(this.photo, {super.key, this.onTap});
  final String photo;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Espacement.radius * 8),
        border: Border.all(color: AppColors.background),
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          ImageApp(photo, size: 164),
          InkWell(
            onTap: onTap,
            child: Container(
              width: 164,
              color: AppColors.accent.withAlpha(100),
              child: CircleIcon(image: Icons.edit_note),
            ),
          ),
        ],
      ),
    );
  }
}
