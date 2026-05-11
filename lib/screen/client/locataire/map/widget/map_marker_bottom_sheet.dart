import 'package:flutter/material.dart';
import 'package:asfar/model/map/map_residence.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// BottomSheet de preview affiché au tap sur un marker carte.
///
/// Affiche : image placeholder 16:9 + nom + sub-line (priceRange ·
/// communeName · count) + CTA "Voir détails" full-width.
class MapMarkerBottomSheet extends StatelessWidget {
  final MapResidence residence;
  final VoidCallback? onViewDetails;

  const MapMarkerBottomSheet({
    super.key,
    required this.residence,
    this.onViewDetails,
  });

  /// Helper d'ouverture du modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required MapResidence residence,
    VoidCallback? onViewDetails,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MapMarkerBottomSheet(
        residence: residence,
        onViewDetails: onViewDetails,
      ),
    );
  }

  int get _tone {
    final id = residence.id ?? 0;
    return (id % 4) + 1;
  }

  String _priceLabel() {
    final min = residence.minPrice;
    final max = residence.maxPrice;
    if (min == null) return '—';
    if (max == null || max == min) {
      return '${FcfaFormatter.full(min.round())} / nuit';
    }
    return '${FcfaFormatter.compact(min.round())} - ${FcfaFormatter.compact(max.round())}';
  }

  String _subLine() {
    final parts = <String>[_priceLabel()];
    final commune = residence.communeName?.trim();
    if (commune != null && commune.isNotEmpty) parts.add(commune);
    final count = residence.appartementCount ?? 0;
    if (count > 1) parts.add('$count appartements');
    return parts.join(' · ');
  }

  String _title() {
    final n = residence.nom?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Logement';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bgElev3,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ImgPh(tone: _tone, radius: 14),
          ),
          const SizedBox(height: 14),
          Text(
            _title(),
            style: AppTextStyles.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _subLine(),
            style: AppTextStyles.small.copyWith(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: 'Voir détails',
            onPressed: onViewDetails,
            size: ButtonSize.lg,
            block: true,
          ),
        ],
      ),
    );
  }
}
