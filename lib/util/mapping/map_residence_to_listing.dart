import 'package:asfar/model/map/map_residence.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Mapper `MapResidence` (pin carte) → `ListingPreview` (UI-only V8)
/// utilisé pour pousser vers `LocataireDetailScreen` depuis le BottomSheet
/// d'un marker.
///
/// Les champs absents de `MapResidence` (rating, reviews, beds, baths,
/// surface, imageUrl) reçoivent des fallbacks neutres — le détail réel
/// sera affiché côté DetailScreen une fois l'appartement complet chargé.
class MapResidenceToListingMapper {
  MapResidenceToListingMapper._();

  static ListingPreview mapOne(MapResidence residence) {
    final id = residence.id ?? 0;
    final price = (residence.minPrice ?? 0).round();
    return ListingPreview(
      id: id.toString(),
      tone: (id % 4) + 1,
      title: residence.nom?.trim().isNotEmpty == true
          ? residence.nom!
          : 'Logement',
      area: residence.communeName ?? '',
      city: '',
      price: price,
    );
  }
}
