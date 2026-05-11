import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/screen/client/locataire/booking/widget/mini_map_preview.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card de capture GPS pour l'étape 2 du wizard d'ajout d'appartement.
///
/// Reproduit `proprietaire-extras.jsx::GpsCapture` (lignes 369-438) :
/// - état vide → bordure `line`, bg `bgElev1`, icon accent + bouton "Activer GPS"
/// - état capturé → bordure `successLight`, bg success-tinted, coords mono +
///   bouton "Recapturer" + mini-carte preview en dessous.
class GpsCaptureCard extends StatelessWidget {
  final LatLng? gps;
  final bool loading;
  final VoidCallback onCapture;

  const GpsCaptureCard({
    super.key,
    required this.gps,
    required this.loading,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final bool captured = gps != null;
    final Color borderColor =
        captured ? AppColors.successLight : AppColors.line;
    final Color bg = captured
        ? AppColors.success.withValues(alpha: 0.06)
        : AppColors.bgElev1;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _LeadingIcon(captured: captured),
              const SizedBox(width: 12),
              Expanded(
                child: _LabelBlock(gps: gps, captured: captured),
              ),
              const SizedBox(width: 8),
              _CaptureButton(
                captured: captured,
                loading: loading,
                onTap: onCapture,
              ),
            ],
          ),
          if (captured)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: MiniMapPreview(center: gps!, height: 100, zoom: 14),
            ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final bool captured;
  const _LeadingIcon({required this.captured});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: captured ? AppColors.successLight : AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Icon(
        Icons.place_outlined,
        size: 20,
        color: captured ? AppColors.success : AppColors.accent,
      ),
    );
  }
}

class _LabelBlock extends StatelessWidget {
  final LatLng? gps;
  final bool captured;

  const _LabelBlock({required this.gps, required this.captured});

  @override
  Widget build(BuildContext context) {
    final String title =
        captured ? 'Position enregistrée' : 'Position GPS';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.small.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        if (captured)
          Text(
            '${gps!.latitude.toStringAsFixed(5)}, '
            '${gps!.longitude.toStringAsFixed(5)}',
            style: AppTextStyles.mono(AppTextStyles.small.copyWith(
              fontSize: 11,
              color: AppColors.text2,
            )),
          )
        else
          Text(
            'Permet de placer le bien sur la carte avec précision.',
            style: AppTextStyles.small.copyWith(
              fontSize: 11,
              height: 1.4,
              color: AppColors.text2,
            ),
          ),
      ],
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final bool captured;
  final bool loading;
  final VoidCallback onTap;

  const _CaptureButton({
    required this.captured,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String label =
        loading ? 'Localisation…' : (captured ? 'Recapturer' : 'Activer GPS');
    final Color bg = captured ? AppColors.bgElev2 : AppColors.accent;
    final Color fg = captured ? AppColors.text : AppColors.onAccent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: captured
                ? Border.all(color: AppColors.line, width: 1)
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
