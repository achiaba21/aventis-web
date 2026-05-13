import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';

/// Events pour le ChargeBloc
abstract class ChargeEvent {}

/// Charger toutes les charges
class LoadCharges extends ChargeEvent {
  final int? appartementId;
  final DateTime? dateDebut;
  final DateTime? dateFin;

  LoadCharges({
    this.appartementId,
    this.dateDebut,
    this.dateFin,
  });
}

/// Rafraîchir les charges (recharger avec les mêmes filtres)
class RefreshCharges extends ChargeEvent {}

/// Ajouter une nouvelle charge.
///
/// `estRecurrent` n'est pas exposé : il est dérivé de `frequence` côté
/// modèle (`Charge.create`) selon l'invariant `ponctuel ⟺ !recurrent`.
class AddCharge extends ChargeEvent {
  final int appartementId;
  final TypeCharge typeCharge;
  final String? libelle;
  final double montant;
  final FrequenceCharge frequence;
  final DateTime? dateDebut;
  final DateTime? dateEcheance;
  final String? notes;

  AddCharge({
    required this.appartementId,
    required this.typeCharge,
    this.libelle,
    required this.montant,
    required this.frequence,
    this.dateDebut,
    this.dateEcheance,
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

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial
/// Utilisé lors de la déconnexion pour nettoyer les données
class ResetChargeState extends ChargeEvent {}
