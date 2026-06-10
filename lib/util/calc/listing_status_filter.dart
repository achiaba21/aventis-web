import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/model/residence/appart.dart';

/// Filtres de la liste « Mes annonces » du propriétaire.
///
/// Chaque filtre cible un `AppartementStatus` précis ; `tout` (status `null`)
/// n'en filtre aucun. Les libellés sont alignés sur ceux du badge de statut
/// (`AppartementStatusDisplay`) pour rester cohérents.
enum ListingFilter {
  tout(null, 'Tout'),
  enLigne(AppartementStatus.EN_LIGNE, 'En ligne'),
  enValidation(AppartementStatus.EN_COURS, 'En validation'),
  horsLigne(AppartementStatus.HORS_LIGNE, 'Hors ligne'),
  refusee(AppartementStatus.REFUSER, 'Refusée');

  const ListingFilter(this.status, this.baseLabel);

  /// Statut ciblé par le filtre, ou `null` pour « Tout ».
  final AppartementStatus? status;

  /// Libellé de base (sans le compteur).
  final String baseLabel;
}

/// Helper pur de filtrage/comptage des annonces par statut. Zéro dépendance UI.
class ListingStatusFilter {
  ListingStatusFilter._();

  /// Nombre d'annonces correspondant à [filter] dans [appartements].
  static int count(List<Appartement> appartements, ListingFilter filter) {
    final status = filter.status;
    if (status == null) return appartements.length;
    return appartements.where((a) => a.status == status).length;
  }

  /// Sous-liste des annonces correspondant à [filter].
  static List<Appartement> apply(
    List<Appartement> appartements,
    ListingFilter filter,
  ) {
    final status = filter.status;
    if (status == null) return appartements;
    return appartements.where((a) => a.status == status).toList();
  }

  /// Libellé complet de chip (base + compteur), ex. « En ligne (3) ».
  static String label(List<Appartement> appartements, ListingFilter filter) {
    return '${filter.baseLabel} (${count(appartements, filter)})';
  }

  /// Retrouve le `ListingFilter` à partir de son libellé complet (mapping
  /// inverse pour le callback des chips). Retombe sur `tout` si non trouvé.
  static ListingFilter fromLabel(
    List<Appartement> appartements,
    String label,
  ) {
    for (final filter in ListingFilter.values) {
      if (ListingStatusFilter.label(appartements, filter) == label) {
        return filter;
      }
    }
    return ListingFilter.tout;
  }
}
