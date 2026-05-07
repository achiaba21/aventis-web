import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/form/image_uploader.dart';

abstract class AppartementEvent {}

class LoadAppartements extends AppartementEvent {}

class RefreshAppartements extends AppartementEvent {}

class LoadAppartementsByOwner extends AppartementEvent {
  final int proprietaireId;
  LoadAppartementsByOwner(this.proprietaireId);
}

class LoadFilteredAppartements extends AppartementEvent {
  final FilterCriteria criteria;
  LoadFilteredAppartements(this.criteria);
}

class LoadFilterOptions extends AppartementEvent {}

class ClearFilters extends AppartementEvent {}

class LoadProprietaireAppartements extends AppartementEvent {}

/// Rafraîchit les appartements du propriétaire en forçant le rechargement depuis l'API
/// Utilisé pour le pull-to-refresh (scroll vers le bas)
class RefreshProprietaireAppartements extends AppartementEvent {}

/// Met à jour les appartements avec les données fraîches de l'API (cache-first)
class UpdateAppartementsFromApi extends AppartementEvent {
  final List<Appartement> appartements;

  UpdateAppartementsFromApi(this.appartements);
}

// ==================== CRUD ÉVÉNEMENTS (Propriétaire) ====================

/// Crée un nouvel appartement via le Repository
class CreateAppartement extends AppartementEvent {
  final Appartement appartement;
  final List<UploadedImage>? images;
  CreateAppartement(this.appartement, {this.images});
}

/// Met à jour un appartement existant via le Repository
class UpdateAppartement extends AppartementEvent {
  final Appartement appartement;
  final List<UploadedImage>? images;
  final List<String>? photosToDelete; // UUIDs des photos à supprimer
  UpdateAppartement(this.appartement, {this.images, this.photosToDelete});
}

/// Supprime un appartement via le Repository
class DeleteAppartement extends AppartementEvent {
  final int appartementId;
  DeleteAppartement(this.appartementId);
}

// ==================== SYNCHRONISATION ====================

/// Synchronise les appartements depuis une liste préchargée (utilisé pendant
/// le bootstrap pour alimenter AppartementBloc avant l'appel API).
class SyncFromResidences extends AppartementEvent {
  final List<Appartement> appartements;
  SyncFromResidences(this.appartements);
}

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial
/// Utilisé lors d'une nouvelle session utilisateur pour garantir l'affichage des skeletons
class ResetAppartementState extends AppartementEvent {}