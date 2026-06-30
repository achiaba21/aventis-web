import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';

/// Données **validées** issues du formulaire de charge (`ChargeFormBody`),
/// transmises à l'écran pour dispatch vers le BLoC.
///
/// Toutes les valeurs sont déjà normalisées : [montant] > 0, [dateDebut] non
/// nulle (date du paiement requise), libellés/notes vides ramenés à `null`.
class ChargeFormData {
  final int appartementId;
  final TypeCharge typeCharge;
  final String? libelle;
  final double montant;
  final FrequenceCharge frequence;
  final DateTime dateDebut;
  final DateTime? dateEcheance;
  final String? notes;

  const ChargeFormData({
    required this.appartementId,
    required this.typeCharge,
    required this.libelle,
    required this.montant,
    required this.frequence,
    required this.dateDebut,
    required this.dateEcheance,
    required this.notes,
  });
}
