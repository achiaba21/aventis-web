import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/demarcheur/listings/listing_filters.dart';

/// Croise les `MapAppartement` retournés par `/api/map/appartements/filtered`
/// avec les `Appartement` métier (cache `DemarcheurBloc`) pour appliquer les
/// `ListingFilters` locaux (pièces / partenaire / zone) qui ne sont pas
/// connaissables depuis `MapAppartement` seul.
///
/// Un marker dont l'id n'est pas dans [appartementsParId] est exclu
/// (filet de sécurité — le cache liste n'est pas encore peuplé).
class ListingMapFilter {
  ListingMapFilter._();

  static List<MapAppartement> apply({
    required List<MapAppartement> source,
    required Map<int, Appartement> appartementsParId,
    required ListingFilters filters,
  }) {
    if (filters.isEmpty) {
      return source
          .where((m) => m.id != null && appartementsParId.containsKey(m.id))
          .toList(growable: false);
    }
    return source.where((m) {
      final id = m.id;
      if (id == null) return false;
      final appart = appartementsParId[id];
      if (appart == null) return false;
      return filters.apply([appart]).isNotEmpty;
    }).toList(growable: false);
  }
}
