import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/model/residence/offre.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/model/forms/uploaded_image.dart';
import 'package:asfar/model/forms/location_data.dart';

/// Utilitaires pour la conversion des données du formulaire d'appartement
class AppartementMapperUtil {
  /// Convertit une liste de values d'amenities en liste d'Offre
  /// Les commodités seront créées avec le value (ex: "wifi", "pool")
  /// Le backend assignera les IDs et détails complets
  static List<Offre> amenitiesToOffres(List<String> amenityValues) {
    if (amenityValues.isEmpty) return [];

    return amenityValues.map((value) {
      return Offre(
        commodite: Commodite(
          value: value, // "wifi", "pool", "gym", etc.
          // nom et description seront complétés par le backend
        ),
        // appartement sera défini par le backend lors de la sauvegarde
      );
    }).toList();
  }

  /// Convertit une liste d'Offre en liste de values d'amenities
  /// Utilisé pour pré-remplir le formulaire lors de l'édition
  static List<String> offresToAmenities(List<Offre>? offres) {
    if (offres == null || offres.isEmpty) return [];

    return offres
        .where((offre) => offre.commodite?.value != null)
        .map((offre) => offre.commodite!.value!)
        .toList();
  }

  /// Convertit LocationData en Address pour la Résidence
  static Address locationDataToAddress(LocationData locationData) {
    return Address(
      lat: locationData.latitude,
      longi: locationData.longitude,
      nom: locationData.streetAddress ?? locationData.gpsAddress,
      description: locationData.streetAddress,
      // commune reste null pour le moment (pas de sélection de commune dans le formulaire)
    );
  }

  /// Convertit UploadedImage en PhotoAppart
  static PhotoAppart uploadedImageToPhotoAppart(UploadedImage uploadedImage) {
    // Extraire l'extension depuis le nom du fichier
    String? extension;
    if (uploadedImage.name.contains('.')) {
      extension = uploadedImage.name.split('.').last.toLowerCase();
    }

    // Obtenir la taille du fichier si disponible
    int? fileSize;
    if (uploadedImage.file != null) {
      try {
        fileSize = uploadedImage.file!.lengthSync();
      } catch (e) {
        // Ignorer si on ne peut pas obtenir la taille
      }
    }

    return PhotoAppart(
      uuid: uploadedImage.id,
      extension: extension,
      titre: uploadedImage.name,
      path: uploadedImage.path,
      size: fileSize,
      createdAt: DateTime.now(),
      // type reste null - sera défini par le backend
    );
  }

  /// Convertit une liste d'UploadedImage en liste de PhotoAppart
  static List<PhotoAppart> uploadedImagesToPhotoApparts(
    List<UploadedImage> images,
  ) {
    return images.map((img) => uploadedImageToPhotoAppart(img)).toList();
  }

  /// Convertit Address en LocationData pour pré-remplir le formulaire
  /// Utilisé en mode édition
  static LocationData addressToLocationData(Address? address) {
    deboger([
      '🔄 [AppartementMapperUtil] addressToLocationData appelé',
      '   - Address reçue: $address',
      '   - Address est null: ${address == null}',
    ]);

    if (address == null) {
      deboger(
        '⚠️ [AppartementMapperUtil] Address est null, retourne LocationData vide',
      );
      return LocationData();
    }

    deboger([
      '🔄 [AppartementMapperUtil] Conversion Address -> LocationData:',
      '   - address.lat: ${address.lat} (type: ${address.lat.runtimeType})',
      '   - address.longi: ${address.longi} (type: ${address.longi.runtimeType})',
      '   - address.nom: ${address.nom}',
      '   - address.description: ${address.description}',
    ]);

    final locationData = LocationData(
      latitude: address.lat,
      longitude: address.longi,
      streetAddress: address.description ?? address.nom,
      gpsAddress: address.nom,
    );

    deboger([
      '✅ [AppartementMapperUtil] LocationData créé:',
      '   - latitude: ${locationData.latitude}',
      '   - longitude: ${locationData.longitude}',
      '   - streetAddress: ${locationData.streetAddress}',
      '   - gpsAddress: ${locationData.gpsAddress}',
    ]);

    return locationData;
  }
}
