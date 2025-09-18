import 'package:web_flutter/model/filter/filter_criteria.dart';

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