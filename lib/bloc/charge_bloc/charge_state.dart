import 'package:asfar/model/comptabilite/charge.dart';

/// States pour le ChargeBloc
///
/// Pattern "keep last known data" : conserve les charges connues
/// même pendant les transitions d'état pour éviter les flashs UI
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
  final int? residenceId;
  final int? appartementId;
  final DateTime? dateDebut;
  final DateTime? dateFin;

  ChargeLoaded({
    required List<Charge> charges,
    this.residenceId,
    this.appartementId,
    this.dateDebut,
    this.dateFin,
  }) : super(charges: charges);

  /// Copie avec modifications
  ChargeLoaded copyWith({
    List<Charge>? charges,
    int? residenceId,
    bool clearResidenceId = false,
    int? appartementId,
    bool clearAppartementId = false,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) {
    return ChargeLoaded(
      charges: charges ?? this.charges,
      residenceId: clearResidenceId ? null : (residenceId ?? this.residenceId),
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
    if (residenceId != null) {
      return charges.where((c) => c.residenceId == residenceId).toList();
    }
    return charges;
  }

  /// Charges en retard
  List<Charge> get chargesEnRetard {
    return charges.where((c) => c.estEnRetard).toList();
  }

  /// Charges avec échéance proche (7 jours)
  List<Charge> get chargesEcheanceProche {
    return charges.where((c) => c.echeanceProche).toList();
  }

  /// Toutes les alertes (en retard + échéance proche)
  List<Charge> get alertes {
    final Set<int?> ids = {};
    final result = <Charge>[];

    // D'abord les retards (plus urgent)
    for (final c in chargesEnRetard) {
      if (!ids.contains(c.id)) {
        ids.add(c.id);
        result.add(c);
      }
    }

    // Ensuite les échéances proches
    for (final c in chargesEcheanceProche) {
      if (!ids.contains(c.id)) {
        ids.add(c.id);
        result.add(c);
      }
    }

    return result;
  }

  /// Nombre d'alertes
  int get nombreAlertes => alertes.length;

  /// A des alertes urgentes (en retard)
  bool get hasAlertesUrgentes => chargesEnRetard.isNotEmpty;
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
