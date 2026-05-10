import 'package:asfar/widget/card/listing_preview.dart';

/// Données mock alignées sur `LISTINGS` du proto (`shared.jsx`).
///
/// Utilisé en attendant le branchement réel sur `AppartementBloc`. Permet
/// de valider visuellement les écrans Locataire pendant la reconstruction.
class SampleListings {
  SampleListings._();

  static const List<ListingPreview> all = [
    ListingPreview(
      id: 'L1',
      tone: 1,
      title: 'Loft moderne — Plateau',
      area: 'Plateau',
      city: 'Abidjan',
      price: 45000,
      rating: 4.92,
      reviews: 128,
      beds: 1,
      baths: 1,
      surface: 38,
      superhost: true,
    ),
    ListingPreview(
      id: 'L2',
      tone: 2,
      title: 'Studio cosy — Cocody',
      area: 'Cocody Riviera',
      city: 'Abidjan',
      price: 32000,
      rating: 4.78,
      reviews: 64,
      beds: 1,
      baths: 1,
      surface: 28,
    ),
    ListingPreview(
      id: 'L3',
      tone: 3,
      title: 'Appartement vue lagune',
      area: 'Marcory Zone 4',
      city: 'Abidjan',
      price: 68000,
      rating: 4.95,
      reviews: 211,
      beds: 2,
      baths: 2,
      surface: 64,
      superhost: true,
    ),
    ListingPreview(
      id: 'L4',
      tone: 4,
      title: 'Penthouse — Almadies',
      area: 'Almadies',
      city: 'Dakar',
      price: 120000,
      rating: 4.97,
      reviews: 88,
      beds: 3,
      baths: 2,
      surface: 110,
      superhost: true,
    ),
  ];
}
