import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';

/// Événements du `ChargeDetailBloc`.
abstract class ChargeDetailEvent {}

/// Charge initiale depuis l'objet déjà en mémoire (push depuis liste).
class LoadCharge extends ChargeDetailEvent {
  final Charge charge;
  LoadCharge(this.charge);
}

/// Marque la charge courante comme payée.
class MarkPaid extends ChargeDetailEvent {}

/// Annule le paiement (charge re-marquée impayée).
class MarkUnpaid extends ChargeDetailEvent {}

/// Met à jour la charge (depuis formulaire d'édition).
class UpdateChargeAction extends ChargeDetailEvent {
  final Charge updated;
  UpdateChargeAction(this.updated);
}

/// Supprime la charge.
class DeleteChargeAction extends ChargeDetailEvent {}

/// Met à jour silencieusement le state avec une charge fraîche.
class UpdateChargeFromApi extends ChargeDetailEvent {
  final Charge charge;
  UpdateChargeFromApi(this.charge);
}

/// Action générique utilisée par les states (pour mapping uniforme).
abstract class ChargeDetailActionState {
  ChargeDetailAction get action;
}
