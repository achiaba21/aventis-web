import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/filter/filter_options.dart';

/// État de base pour les appartements
///
/// Pattern "keep last known data" : conserve les appartements connus
/// même pendant les transitions d'état pour éviter les flashs UI
abstract class AppartementState {
  /// Liste des derniers appartements connus (persistée entre les états)
  final List<Appartement> appartements;

  AppartementState({this.appartements = const []});
}

class AppartementInitial extends AppartementState {
  AppartementInitial({super.appartements});
}

class AppartementLoading extends AppartementState {
  AppartementLoading({super.appartements});
}

class AppartementLoaded extends AppartementState {
  AppartementLoaded(List<Appartement> appartements)
      : super(appartements: appartements);
}

class AppartementsByOwnerLoaded extends AppartementState {
  final int proprietaireId;
  AppartementsByOwnerLoaded(List<Appartement> appartements, this.proprietaireId)
      : super(appartements: appartements);
}

class ProprietaireAppartementsLoaded extends AppartementState {
  ProprietaireAppartementsLoaded(List<Appartement> appartements)
      : super(appartements: appartements);
}

class FilteredAppartementsLoaded extends AppartementState {
  final FilterCriteria criteria;
  FilteredAppartementsLoaded(List<Appartement> appartements, this.criteria)
      : super(appartements: appartements);
}

class FilterOptionsLoaded extends AppartementState {
  final FilterOptions options;
  FilterOptionsLoaded(this.options, [List<Appartement>? appartements])
      : super(appartements: appartements ?? const []);
}

/// État émis après une opération CRUD réussie (création, modification, suppression)
/// Contient la liste à jour des appartements du propriétaire
class AppartementOperationSuccess extends AppartementState {
  final String message;
  AppartementOperationSuccess(this.message, List<Appartement> appartements)
      : super(appartements: appartements);
}

class AppartementError extends AppartementState {
  final String message;
  AppartementError(this.message, {super.appartements});
}