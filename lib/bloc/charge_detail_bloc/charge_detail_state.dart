import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';

/// État de base du `ChargeDetailBloc`.
///
/// Pattern "keep last known data" : la charge est conservée à travers les
/// transitions d'état pour éviter les flashs UI.
abstract class ChargeDetailState {
  final Charge? charge;
  ChargeDetailState({this.charge});
}

class ChargeDetailInitial extends ChargeDetailState {
  ChargeDetailInitial();
}

class ChargeDetailLoaded extends ChargeDetailState {
  ChargeDetailLoaded(Charge charge) : super(charge: charge);
}

class ChargeDetailActionInProgress extends ChargeDetailState {
  final ChargeDetailAction action;
  ChargeDetailActionInProgress(this.action, {super.charge});
}

class ChargeDetailActionSuccess extends ChargeDetailState {
  final ChargeDetailAction action;
  ChargeDetailActionSuccess(this.action, {super.charge});
}

class ChargeDetailActionError extends ChargeDetailState {
  final ChargeDetailAction action;
  final String message;
  ChargeDetailActionError(this.action, this.message, {super.charge});
}
