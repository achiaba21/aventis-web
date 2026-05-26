import 'package:flutter/material.dart';
import 'package:asfar/model/user/participant_mini.dart';
import 'package:asfar/screen/client/demarcheur/listings/widget/listing_picker_tile.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bottom sheet de sélection d'un partenaire (propriétaire) dans le filtre
/// de l'écran "Choisir un logement". Retourne l'`id` du propriétaire choisi,
/// ou `null` si "Tous les partenaires" est sélectionné.
class ListingPartenairePicker {
  ListingPartenairePicker._();

  static Future<int?> show(
    BuildContext context, {
    required List<ParticipantMini> partenaires,
    required int? selectedId,
  }) {
    return showModalBottomSheet<int?>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => _PartenairePickerBody(
        partenaires: partenaires,
        selectedId: selectedId,
      ),
    );
  }
}

class _PartenairePickerBody extends StatelessWidget {
  final List<ParticipantMini> partenaires;
  final int? selectedId;

  const _PartenairePickerBody({
    required this.partenaires,
    required this.selectedId,
  });

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
                child: Text('PARTENAIRE', style: AppTextStyles.eyebrow),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListingPickerTile(
                      label: 'Tous les partenaires',
                      selected: selectedId == null,
                      onTap: () => Navigator.of(context).pop(null),
                    ),
                    ...partenaires.map((p) => ListingPickerTile(
                          label: p.fullName,
                          selected: selectedId == p.id,
                          onTap: () => Navigator.of(context).pop(p.id),
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
