import 'package:flutter/material.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_marker_preview_image.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';

/// BottomSheet preview affiché au tap sur un marker carte — V9.7b.
///
/// Layout : drag handle → photo lazy (chargée via `AppartementService.
/// getAppartementById` au moment du tap) → titre → sub-line (prix · commune
/// · type · chambres) → CTA "Voir détails" full-width.
///
/// Le callback `onViewDetails` reçoit l'`Appartement` complet si chargé,
/// sinon `null` (l'appelant utilisera un mapper fallback partiel).
class MapMarkerBottomSheet extends StatefulWidget {
  final MapAppartement appartement;
  final void Function(Appartement? loadedDetails) onViewDetails;

  const MapMarkerBottomSheet({
    super.key,
    required this.appartement,
    required this.onViewDetails,
  });

  /// Helper d'ouverture du modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required MapAppartement appartement,
    required void Function(Appartement? loadedDetails) onViewDetails,
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
        appartement: appartement,
        onViewDetails: onViewDetails,
      ),
    );
  }

  @override
  State<MapMarkerBottomSheet> createState() => _MapMarkerBottomSheetState();
}

class _MapMarkerBottomSheetState extends State<MapMarkerBottomSheet> {
  final AppartementService _service = AppartementService();
  Appartement? _loadedDetails;
  bool _isLoadingDetails = true;

  int get _tone {
    final id = widget.appartement.id ?? 0;
    return (id % 4) + 1;
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final id = widget.appartement.id;
    if (id == null) {
      if (mounted) setState(() => _isLoadingDetails = false);
      return;
    }
    try {
      final detail = await _service.getAppartementById(id);
      if (!mounted) return;
      setState(() {
        _loadedDetails = detail;
        _isLoadingDetails = false;
      });
    } catch (e) {
      deboger('MapMarkerBottomSheet.loadDetails: $e');
      if (!mounted) return;
      setState(() => _isLoadingDetails = false);
    }
  }

  String _title() {
    final t = widget.appartement.title?.trim();
    if (t != null && t.isNotEmpty) return t;
    final fromDetails = _loadedDetails?.titre?.trim();
    if (fromDetails != null && fromDetails.isNotEmpty) return fromDetails;
    return 'Logement';
  }

  String _subLine() {
    final parts = <String>[];

    final price = widget.appartement.price ?? _loadedDetails?.prix?.round();
    if (price != null && price > 0) {
      parts.add('${FcfaFormatter.full(price)} / nuit');
    }

    final commune = widget.appartement.communeName?.trim();
    if (commune != null && commune.isNotEmpty) {
      parts.add(commune);
    }

    final type = widget.appartement.typeAppart?.trim();
    if (type != null && type.isNotEmpty) {
      parts.add(type);
    }

    final nbCh =
        widget.appartement.nbChambres ?? _loadedDetails?.nbChambres;
    if (nbCh != null && nbCh > 0) {
      parts.add('$nbCh ${nbCh == 1 ? 'chambre' : 'chambres'}');
    }

    return parts.join(' · ');
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
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 16),
          MapMarkerPreviewImage(
            tone: _tone,
            imgUrl: widget.appartement.imgUrl ?? _loadedDetails?.imgUrl,
            isLoading:
                _isLoadingDetails && widget.appartement.imgUrl == null,
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
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: AppColors.text3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          CustomButton(
            text: 'Voir détails',
            onPressed: () => widget.onViewDetails(_loadedDetails),
            size: ButtonSize.lg,
            block: true,
          ),
        ],
      ),
    );
  }
}
