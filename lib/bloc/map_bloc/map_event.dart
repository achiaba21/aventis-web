import 'package:latlong2/latlong.dart';
import 'package:asfar/model/filter/filter_criteria.dart';

abstract class MapEvent {
  const MapEvent();
}

/// Charge les appartements visibles dans une zone, avec filtres optionnels.
class LoadFilteredMapAppartements extends MapEvent {
  final LatLng center;
  final double radiusKm;
  final FilterCriteria? filter;

  const LoadFilteredMapAppartements({
    required this.center,
    this.radiusKm = 10.0,
    this.filter,
  });
}

/// Sélectionne un appartement dans le cache courant (préparation UI).
class SelectMapAppartement extends MapEvent {
  final int appartementId;

  const SelectMapAppartement(this.appartementId);
}

/// Recharge l'appartement courant depuis le backend (refresh forcé).
class LoadAppartementDetails extends MapEvent {
  final int appartementId;

  const LoadAppartementDetails(this.appartementId);
}

class UpdateMapCenter extends MapEvent {
  final LatLng center;

  const UpdateMapCenter(this.center);
}

class UpdateMapFilter extends MapEvent {
  final FilterCriteria? filter;

  const UpdateMapFilter(this.filter);
}

class RefreshMapData extends MapEvent {
  const RefreshMapData();
}

class ClearMapSelection extends MapEvent {
  const ClearMapSelection();
}

/// Demande les coordonnées réelles d'un appartement (post-réservation).
///
/// Le backend vérifie la réservation côté serveur ; sans réservation valide
/// la réponse est `null` (UI conserve les coords obfusquées).
class RequestRealLocation extends MapEvent {
  final int appartementId;

  const RequestRealLocation(this.appartementId);
}

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial.
/// Utilisé lors de la déconnexion pour nettoyer les données.
class ResetMapState extends MapEvent {
  const ResetMapState();
}
