/// Source d'une réservation manuelle (créée par le proprio, hors plateforme Asfar).
///
/// 2 sources possibles côté UI proprio :
/// - `clientDirect` : pas d'apporteur, pas de commission
/// - `apporteurExterne` : un apporteur d'affaires hors plateforme (pas de
///   compte Asfar) a référé le client → le proprio renseigne nom/téléphone
///   et la commission qu'il a négociée en gré à gré.
///
/// **Note importante :** le formulaire de résa manuelle ne propose **pas**
/// d'attribution à un démarcheur Asfar avec compte plateforme. Si le
/// démarcheur a un compte, il crée lui-même la demande via son écran
/// « Nouvelle demande » (flow `POST /api/demarcheur/reservations`).
///
/// La source n'est qu'un état UI : le backend ne lit pas le champ `source`
/// pour distinguer apporteur externe vs client direct — il s'appuie sur la
/// présence ou non du champ `demarcheurNomExterne` dans le payload.
enum ReservationManuelleSource {
  clientDirect('CLIENT_DIRECT'),
  apporteurExterne('APPORTEUR_EXTERNE');

  const ReservationManuelleSource(this.value);

  /// Valeur sérialisée backend.
  final String value;

  /// Libellé utilisateur (français).
  String get label {
    switch (this) {
      case ReservationManuelleSource.clientDirect:
        return 'Client direct';
      case ReservationManuelleSource.apporteurExterne:
        return "Apporteur d'affaires (hors plateforme)";
    }
  }

  /// Sous-titre descriptif.
  String get description {
    switch (this) {
      case ReservationManuelleSource.clientDirect:
        return 'Pas de commission';
      case ReservationManuelleSource.apporteurExterne:
        return 'Commission tracée pour la compta proprio';
    }
  }

  /// Taux de commission suggéré par défaut (10% pour un apporteur, modifiable).
  double get commissionRate {
    switch (this) {
      case ReservationManuelleSource.clientDirect:
        return 0.0;
      case ReservationManuelleSource.apporteurExterne:
        return 0.10;
    }
  }

  /// Indique si la source requiert la saisie d'un apporteur externe (nom + tel).
  bool get requiresApporteurExterne =>
      this == ReservationManuelleSource.apporteurExterne;

  /// Compat héritée — anciennement `requiresDemarcheur`. Conservé pour les
  /// call sites de validation pas encore migrés.
  bool get requiresDemarcheur => requiresApporteurExterne;

  static ReservationManuelleSource? fromBackend(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final source in values) {
      if (source.value == raw) return source;
    }
    return null;
  }
}
