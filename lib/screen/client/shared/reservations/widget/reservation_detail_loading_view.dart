import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Skeleton de la page détail réservation pendant le chargement initial.
///
/// Reproduit fidèlement la structure réelle : hero, sections eyebrow + card,
/// QR section, timeline. Pas de shimmer (sobre, cohérent dark theme).
class ReservationDetailLoadingView extends StatelessWidget {
  const ReservationDetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonHero(),
          const SizedBox(height: 24),
          _SkeletonEyebrow(),
          const SizedBox(height: 10),
          _SkeletonCard(height: 86),
          const SizedBox(height: 24),
          _SkeletonEyebrow(),
          const SizedBox(height: 10),
          _SkeletonCard(height: 140),
          const SizedBox(height: 24),
          _SkeletonEyebrow(),
          const SizedBox(height: 10),
          _SkeletonCard(height: 80),
          const SizedBox(height: 24),
          _SkeletonEyebrow(),
          const SizedBox(height: 10),
          _SkeletonCard(height: 160),
        ],
      ),
    );
  }
}

class _SkeletonHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
    );
  }
}

class _SkeletonEyebrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;

  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
    );
  }
}
