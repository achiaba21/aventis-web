import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/appartement_mapper_util.dart';
import 'package:asfar/util/appartement_publication_validator.dart';
import 'package:asfar/widget/form/amenities_grid.dart';
import 'package:asfar/widget/form/image_uploader.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Étape 4 du wizard : photos (≥3 pour publier) + équipements.
class Step4MediaAmenities extends StatefulWidget {
  const Step4MediaAmenities({super.key});

  @override
  State<Step4MediaAmenities> createState() => _Step4MediaAmenitiesState();
}

class _Step4MediaAmenitiesState extends State<Step4MediaAmenities> {
  /// Cache local des `UploadedImage` correspondant aux nouvelles photos
  /// ajoutées dans le wizard (les `PhotoAppart` du draft sont la source
  /// de vérité visuelle, mais on garde les `File` ici pour l'upload final).
  final Map<String, UploadedImage> _localUploads = {};

  void _onImageAdd(File file) {
    final upload = UploadedImage.fromFile(file);
    _localUploads[upload.id] = upload;

    // Recalcule la liste de PhotoAppart depuis le cache local
    final photos = AppartementMapperUtil
        .uploadedImagesToPhotoApparts(_localUploads.values.toList());

    // Conserve d'éventuelles photos existantes (mode édition) en plus
    final draft = context.read<AppartementWizardBloc>().state.draft;
    final existingServerPhotos = (draft.photos ?? [])
        .where((p) => p.uuid != null)
        .toList();

    context.read<AppartementWizardBloc>().add(
          UpdateField('photos', [...existingServerPhotos, ...photos]),
        );
  }

  void _onImageRemove(String imageId) {
    _localUploads.remove(imageId);
    final photos = AppartementMapperUtil
        .uploadedImagesToPhotoApparts(_localUploads.values.toList());
    final draft = context.read<AppartementWizardBloc>().state.draft;
    final existingServerPhotos = (draft.photos ?? [])
        .where((p) => p.uuid != null)
        .toList();
    context.read<AppartementWizardBloc>().add(
          UpdateField('photos', [...existingServerPhotos, ...photos]),
        );
  }

  void _onExistingPhotoRemove(String photoUuid) {
    final draft = context.read<AppartementWizardBloc>().state.draft;
    final remaining = (draft.photos ?? [])
        .where((p) => p.uuid != photoUuid)
        .toList();
    context.read<AppartementWizardBloc>().add(UpdateField('photos', remaining));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppartementWizardBloc, AppartementWizardState>(
      buildWhen: (prev, next) =>
          prev.draft.photos != next.draft.photos ||
          prev.draft.offres != next.draft.offres,
      builder: (context, state) {
        final draft = state.draft;
        final photos = draft.photos ?? <PhotoAppart>[];
        final localPhotos = _localUploads.values.toList();
        final serverPhotos = photos.where((p) => p.uuid != null).toList();
        final selectedAmenities =
            AppartementMapperUtil.offresToAmenities(draft.offres);

        final photosCount = photos.length;
        final minRequired = AppartementPublicationValidator.minPhotosToPublish;
        final hint = photosCount >= minRequired
            ? "$photosCount photos · minimum $minRequired atteint"
            : "Ajoutez encore ${minRequired - photosCount} photo(s) "
                "pour pouvoir publier";
        final hintColor =
            photosCount >= minRequired ? AppColors.success : AppColors.warning;

        return SingleChildScrollView(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                "Photos & équipements",
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: Espacement.gapItem),
              TextSeed(
                "Mettez en valeur votre bien — au moins $minRequired photos.",
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: Espacement.gapSection * 2),
              ImageUploader(
                images: localPhotos,
                onImageAdd: _onImageAdd,
                onImageRemove: _onImageRemove,
                existingPhotos: serverPhotos,
                onExistingPhotoRemove: _onExistingPhotoRemove,
              ),
              SizedBox(height: Espacement.gapItem),
              TextSeed(
                hint,
                fontSize: 12,
                color: hintColor,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: Espacement.gapSection * 2),
              TextSeed(
                "Équipements",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: Espacement.gapSection),
              AmenitiesGrid(
                selectedAmenities: selectedAmenities,
                onAmenityToggle: (amenity) {
                  final updated = List<String>.from(selectedAmenities);
                  if (updated.contains(amenity)) {
                    updated.remove(amenity);
                  } else {
                    updated.add(amenity);
                  }
                  final offres = AppartementMapperUtil.amenitiesToOffres(updated);
                  context
                      .read<AppartementWizardBloc>()
                      .add(UpdateField('offres', offres));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
