import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/client.dart';
import 'package:asfar/screen/client/locataire/profile/edit_profil.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/plain_button_expand.dart';
import 'package:asfar/widget/img/image_app.dart';
import 'package:asfar/widget/profile/credential_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key, required this.client});
  final Client client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and profile photo
              Padding(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                child: Row(
                  children: [
                    IconBoutton(
                      icon: Icons.arrow_back,
                      onPressed: () => back(context),
                    ),
                  ],
                ),
              ),

              // Profile Photo (large)
              Center(
                child: ImageApp(client.photoUser, size: 96),
              ),

              Gap(Espacement.gapSection),

              // User Info Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextSeed(
                                "Hi, I'm ${client.fullName}",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 4),
                              TextSeed(
                                client.credential,
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 8),
                              if (client.createdAt != null)
                                TextSeed(
                                  "Joined in ${client.createdAt!.year}",
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                            ],
                          ),
                        ),
                        IconBoutton(
                          icon: Icons.edit_outlined,
                          onPressed: () => pushScreen(context, EditProfil()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Gap(Espacement.gapSection * 2),

              Divider(),

              Gap(Espacement.gapSection),

              // ID Verification Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeed(
                      "Add ID for verification",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    Gap(Espacement.gapSection),
                    Container(
                      padding: EdgeInsets.all(Espacement.paddingBloc),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.infoLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.info,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: Espacement.gapSection),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PlainButtonExpand(
                                  value: "Add identification",
                                  onPress: () {
                                    // TODO: Navigate to ID upload page
                                  },
                                ),
                                SizedBox(height: 8),
                                TextSeed(
                                  "Add a valid National Identification card, Drivers license or any valid national ID\nFormat: PDF, JPG and PNG",
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Gap(Espacement.gapSection * 2),

              Divider(),

              Gap(Espacement.gapSection),

              // Files Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeed(
                      "Files",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    Gap(Espacement.gapSection),
                    // Example credentials - replace with actual data
                    Wrap(
                      spacing: Espacement.gapSection,
                      runSpacing: Espacement.gapSection,
                      children: [
                        CredentialCard(
                          title: "Credential 1",
                          format: "PDF",
                          status: "Approved",
                          onDelete: () {
                            // TODO: Delete document
                          },
                        ),
                        CredentialCard(
                          title: "Credential 2",
                          format: "JPG",
                          status: "Approved",
                          onDelete: () {
                            // TODO: Delete document
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Gap(Espacement.gapSection * 2),

              Divider(),

              Gap(Espacement.gapSection),

              // Change Password Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to change password page
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Espacement.paddingBloc),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextSeed(
                          "Change password",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),

              Gap(Espacement.gapSection * 2),
            ],
          ),
        ),
      ),
    );
  }
}
