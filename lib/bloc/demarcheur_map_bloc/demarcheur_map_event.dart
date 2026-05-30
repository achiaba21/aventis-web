import 'package:latlong2/latlong.dart';

/// Events du BLoC carte démarcheur — V9.7d.
///
/// Pendant SRP du `MapEvent` locataire, scopé au flow démarcheur :
/// pas de `RequestRealLocation` (le démarcheur ne réserve pas), pas de
/// `UpdateMapFilter` (les filtres `ListingFilters` restent locaux au screen),
/// pas de `SelectMapAppartement` ni `LoadAppartementDetails` (tap pin →
/// navigation directe vers `DemarcheurAppartDetailScreen`).
abstract class DemarcheurMapEvent {
  const DemarcheurMapEvent();
}

/// Charge les logements partenaires visibles dans une zone.
///
/// Le scope (réseau partenaires du démarcheur authentifié) est garanti côté
/// serveur via le token Bearer — aucun paramètre `demarcheurId` n'est envoyé.
class LoadDemarcheurMapAppartements extends DemarcheurMapEvent {
  final LatLng center;
  final double radiusKm;

  const LoadDemarcheurMapAppartements({
    required this.center,
    this.radiusKm = 10.0,
  });
}

/// Émis après chaque `MapEventMoveEnd` debouncé (300ms) du picker.
/// Le handler émet `DemarcheurMapCenterUpdated` puis chaîne
/// `LoadDemarcheurMapAppartements` pour rafraîchir la zone.
class UpdateDemarcheurMapCenter extends DemarcheurMapEvent {
  final LatLng center;

  const UpdateDemarcheurMapCenter(this.center);
}

/// Recherche textuelle d'un lieu (geocoding backend `/api/map/search`).
/// Au succès, l'UI recentre la carte ; le moveEnd qui s'ensuit déclenche
/// automatiquement `UpdateDemarcheurMapCenter`.
class SearchPlaceDemarcheur extends DemarcheurMapEvent {
  final String query;

  const SearchPlaceDemarcheur(this.query);
}

/// Force un rechargement de la zone courante (vide le cache interne).
class RefreshDemarcheurMap extends DemarcheurMapEvent {
  const RefreshDemarcheurMap();
}

/// Réinitialise le BLoC à `DemarcheurMapInitial` (utile au logout).
class ResetDemarcheurMapState extends DemarcheurMapEvent {
  const ResetDemarcheurMapState();
}
