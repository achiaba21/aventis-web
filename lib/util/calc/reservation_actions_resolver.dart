import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';

/// Rôle du user courant vis-à-vis de la réservation consultée.
enum ReservationViewerRole {
  locataire,
  proprietaire,
  demarcheur,
}

/// Résout la liste des actions affichables sur la page de détail
/// pour `(rôle, statut, type)` donné.
///
/// Source unique de la matrice §5.2 de la spec métier. Helper pur, testable.
class ReservationActionsResolver {
  ReservationActionsResolver._();

  static List<ReservationDetailAction> actionsFor({
    required ReservationViewerRole role,
    required Reservation reservation,
  }) {
    final statut = reservation.statut;
    if (statut == null) {
      return const [ReservationDetailAction.contact];
    }

    switch (role) {
      case ReservationViewerRole.locataire:
        return _forLocataire(statut);
      case ReservationViewerRole.proprietaire:
        return _forProprio(reservation, statut);
      case ReservationViewerRole.demarcheur:
        return const [ReservationDetailAction.contact];
    }
  }

  static List<ReservationDetailAction> _forLocataire(
    ReservationStatus statut,
  ) {
    switch (statut) {
      case ReservationStatus.enAttente:
        return const [
          ReservationDetailAction.cancel,
          ReservationDetailAction.contact,
        ];
      case ReservationStatus.confirmee:
        return const [
          ReservationDetailAction.pay,
          ReservationDetailAction.cancel,
          ReservationDetailAction.contact,
        ];
      case ReservationStatus.payee:
      case ReservationStatus.finalisee:
        return const [
          ReservationDetailAction.viewQr,
          ReservationDetailAction.contact,
        ];
      case ReservationStatus.terminee:
      case ReservationStatus.refusee:
      case ReservationStatus.annulee:
        return const [ReservationDetailAction.contact];
    }
  }

  static List<ReservationDetailAction> _forProprio(
    Reservation r,
    ReservationStatus statut,
  ) {
    final isManuelle = r is ReservationManuelle;

    switch (statut) {
      case ReservationStatus.enAttente:
        if (isManuelle) {
          return const [
            ReservationDetailAction.edit,
            ReservationDetailAction.cancel,
            ReservationDetailAction.contact,
          ];
        }
        return const [
          ReservationDetailAction.confirm,
          ReservationDetailAction.refuse,
          ReservationDetailAction.contact,
        ];
      case ReservationStatus.confirmee:
        if (isManuelle) {
          // Manuelle confirmée = argent encaissé (paiement hors plateforme).
          // Édition verrouillée pour cohérence avec RM4. Annulation possible
          // si remboursement négocié hors-app.
          return const [
            ReservationDetailAction.cancel,
            ReservationDetailAction.contact,
          ];
        }
        return const [ReservationDetailAction.contact];
      case ReservationStatus.payee:
        return const [
          ReservationDetailAction.scanQr,
          ReservationDetailAction.contact,
        ];
      case ReservationStatus.finalisee:
      case ReservationStatus.terminee:
      case ReservationStatus.refusee:
      case ReservationStatus.annulee:
        return const [ReservationDetailAction.contact];
    }
  }

  /// Libellé d'affichage de l'action (français, sans icône).
  static String labelOf(ReservationDetailAction action) {
    switch (action) {
      case ReservationDetailAction.cancel:
        return 'Annuler';
      case ReservationDetailAction.pay:
        return 'Payer maintenant';
      case ReservationDetailAction.confirm:
        return 'Confirmer';
      case ReservationDetailAction.refuse:
        return 'Refuser';
      case ReservationDetailAction.viewQr:
        return 'Présenter mon code';
      case ReservationDetailAction.scanQr:
        return 'Scanner le code';
      case ReservationDetailAction.edit:
        return 'Modifier';
      case ReservationDetailAction.contact:
        return 'Contacter';
    }
  }
}
