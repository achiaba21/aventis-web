import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/model/reservation/commentaire/commentaire.dart';
import 'package:asfar/screen/client/locataire/booking/reserve_screen.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenities_grid.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenity_item.dart';
import 'package:asfar/screen/client/locataire/booking/widget/detail_bottom_bar.dart';
import 'package:asfar/screen/client/locataire/booking/widget/detail_map_section.dart';
import 'package:asfar/screen/client/locataire/booking/widget/detail_title_block.dart';
import 'package:asfar/screen/client/locataire/booking/widget/host_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/quick_specs_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/review_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/img/img_placeholder.dart';
import 'package:asfar/widget/img/photo_carousel.dart';

/// Écran Detail logement — fiche complète.
///
/// Consomme directement [Appartement]. Reproduit `LocataireDetail` du proto :
/// galerie hero 1:1 + actions flottantes (back, share, heart) + title block +
/// quick specs + host card + description + amenities + emplacement + reviews
/// + bottom bar.
class LocataireDetailScreen extends StatelessWidget {
  final Appartement appartement;
  final String dates;

  const LocataireDetailScreen({
    super.key,
    required this.appartement,
    this.dates = '12-15 nov',
  });

  static const _amenities = [
    AmenityItem(icon: Icons.wifi, label: 'WiFi fibre'),
    AmenityItem(icon: Icons.local_parking, label: 'Parking'),
    AmenityItem(icon: Icons.shield_outlined, label: 'Sécurité 24/7'),
    AmenityItem(icon: Icons.kitchen_outlined, label: 'Cuisine équipée'),
    AmenityItem(icon: Icons.ac_unit, label: 'Climatisation'),
    AmenityItem(icon: Icons.tv_outlined, label: 'TV'),
  ];

  void _onReserve(BuildContext context) {
    pushScreen(context, LocataireReserveScreen(appartement: appartement));
  }

  String get _typeLabel {
    final t = appartement.typeLocation;
    if (t == null || t.isEmpty) return 'Logement';
    return t[0].toUpperCase() + t.substring(1).toLowerCase();
  }

  String get _descriptionText {
    final d = appartement.description;
    if (d != null && d.trim().isNotEmpty) return d;
    return "Espace lumineux et calme au cœur de ${appartement.areaName}. "
        "Décoration soignée, équipements modernes, balcon avec "
        "vue dégagée. Idéal pour séjours d'affaires ou tourisme.";
  }

  @override
  Widget build(BuildContext context) {
    final reviews = appartement.commentaires ?? const <Commentaire>[];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: PhotoCarousel(
                  paths: (appartement.photos ?? const [])
                      .map((p) => p.path)
                      .toList(),
                  placeholder: ImgPh(tone: appartement.tone, radius: 0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailTitleBlock(
                      type: _typeLabel,
                      title: appartement.titleSafe,
                      rating: appartement.rating,
                      reviews: appartement.reviewsCount,
                      area: appartement.areaName,
                      city: appartement.cityName,
                    ),
                    const SizedBox(height: 18),
                    QuickSpecsCard(
                      beds: appartement.bedsCount,
                      rooms: appartement.nbChambres ?? 0,
                      baths: appartement.bathsCount,
                    ),
                    const SizedBox(height: 18),
                    HostCard(
                      hostName: 'Aminata K.',
                      memberSince: '2023',
                      certified: appartement.isSuperhost,
                      onContactTap: () {},
                    ),
                    const SizedBox(height: 22),
                    const Text('À propos du logement',
                        style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    Text(_descriptionText, style: AppTextStyles.body),
                    const SizedBox(height: 22),
                    const Text('Équipements', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    const AmenitiesGrid(items: _amenities),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {},
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          'Voir les 18 équipements →',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text('Localisation', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    DetailMapSection(
                      appartId: appartement.id,
                      area: appartement.areaName,
                      city: appartement.cityName,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: AppColors.accent),
                              const SizedBox(width: 6),
                              Text(
                                '${appartement.rating.toStringAsFixed(2)} · ${appartement.reviewsCount} avis',
                                style: AppTextStyles.h3,
                              ),
                            ],
                          ),
                        ),
                        if (reviews.isNotEmpty)
                          const Text(
                            'Tout voir',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              if (reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: EmptyState.inline(
                    icon: Icons.chat_bubble_outline,
                    title: 'Aucun avis pour le moment',
                    body:
                        'Soyez le premier à séjourner ici et à partager votre expérience.',
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final r = reviews[i];
                      return ReviewCard(
                        name: _reviewerName(r),
                        text: r.contenu ?? '',
                        date: formatDateMonth(r.createdAt),
                        starCount: (r.note ?? 5).clamp(0, 5),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconBoutton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: () => back(context),
                      floating: true,
                    ),
                    Row(
                      children: [
                        IconBoutton(
                          icon: Icons.ios_share,
                          onPressed: () {},
                          floating: true,
                        ),
                        const SizedBox(width: 8),
                        IconBoutton(
                          icon: Icons.favorite_border,
                          onPressed: () {},
                          floating: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DetailBottomBar(
              pricePerNight: appartement.priceAmount,
              dates: dates,
              onReserve: () => _onReserve(context),
            ),
          ),
        ],
      ),
    );
  }

  String _reviewerName(Commentaire c) {
    final prenom = c.client?.prenom?.trim() ?? '';
    final nom = c.client?.nom?.trim() ?? '';
    final initial = nom.isNotEmpty ? ' ${nom[0]}.' : '';
    if (prenom.isEmpty && nom.isEmpty) return 'Anonyme';
    return '$prenom$initial'.trim();
  }
}
