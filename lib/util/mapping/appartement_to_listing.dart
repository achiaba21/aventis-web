import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Mappe `Appartement` (modèle métier Hive) → `ListingPreview` (DTO de
/// présentation V5).
///
/// Champs hérités directement :
/// - `id` (int → String)
/// - `titre` → `title`
/// - `prix` → `price` (round)
/// - `nbLits` → `beds`
/// - `nbDouches` → `baths`
/// - `commune.nom` → `area` (quartier)
/// - `commune.ville.nom` → `city`
/// - `imgUrl` → `imageUrl`
/// - `commentaires.length` → `reviews`
/// - `note` (calculé sur Appartement) → `rating`
///
/// Champs dérivés (heuristiques, à affiner avec le backend dans une vague
/// future) :
/// - `tone` (1-4) : `id % 4 + 1` — déterministe par appartement, garantit
///   que chaque appartement a toujours le même tone visuel
/// - `surface` : non disponible sur `Appartement` → 0 (TODO BACKEND : ajouter
///   un champ `surface` au backend)
/// - `superhost` : `note >= 4.8 && reviews >= 50` — heuristique simple
class AppartementToListingMapper {
  AppartementToListingMapper._();

  static ListingPreview mapOne(Appartement source) {
    final reviews = source.commentaires?.length ?? 0;
    final rating = source.note;
    final id = source.id ?? 0;

    return ListingPreview(
      id: id.toString(),
      tone: (id % 4) + 1,
      title: source.titre ?? 'Sans titre',
      area: source.address?.commune?.nom ?? '',
      city: source.address?.commune?.ville?.nom ?? '',
      price: (source.prix ?? 0).round(),
      rating: rating,
      reviews: reviews,
      beds: source.nbLits ?? 0,
      baths: source.nbDouches ?? 0,
      surface: 0,
      superhost: rating >= 4.8 && reviews >= 50,
      imageUrl: source.imgUrl,
    );
  }

  static List<ListingPreview> mapMany(List<Appartement> sources) {
    return sources.map(mapOne).toList(growable: false);
  }

  static ListingPreview? mapNullable(Appartement? source) {
    return source == null ? null : mapOne(source);
  }
}
