import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card complète d'annonce — `ProprioListingsScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListings`
/// (lignes 377-430) : `ImgPh` 16:9 + 2 badges en absolute (Actif success +
/// Certifié accent si superhost) + bouton `moreH` 32×32 blur top-right + body
/// (titre + prix + sub + 3 KPIs inline) + footer 3 boutons ghost.
class ListingFullCard extends StatelessWidget {
  final ListingPreview listing;
  final double occupancyRate;
  final int monthlyRevenue;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onStatsTap;

  const ListingFullCard({
    super.key,
    required this.listing,
    required this.occupancyRate,
    required this.monthlyRevenue,
    this.onTap,
    this.onMoreTap,
    this.onCalendarTap,
    this.onEditTap,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _hero(),
              _body(),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          Positioned.fill(child: ImgPh(tone: listing.tone, radius: 0)),
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BadgeStatus(text: '● Actif', tone: BadgeTone.success),
                if (listing.superhost) ...[
                  const SizedBox(width: 6),
                  const BadgeStatus(text: '★ Certifié', tone: BadgeTone.accent),
                ],
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _moreButton(),
          ),
        ],
      ),
    );
  }

  Widget _moreButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onMoreTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background.withValues(alpha: 0.6),
          ),
          child: const Icon(Icons.more_horiz, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _body() {
    final occupancyPct = (occupancyRate * 100).round();
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${FcfaFormatter.compact(listing.price)}/n',
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${listing.area} · ${listing.surface} m²',
            style: AppTextStyles.small.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kpi('OCCUP.', '$occupancyPct%')),
              Expanded(child: _kpi('NOTE', listing.rating.toStringAsFixed(2),
                  withStar: true)),
              Expanded(
                child: _kpi('REV. MOIS', FcfaFormatter.compact(monthlyRevenue)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpi(String label, String value, {bool withStar = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.eyebrow.copyWith(fontSize: 9),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (withStar) ...[
              const Icon(Icons.star, size: 12, color: AppColors.accent),
              const SizedBox(width: 3),
            ],
            Text(
              value,
              style: AppTextStyles.mono(const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footer() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(child: _ghostBtn(Icons.calendar_today_outlined,
              'Calendrier', onCalendarTap)),
          const SizedBox(width: 4),
          Expanded(child: _ghostBtn(Icons.edit_outlined, 'Modifier',
              onEditTap)),
          const SizedBox(width: 4),
          Expanded(child: _ghostBtn(Icons.bar_chart_outlined, 'Stats',
              onStatsTap)),
        ],
      ),
    );
  }

  Widget _ghostBtn(IconData icon, String label, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: AppColors.text2),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
