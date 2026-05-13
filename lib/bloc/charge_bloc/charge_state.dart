import 'package:asfar/model/comptabilite/charge.dart';

/// States pour le ChargeBloc.
///
/// Pattern "keep last known data" : conserve les charges connues
/// même pendant les transitions d'état pour éviter les flashs UI.
///
/// Sémantique post-2026-05-13 : chaque charge en base = un paiement déjà
/// effectué. Les helpers `chargesEnRetard` / `chargesEcheanceProche` /
/// `alertes` ont été retirés (le backend ne renvoie plus `aVenir` que pour
/// les prochaines occurrences récurrentes, géré ailleurs si besoin).
abstract class ChargeState {
  /// Liste des dernières charges connues (persistée entre les états)
  final List<Charge> charges;

  ChargeState({this.charges = const []});
}

/// État initial
class ChargeInitial extends ChargeState {
  ChargeInitial({super.charges});
}

/// Chargement en cours
class ChargeLoading extends ChargeState {
  ChargeLoading({super.charges});
}

/// Charges chargées avec succès
class ChargeLoaded extends ChargeState {
  /// Filtres actuels (pour permettre le refresh)
  final int? appartementId;
  final DateTime? dateDebut;
  final DateTime? dateFin;

  ChargeLoaded({
    required super.charges,
    this.appartementId,
    this.dateDebut,
    this.dateFin,
  });

  /// Copie avec modifications
  ChargeLoaded copyWith({
    List<Charge>? charges,
    int? appartementId,
    bool clearAppartementId = false,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) {
    return ChargeLoaded(
      charges: charges ?? this.charges,
      appartementId: clearAppartementId ? null : (appartementId ?? this.appartementId),
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
    );
  }

  /// Charges filtrées par appartement (si appartementId est défini)
  List<Charge> get chargesFiltrees {
    if (appartementId != null) {
      return charges.where((c) => c.appartementId == appartementId).toList();
    }
    return charges;
  }
}

/// Erreur lors du chargement
class ChargeError extends ChargeState {
  final String message;

  ChargeError({required this.message, super.charges});
}

/// Opération réussie (ajout, modification, suppression)
class ChargeOperationSuccess extends ChargeState {
  final String message;
  final ChargeLoaded previousState;

  ChargeOperationSuccess({
    required this.message,
    required this.previousState,
  }) : super(charges: previousState.charges);
}
