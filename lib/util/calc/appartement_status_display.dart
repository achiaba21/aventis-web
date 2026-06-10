import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Helpers d'affichage pour `AppartementStatus`.
///
/// Centralise le mapping enum → libellés et ton de badge, consommés par
/// `ProprioListingEditScreen` (eyebrow AppBar) et les cartes annonces
/// (`ListingFullCardHero`, `ProprioListingRow`).
///
/// Les libellés sont volontairement **neutres** : `HORS_LIGNE` n'est pas
/// étiqueté « Refusée » tant que le backend n'a pas confirmé si ce statut
/// signifie un refus admin ou un masquage volontaire du propriétaire.
class AppartementStatusDisplay {
  AppartementStatusDisplay._();

  /// Libellé eyebrow (consommé tel quel, le widget cible gère la casse).
  static String eyebrowLabel(AppartementStatus? status) {
    switch (status) {
      case AppartementStatus.EN_COURS:
        return 'EN COURS DE VALIDATION';
      case AppartementStatus.EN_LIGNE:
        return 'ANNONCE EN LIGNE';
      case AppartementStatus.HORS_LIGNE:
        return 'ANNONCE HORS LIGNE';
      case AppartementStatus.REFUSER:
        return 'ANNONCE REFUSÉE';
      case null:
        return 'ANNONCE';
    }
  }

  /// Libellé court pour le badge de statut (BadgeStatus met en majuscules).
  static String badgeLabel(AppartementStatus? status) {
    switch (status) {
      case AppartementStatus.EN_COURS:
        return '● En validation';
      case AppartementStatus.EN_LIGNE:
        return '● En ligne';
      case AppartementStatus.HORS_LIGNE:
        return '● Hors ligne';
      case AppartementStatus.REFUSER:
        return '● Refusée';
      case null:
        return '● Annonce';
    }
  }

  /// Ton sémantique du badge de statut.
  static BadgeTone badgeTone(AppartementStatus? status) {
    switch (status) {
      case AppartementStatus.EN_COURS:
        return BadgeTone.warn;
      case AppartementStatus.EN_LIGNE:
        return BadgeTone.success;
      case AppartementStatus.HORS_LIGNE:
        return BadgeTone.neutral;
      case AppartementStatus.REFUSER:
        return BadgeTone.danger;
      case null:
        return BadgeTone.neutral;
    }
  }
}
