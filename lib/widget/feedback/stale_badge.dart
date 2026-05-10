import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Badge indiquant que les données affichées viennent du cache (stale).
///
/// Pill `bgElev2` border `line` radius pill, icon refresh 12 `text3` + texte
/// 11 `text3` « Mis à jour il y a X ». Tap → `onRefresh`.
///
/// Affichage conditionnel : caché si `lastFetch.difference(now) < 5min`.
/// Permet à l'utilisateur de savoir que les données sont stale et de
/// déclencher un refresh manuel.
class StaleBadge extends StatelessWidget {
  final DateTime lastFetch;
  final VoidCallback? onRefresh;

  const StaleBadge({
    super.key,
    required this.lastFetch,
    this.onRefresh,
  });

  /// Seuil au-dessus duquel les données sont considérées stale (5 minutes).
  static const Duration _staleThreshold = Duration(minutes: 5);

  String _humanRelative(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return 'il y a ${diff.inDays} j';
  }

  bool get _isStale =>
      DateTime.now().difference(lastFetch) >= _staleThreshold;

  @override
  Widget build(BuildContext context) {
    if (!_isStale) return const SizedBox.shrink();

    final label = 'Mis à jour ${_humanRelative(lastFetch)}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: onRefresh,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh, size: 12, color: AppColors.text3),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
