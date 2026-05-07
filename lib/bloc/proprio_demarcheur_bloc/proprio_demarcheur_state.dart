import 'package:asfar/model/user/demarcheur.dart';

abstract class ProprietaireDemarcheurState {}

class ProprietaireDemarcheurInitial extends ProprietaireDemarcheurState {}

class ProprietaireDemarcheurLoading extends ProprietaireDemarcheurState {}

class DemarchemursLoaded extends ProprietaireDemarcheurState {
  final List<Demarcheur> demarcheurs;

  DemarchemursLoaded(this.demarcheurs);
}

class DemarcheurLinkSuccess extends ProprietaireDemarcheurState {
  final String message;

  DemarcheurLinkSuccess(this.message);
}

class DemarcheurUnlinkSuccess extends ProprietaireDemarcheurState {}

class ProprietaireDemarcheurError extends ProprietaireDemarcheurState {
  final String message;

  ProprietaireDemarcheurError(this.message);
}
