import 'package:asfar/model/enumeration/appartement_status.dart';

/// Helpers d'affichage pour `AppartementStatus`.
///
/// Centralise le mapping enum → label eyebrow (uppercase) consommé par
/// `ProprioListingEditScreen` et la liste annonces.
class AppartementStatusDisplay {
  AppartementStatusDisplay._();

  static String eyebrowLabel(AppartementStatus? status) {
    switch (status) {
      case AppartementStatus.DISPONIBLE:
        return 'ANNONCE ACTIVE';
      case AppartementStatus.OCCUPE:
        return 'ACTUELLEMENT OCCUPÉE';
      case AppartementStatus.EN_MAINTENANCE:
        return 'EN MAINTENANCE';
      case AppartementStatus.INACTIF:
        return 'ANNONCE DÉSACTIVÉE';
      case null:
        return 'ANNONCE';
    }
  }
}
