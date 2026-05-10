import 'package:asfar/screen/client/locataire/home/sample_listings.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Logements à pousser pour le démarcheur — réutilise [SampleListings.all] et
/// précalcule la commission estimée (10% du prix × `defaultNights` nuits).
///
/// Aligne sur la section « Logements à pousser » du proto
/// (`demarcheur.jsx::DemarcheurDashboard`, carrousel horizontal cards 200px).
class SampleListingsToReferral {
  SampleListingsToReferral._();

  /// Nombre de nuits utilisé par défaut pour estimer la commission
  /// (3 nuits — séjour standard du proto).
  static const int defaultNights = 3;

  /// Tous les logements de [SampleListings.all] sont éligibles au référencement.
  static List<ListingPreview> get listings => SampleListings.all;

  /// Commission estimée par référence sur ce logement (10% × prix × `defaultNights`).
  static int commissionFor(ListingPreview listing,
      {int nights = defaultNights}) {
    return (listing.price * nights * 0.10).round();
  }
}
