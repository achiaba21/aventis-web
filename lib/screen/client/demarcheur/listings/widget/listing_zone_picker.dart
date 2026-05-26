import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/listings/widget/listing_picker_tile.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bottom sheet de sélection d'une zone (communeNom) dans le filtre
/// de l'écran "Choisir un logement". Retourne la commune choisie,
/// ou `null` si "Toutes les zones" est sélectionné.
class ListingZonePicker {
  ListingZonePicker._();

  static Future<String?> show(
    BuildContext context, {
    required List<String> zones,
    required String? selected,
  }) {
    return showModalBottomSheet<String?>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => _ZonePickerBody(zones: zones, selected: selected),
    );
  }
}

class _ZonePickerBody extends StatelessWidget {
  final List<String> zones;
  final String? selected;

  const _ZonePickerBody({required this.zones, required this.selected});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.75),
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDim,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('ZONE', style: AppTextStyles.eyebrow),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListingPickerTile(
                      label: 'Toutes les zones',
                      selected: selected == null,
                      onTap: () => Navigator.of(context).pop(null),
                    ),
                    ...zones.map((z) => ListingPickerTile(
                          label: z,
                          selected: selected == z,
                          onTap: () => Navigator.of(context).pop(z),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
