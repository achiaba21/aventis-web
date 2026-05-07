import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';

/// Events pour le ChargeBloc
abstract class ChargeEvent {}

/// Charger toutes les charges
class LoadCharges extends ChargeEvent {
  final int? residenceId;
  final int? appartementId;
  final DateTime? dateDebut;
  final DateTime? dateFin;

  LoadCharges({
    this.residenceId,
    this.appartementId,
    this.dateDebut,
    this.dateFin,
  });
}

/// Rafraîchir les charges (recharger avec les mêmes filtres)
class RefreshCharges extends ChargeEvent {}

/// Ajouter une nouvelle charge
class AddCharge extends ChargeEvent {
  final int appartementId;
  final TypeCharge typeCharge;
  final String? libelle;
  final double montant;
  final FrequenceCharge frequence;
  final DateTime? dateDebut;
  final DateTime? dateEcheance;
  final bool estRecurrent;
  final String? notes;

  AddCharge({
    required this.appartementId,
    required this.typeCharge,
    this.libelle,
    required this.montant,
    required this.frequence,
    this.dateDebut,
    this.dateEcheance,
    this.estRecurrent = false,
    this.notes,
  });
}

/// Mettre à jour une charge existante
class UpdateCharge extends ChargeEvent {
  final Charge charge;

  UpdateCharge({required this.charge});
}

/// Supprimer une charge
class DeleteCharge extends ChargeEvent {
  final int chargeId;

  DeleteCharge({required this.chargeId});
}

/// Marquer une charge comme payée
class MarkChargeAsPaid extends ChargeEvent {
  final int chargeId;
  final DateTime? datePaiement;

  MarkChargeAsPaid({
    required this.chargeId,
    this.datePaiement,
  });
}

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial
/// Utilisé lors de la déconnexion pour nettoyer les données
class ResetChargeState extends ChargeEvent {}
