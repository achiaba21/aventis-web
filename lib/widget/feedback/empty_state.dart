import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Variants visuels du widget `EmptyState`.
enum EmptyStateVariant {
  /// Hero gradient/cercle accentSoft 120 + icon 40 accent + titre h2 + body +
  /// CTA primary lg block. Usage : zones principales (LocataireTrips,
  /// FavoriteScreen vide, ProprioListings vide, MessagingList vide, etc.).
  hero,

  /// Inline minimal : carré 64 bgElev3 + icon 28 text2 + titre 14 + body 12 +
  /// CTA optionnel. Usage : sections de Dashboard (« Aucun client référé »
  /// dans le proprio dashboard, etc.).
  inline,

  /// Erreur réseau : icon `cloud_off` 64 text3 + titre + body + bouton retry.
  /// Usage : timeout / 500 / pas de cache.
  error,
}

/// Widget générique d'état vide / erreur — Vague de finition.
///
/// 3 factories pour les 3 cas d'usage : `EmptyState.hero(...)` pour les zones
/// principales, `EmptyState.inline(...)` pour les sections de Dashboard,
/// `EmptyState.error(...)` pour les erreurs réseau avec retry.
///
/// Les visuels sont alignés sur l'identité Asfar Premium :
/// `accentSoft` + `accent` (V3 OnboardingRoleCard pattern) pour le hero,
/// `bgElev3` + `text2` pour l'inline, `cloud_off` + retry pour l'erreur.
class EmptyState extends StatelessWidget {
  final EmptyStateVariant variant;
  final IconData icon;
  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
  final VoidCallback? onRetry;

  const EmptyState._({
    required this.variant,
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCtaTap,
    this.onRetry,
  });

  /// Hero variant — zones principales.
  factory EmptyState.hero({
    required IconData icon,
    required String title,
    required String body,
    String? ctaLabel,
    VoidCallback? onCtaTap,
  }) {
    return EmptyState._(
      variant: EmptyStateVariant.hero,
      icon: icon,
      title: title,
      body: body,
      ctaLabel: ctaLabel,
      onCtaTap: onCtaTap,
    );
  }

  /// Inline variant — sections de Dashboard.
  factory EmptyState.inline({
    required IconData icon,
    required String title,
    required String body,
    String? ctaLabel,
    VoidCallback? onCtaTap,
  }) {
    return EmptyState._(
      variant: EmptyStateVariant.inline,
      icon: icon,
      title: title,
      body: body,
      ctaLabel: ctaLabel,
      onCtaTap: onCtaTap,
    );
  }

  /// Error variant — timeout/500/offline.
  factory EmptyState.error({
    required String message,
    required VoidCallback onRetry,
  }) {
    return EmptyState._(
      variant: EmptyStateVariant.error,
      icon: Icons.cloud_off,
      title: 'Connexion impossible',
      body: message,
      ctaLabel: 'Réessayer',
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case EmptyStateVariant.hero:
        return _HeroLayout(
          icon: icon,
          title: title,
          body: body,
          ctaLabel: ctaLabel,
          onCtaTap: onCtaTap,
        );
      case EmptyStateVariant.inline:
        return _InlineLayout(
          icon: icon,
          title: title,
          body: body,
          ctaLabel: ctaLabel,
          onCtaTap: onCtaTap,
        );
      case EmptyStateVariant.error:
        return _ErrorLayout(
          icon: icon,
          title: title,
          body: body,
          ctaLabel: ctaLabel ?? 'Réessayer',
          onRetry: onRetry,
        );
    }
  }
}

class _HeroLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  const _HeroLayout({
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _HeroBadge(icon: icon),
            const SizedBox(height: 22),
            Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCtaTap != null) ...[
              const SizedBox(height: 22),
              CustomButton(
                text: ctaLabel!,
                onPressed: onCtaTap,
                size: ButtonSize.lg,
                block: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;

  const _HeroBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.7],
            ),
          ),
        ),
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentSoft,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 40, color: AppColors.accent),
        ),
      ],
    );
  }
}

class _InlineLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  const _InlineLayout({
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCtaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.bgElev3,
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 28, color: AppColors.text2),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTextStyles.small.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (ctaLabel != null && onCtaTap != null) ...[
            const SizedBox(height: 12),
            OutlinedCustomButton(
              text: ctaLabel!,
              onPressed: onCtaTap,
              size: ButtonSize.sm,
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorLayout extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback? onRetry;

  const _ErrorLayout({
    required this.icon,
    required this.title,
    required this.body,
    required this.ctaLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.text3),
            const SizedBox(height: 18),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTextStyles.small.copyWith(fontSize: 13),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 22),
              OutlinedCustomButton(
                text: ctaLabel,
                onPressed: onRetry,
                size: ButtonSize.md,
                block: true,
                leadingIcon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
