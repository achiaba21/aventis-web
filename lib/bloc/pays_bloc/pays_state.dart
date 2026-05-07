import 'package:asfar/model/locolite/lieux/pays.dart';

/// Classe abstraite représentant tous les états du PaysBloc
abstract class PaysState {}

/// État initial du PaysBloc
class PaysInitial extends PaysState {}

/// État de chargement des pays
class PaysLoading extends PaysState {}

/// État lorsque tous les pays sont chargés
class AllPaysLoaded extends PaysState {
  final List<Pays> paysList;
  AllPaysLoaded(this.paysList);
}

/// État lorsqu'un pays unique est chargé
class SinglePaysLoaded extends PaysState {
  final Pays pays;
  SinglePaysLoaded(this.pays);
}

/// État d'erreur
class PaysError extends PaysState {
  final String message;
  PaysError(this.message);
}
