import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/forms/uploaded_image.dart';

/// Events du `AppartementBloc`.
///
/// Le filtrage (`LoadFilteredAppartements`, `LoadFilterOptions`, `ClearFilters`)
/// a été déplacé vers `AppartementFilterCubit` dédié — voir
/// `lib/bloc/appartement_filter_cubit/`.
abstract class AppartementEvent {}

// ==================== CHARGEMENT ====================

/// Charge le feed locataire (endpoint public, cache-first via Repository).
class LoadAppartements extends AppartementEvent {}

/// Rafraîchit le feed locataire en forçant l'appel API.
class RefreshAppartements extends AppartementEvent {}

/// Charge les appartements d'un propriétaire spécifique.
class LoadAppartementsByOwner extends AppartementEvent {
  final int proprietaireId;
  LoadAppartementsByOwner(this.proprietaireId);
}

/// Charge les appartements du propriétaire connecté (mes biens).
class LoadProprietaireAppartements extends AppartementEvent {}

/// Rafraîchit les appartements du propriétaire en forçant l'API.
class RefreshProprietaireAppartements extends AppartementEvent {}

/// Met à jour les appartements avec les données fraîches de l'API (cache-first).
class UpdateAppartementsFromApi extends AppartementEvent {
  final List<Appartement> appartements;
  UpdateAppartementsFromApi(this.appartements);
}

// ==================== CRUD (Propriétaire) ====================

/// Crée un nouvel appartement via le Repository.
class CreateAppartement extends AppartementEvent {
  final Appartement appartement;
  final List<UploadedImage>? images;
  CreateAppartement(this.appartement, {this.images});
}

/// Met à jour un appartement existant via le Repository.
class UpdateAppartement extends AppartementEvent {
  final Appartement appartement;
  final List<UploadedImage>? images;
  final List<String>? photosToDelete;
  UpdateAppartement(this.appartement, {this.images, this.photosToDelete});
}

/// Supprime un appartement via le Repository.
class DeleteAppartement extends AppartementEvent {
  final int appartementId;
  DeleteAppartement(this.appartementId);
}

// ==================== MODÉRATION (Propriétaire) ====================

/// Met une annonce du proprio hors ligne (EN_LIGNE → HORS_LIGNE).
class MettreHorsLigneAppartement extends AppartementEvent {
  final int appartementId;
  MettreHorsLigneAppartement(this.appartementId);
}

/// Remet une annonce du proprio en ligne (HORS_LIGNE → EN_LIGNE).
class RemettreEnLigneAppartement extends AppartementEvent {
  final int appartementId;
  RemettreEnLigneAppartement(this.appartementId);
}

/// Resoumet une annonce refusée à la modération (REFUSER → EN_COURS).
class ResoumetreAppartement extends AppartementEvent {
  final int appartementId;
  ResoumetreAppartement(this.appartementId);
}

/// Push temps réel : l'admin a changé le statut d'une annonce
/// (canal `/user/queue/updates`). Patche le statut de l'item dans la liste
/// courante, sans refetch.
class AppartementStatusPushed extends AppartementEvent {
  final int? appartementId;
  final String? nouveauStatus;
  AppartementStatusPushed(this.appartementId, this.nouveauStatus);
}

// ==================== SYNCHRONISATION ====================

/// Synchronise les appartements depuis une liste préchargée (bootstrap).
class SyncFromResidences extends AppartementEvent {
  final List<Appartement> appartements;
  SyncFromResidences(this.appartements);
}

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial (nouvelle session user).
class ResetAppartementState extends AppartementEvent {}
