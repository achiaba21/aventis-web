import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/client.dart';
import 'package:asfar/widget/img/image_app.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({
    super.key,
    required this.client,
  });

  final Client client;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textPrimary),
      ),
      child: Row(
        children: [
          ImageApp(client.photoUser, size: 56),
          SizedBox(width: Espacement.gapSection),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  client.fullName,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 4),
                TextSeed(
                  client.credential,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
