import 'package:asfar/widget/badge/badge_tone.dart';

/// Statut de modération d'une pièce d'identité (KYC), aligné sur les valeurs
/// backend `EN_ATTENTE` / `VERIFIER` / `REFUSER`.
enum DocumentStatus { enAttente, verifier, refuser }

extension DocumentStatusX on DocumentStatus {
  /// Mappe la valeur backend (`etats`) vers l'enum. Insensible à la casse ;
  /// toute valeur inconnue/null retombe sur [DocumentStatus.enAttente].
  static DocumentStatus fromBackend(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'VERIFIER':
        return DocumentStatus.verifier;
      case 'REFUSER':
        return DocumentStatus.refuser;
      case 'EN_ATTENTE':
      default:
        return DocumentStatus.enAttente;
    }
  }

  /// Libellé court affichable (badge, statut).
  String get label {
    switch (this) {
      case DocumentStatus.verifier:
        return 'Vérifié';
      case DocumentStatus.refuser:
        return 'Refusé';
      case DocumentStatus.enAttente:
        return 'En attente';
    }
  }

  /// Ton de badge associé (réutilise le design system).
  BadgeTone get tone {
    switch (this) {
      case DocumentStatus.verifier:
        return BadgeTone.success;
      case DocumentStatus.refuser:
        return BadgeTone.danger;
      case DocumentStatus.enAttente:
        return BadgeTone.warn;
    }
  }
}
