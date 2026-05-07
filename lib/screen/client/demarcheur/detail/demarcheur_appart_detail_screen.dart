import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/calendar/appart_calendar_section.dart';
import 'package:asfar/widget/detail_appart/detail_section_card.dart';
import 'package:asfar/widget/img/image_carousel.dart';
import 'package:asfar/widget/item/appart/appart_titre_info.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/screen/client/locataire/home/widget/house_rule.dart';

class DemarcheurAppartDetailScreen extends StatelessWidget {
  final Appartement appartement;

  const DemarcheurAppartDetailScreen({
    super.key,
    required this.appartement,
  });

  @override
  Widget build(BuildContext context) {
    final userTelephone =
        context.read<UserBloc>().state.user?.telephone ?? '';
    final hasPhotos =
        appartement.photos != null && appartement.photos!.isNotEmpty;
    final hasDescription = appartement.description != null &&
        appartement.description!.isNotEmpty;
    final hasRules = appartement.rules != null && appartement.rules!.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  hasPhotos
                      ? ImageCarousel(
                          photos: appartement.photos,
                          fallbackUrl: appartement.imgUrl,
                          height: 300,
                        )
                      : Container(
                          height: 180,
                          color: AppColors.surface,
                          child: Center(
                            child: Icon(
                              Icons.apartment,
                              size: 64,
                              color: AppColors.inactive,
                            ),
                          ),
                        ),
                  Positioned(
                    top: Espacement.paddingBloc,
                    left: Espacement.paddingBloc,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0x80000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppartTitreInfo(appartement),
                    if (hasDescription) ...[
                      Gap(Espacement.gapSection),
                      DetailSectionCard(
                        title: 'Description',
                        icon: Icons.description_outlined,
                        child: TextSeed(
                          appartement.description!,
                          textAlign: TextAlign.justify,
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (hasRules) ...[
                      Gap(Espacement.gapSection),
                      HouseRule(rules: appartement.rules),
                    ],
                    Gap(Espacement.gapSection),
                  ],
                ),
              ),
              _SectionHeader(),
              AppartCalendarSection(
                appartement: appartement,
                userTelephone: userTelephone,
              ),
              Gap(Espacement.gapSection * 2),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingBloc,
        vertical: Espacement.gapSection,
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_month,
            color: AppColors.accent,
            size: 20,
          ),
          const SizedBox(width: 8),
          TextSeed(
            'Disponibilités',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(color: AppColors.textSecondary, thickness: 1),
          ),
        ],
      ),
    );
  }
}
