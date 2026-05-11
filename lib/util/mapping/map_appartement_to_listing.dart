import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Mapper `MapAppartement` (pin carte) → `ListingPreview` (UI-only).
///
/// Mapping **partiel** — sert de fallback lorsque le chargement détail
/// `AppartementService.getAppartementById` échoue dans le BottomSheet. Permet
/// quand même de pousser `LocataireDetailScreen` avec les infos basiques
/// connues par la carte (titre + prix + commune). Le DetailScreen rechargera
/// le détail complet de son côté.
///
/// En cas de succès du chargement, on préfère `AppartementToListingMapper`
/// (plus complet, inclut imgUrl, beds, baths, etc.).
class MapAppartementToListingMapper {
  MapAppartementToListingMapper._();

  static ListingPreview mapOne(MapAppartement m) {
    final id = m.id ?? 0;
    return ListingPreview(
      id: id.toString(),
      tone: (id % 4) + 1,
      title: m.title?.trim().isNotEmpty == true ? m.title! : 'Logement',
      area: m.communeName ?? '',
      city: '',
      price: m.price ?? 0,
      imageUrl: m.imgUrl,
    );
  }
}
