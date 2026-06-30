import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/forms/charge_form_errors.dart';

/// Validation **pure** du formulaire de charge (sans Flutter, testable).
///
/// Règles :
/// - appartement obligatoire ;
/// - montant > 0 (chiffres extraits du texte saisi) ;
/// - date `dateDebut` obligatoire (chaque charge = un paiement effectué) ;
/// - pour les charges récurrentes, l'échéance (si fournie) doit suivre le
///   début.
class ChargeFormValidator {
  ChargeFormValidator._();

  static ChargeFormErrors validate({
    required int? appartementId,
    required String montantText,
    required DateTime? dateDebut,
    required DateTime? dateEcheance,
    required FrequenceCharge frequence,
  }) {
    final montantDigits = montantText.replaceAll(RegExp(r'[^\d]'), '');
    final montant = double.tryParse(montantDigits);
    final montantValide = montant != null && montant > 0;

    String? dateError;
    if (dateDebut == null) {
      dateError = frequence.isPonctuel
          ? 'Indiquez la date du paiement'
          : 'Indiquez la date de début';
    } else if (!frequence.isPonctuel &&
        dateEcheance != null &&
        dateEcheance.isBefore(dateDebut)) {
      dateError = "L'échéance doit être après le début";
    }

    return ChargeFormErrors(
      appartement:
          appartementId == null ? 'Sélectionnez un appartement' : null,
      montant: montantValide ? null : 'Montant invalide',
      date: dateError,
      montantValue: montantValide ? montant : null,
    );
  }
}
