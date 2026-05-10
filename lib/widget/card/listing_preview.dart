/// Données de présentation d'un logement pour les cards Asfar Premium.
///
/// Value object découplé du modèle `Appartement` : les écrans construisent
/// un [ListingPreview] depuis leur modèle métier avant de le passer aux
/// cards. Ainsi les widgets restent purs présentation et réutilisables.
class ListingPreview {
  /// Identifiant unique (utile pour navigation, favoris, BLoC).
  final String id;

  /// Tone du gradient placeholder (1-4, voir `AppColors.tonalGradient*`).
  final int tone;

  final String title;
  final String area;
  final String city;
  final int price;
  final double rating;
  final int reviews;
  final int beds;
  final int baths;
  final int surface;
  final bool superhost;

  /// URL d'image optionnelle (si fournie, remplace l'`ImgPh`).
  final String? imageUrl;

  const ListingPreview({
    required this.id,
    required this.tone,
    required this.title,
    required this.area,
    required this.city,
    required this.price,
    this.rating = 0,
    this.reviews = 0,
    this.beds = 1,
    this.baths = 1,
    this.surface = 0,
    this.superhost = false,
    this.imageUrl,
  });
}
