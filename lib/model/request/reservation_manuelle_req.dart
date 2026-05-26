import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';

/// DTO pour la création d'une réservation manuelle par le propriétaire.
///
/// Permet d'enregistrer une réservation effectuée en dehors de la plateforme
/// pour un suivi complet des appartements.
///
/// Depuis le 2026-05-15 (feature `calendrier-bookings-proprio`), le payload
/// est étendu avec :
/// - [source] : `CLIENT_DIRECT` ou `DEMARCHEUR_PARTENAIRE`
/// - [moyenPaiement] : tracking proprio (Espèces / Wave / OM / Virement)
/// - [demarcheurId] : requis si `source == demarcheurPartenaire`
/// - [montantCommission] : commission attribuée au démarcheur partenaire
///
/// Coordination backend confirmée 2026-05-18 :
/// - Si `demarcheurId` fourni + partenariat OK → backend crée une
///   `ReservationDemarcheur` (statut FINALISER direct) avec commission
///   attribuée. Si `montantCommission` null/absent → commission = 0.
/// - Si `demarcheurNomExterne` fourni (apporteur hors plateforme, sans
///   compte Asfar) → crée une `ReservationManuelle` enrichie avec
///   les 3 champs externe persistés. Pas de crédit auto, c'est du
///   gré à gré.
/// - Si `demarcheurId` absent ET `demarcheurNomExterne` absent →
///   `ReservationManuelle` classique.
/// - Si `demarcheurId` fourni mais démarcheur non partenaire → 400.
class ReservationManuelleReq {
  /// ID de l'appartement concerné.
  final int appartId;

  /// Date de début de la réservation.
  final DateTime debut;

  /// Durée en jours.
  final int duree;

  /// Nom du client externe.
  final String clientNom;

  /// Téléphone du client externe.
  final String clientTelephone;

  /// Email du client externe (optionnel).
  final String? clientEmail;

  /// Montant total payé par le client.
  final double montant;

  /// Source de la réservation (client direct / démarcheur partenaire).
  ///
  /// Nullable pour préserver les call sites d'édition qui ne touchent pas
  /// à ce champ. Le wizard de création (feature `calendrier-bookings-proprio`)
  /// valide en amont que la source est renseignée avant d'instancier le DTO.
  final ReservationManuelleSource? source;

  /// Moyen de paiement utilisé par le client.
  ///
  /// Nullable pour les mêmes raisons que [source].
  final MoyenPaiement? moyenPaiement;

  /// Identifiant du démarcheur partenaire si applicable.
  final int? demarcheurId;

  /// Commission attribuée au démarcheur partenaire (en FCFA). Si null ou
  /// absent → backend traite comme 0 (le proprio garde tout). Sans plafond
  /// côté serveur : `> montant` est accepté (responsabilité proprio).
  final double? montantCommission;

  /// Nom de l'apporteur externe (hors plateforme — pas de compte Asfar).
  /// Mutuellement exclusif avec [demarcheurId] côté UI ; backend valide.
  final String? demarcheurNomExterne;

  /// Téléphone de l'apporteur externe — optionnel même si [demarcheurNomExterne]
  /// est renseigné.
  final String? demarcheurTelephoneExterne;

  ReservationManuelleReq({
    required this.appartId,
    required this.debut,
    required this.duree,
    required this.clientNom,
    required this.clientTelephone,
    this.clientEmail,
    required this.montant,
    this.source,
    this.moyenPaiement,
    this.demarcheurId,
    this.montantCommission,
    this.demarcheurNomExterne,
    this.demarcheurTelephoneExterne,
  });

  Map<String, dynamic> toJson() => {
        'appartId': appartId,
        'debut': debut.toIso8601String(),
        'dure': duree, // Note: "dure" sans 'e' selon spec serveur historique.
        'clientNom': clientNom,
        'clientTelephone': clientTelephone,
        if (clientEmail != null && clientEmail!.isNotEmpty)
          'clientEmail': clientEmail,
        'montant': montant,
        if (source != null) 'source': source!.value,
        if (moyenPaiement != null) 'moyenPaiement': moyenPaiement!.value,
        if (demarcheurId != null) 'demarcheurId': demarcheurId,
        if (montantCommission != null) 'montantCommission': montantCommission,
        if (demarcheurNomExterne != null && demarcheurNomExterne!.isNotEmpty)
          'demarcheurNomExterne': demarcheurNomExterne,
        if (demarcheurTelephoneExterne != null &&
            demarcheurTelephoneExterne!.isNotEmpty)
          'demarcheurTelephoneExterne': demarcheurTelephoneExterne,
      };

  @override
  String toString() {
    return 'ReservationManuelleReq(appartId: $appartId, debut: $debut, '
        'duree: $duree, clientNom: $clientNom, montant: $montant, '
        'source: ${source?.name}, moyenPaiement: ${moyenPaiement?.name})';
  }
}
