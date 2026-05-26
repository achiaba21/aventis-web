import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_counted.dart';

/// Statuts d'une référence démarcheur — UI uniquement.
///
/// Aligne sur les 4 chips de filtre du proto (`app.jsx::ReferralsScreen`) :
/// En attente / Acceptées / Terminées / Refusées.
enum ReferralStatus { pending, accepted, completed, refused }

/// Extension de présentation sur `Reservation` côté démarcheur — usage UI.
///
/// Une `Reservation` créée par un démarcheur pour son client est ce que les
/// écrans démarcheur appellent une « référence ». Les getters ci-dessous
/// dérivent les libellés/statuts/montants directement depuis la `Reservation`.
extension ReferralDisplay on Reservation {
  ReferralStatus get referralStatus {
    switch (statut) {
      case ReservationStatus.confirmee:
      case ReservationStatus.payee:
        return ReferralStatus.accepted;
      case ReservationStatus.finalisee:
      case ReservationStatus.terminee:
        return ReferralStatus.completed;
      case ReservationStatus.refusee:
      case ReservationStatus.annulee:
        return ReferralStatus.refused;
      case ReservationStatus.enAttente:
      case null:
        return ReferralStatus.pending;
    }
  }

  int get referralNights {
    final d = debut;
    final f = fin;
    if (d == null || f == null) return 1;
    final diff = f.difference(d).inDays;
    return diff > 0 ? diff : 1;
  }

  int get referralCommissionAmount => demarcheurCommissionAmount.round();

  /// Sous-total séjour (prix de la résa, qui correspond à nuits × prixNuit).
  int get referralSubtotal => (prix ?? 0).round();

  /// True si le client de cette réservation doit rester confidentiel pour
  /// le démarcheur (R4 : réservation MANUELLE → client externe du proprio,
  /// infos personnelles non partagées avec le démarcheur).
  bool get isClientConfidential => type == ReservationType.manuelle;

  String get referralClientName {
    if (isClientConfidential) return 'Client confidentiel';
    final base = clientNom?.trim().isNotEmpty == true
        ? clientNom!
        : 'Client #${id ?? 0}';
    return base;
  }

  String get referralClientPhone {
    if (isClientConfidential) return '';
    return clientExterneTelephone ?? locataire?.telephone ?? '';
  }

  /// Identifiant affiché (codeReservation > reference > REF-id).
  String get referralIdLabel {
    return codeReservation?.secretKey ?? reference ?? 'REF-${id ?? 0}';
  }
}
