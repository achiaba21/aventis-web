import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/filter/filter_options.dart';
import 'package:web_flutter/model/residence/appart.dart';

abstract class AppartementState {}

class AppartementInitial extends AppartementState {}

class AppartementLoading extends AppartementState {}

class AppartementLoaded extends AppartementState {
  List<Appartement> appartements;
  AppartementLoaded(this.appartements);
}

class AppartementsByOwnerLoaded extends AppartementState {
  final List<Appartement> appartements;
  final int proprietaireId;
  AppartementsByOwnerLoaded(this.appartements, this.proprietaireId);
}

class FilteredAppartementsLoaded extends AppartementState {
  final List<Appartement> appartements;
  final FilterCriteria criteria;
  FilteredAppartementsLoaded(this.appartements, this.criteria);
}

class FilterOptionsLoaded extends AppartementState {
  final FilterOptions options;
  final List<Appartement>? appartements;
  FilterOptionsLoaded(this.options, [this.appartements]);
}

class AppartementError extends AppartementState {
  String message;
  AppartementError(this.message);
}