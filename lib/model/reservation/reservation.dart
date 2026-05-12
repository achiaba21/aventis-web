import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/util/function.dart';
import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/avance_reservation.dart';
import 'package:asfar/model/reservation/code_reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';
import 'package:asfar/model/reservation/reservation_plateforme.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/model/user/proprietaire.dart';

enum ReservationStatus {
  enAttente('EN_ATTENTE'),
  confirmee('CONFIRMER'),
  payee('PAYER'),
  finalisee('FINALISER'),
  refusee('REFUSEE'),
  annulee('ANULLE'),
  terminee('TERMINEE');

  const ReservationStatus(this.value);
  final String value;

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere((e) {
      deboger([e.value, value]);
      return e.value == value.toUpperCase();
    }, orElse: () => ReservationStatus.enAttente);
  }
}

/// Réservation côté Flutter — modèle abstrait mirroring l'héritage backend
/// `@Inheritance(strategy = TABLE_PER_CLASS)`.
///
/// Sous-classes (alignées sur backend Java) :
/// - `ReservationPlateforme` : résa créée par un locataire via la plateforme
/// - `ReservationManuelle` : résa enregistrée manuellement par le proprio
///   (client externe, pas dans la base locataires)
/// - `ReservationDemarcheur` : résa créée par un démarcheur pour son client
///   (porte en plus `demarcheur: Demarcheur` et `montantCommission`)
///
/// Le `factory Reservation.fromJson` choisit automatiquement la bonne
/// sous-classe en fonction du champ `type` du payload.
///
/// Note : `proprio` reste défini côté Flutter pour rétro-compat (consommé
/// par `ReferralDetailScreen`) mais le backend actuel ne l'envoie pas —
/// voir `BACKEND_NOTES_FINANCES_PDF.md` pour la demande backend.
abstract class Reservation {
  int? id;
  DateTime? debut;
  DateTime? fin;
  double? prix;
  Appartement? appart;
  MoyenPaiement? moyenPaiement;
  String? reference;
  double? frais;
  Locataire? locataire;
  Proprietaire? proprio;
  AvanceReservation? avanceReservation;
  ReservationStatus? statut;
  DateTime? createdAt;
  CodeReservation? codeReservation;
  String? motif;

  ReservationType? type;
  String? clientExterneNom;
  String? clientExterneTelephone;
  String? clientExterneEmail;

  Reservation();

  /// Constructeur nommé partagé par les sous-classes pour parser les champs
  /// communs depuis JSON. Les sous-classes y ajoutent leurs spécifiques.
  Reservation.fromJsonCommon(Map<String, dynamic> json) {
    id = json['id'];
    debut = json['debut'] != null ? DateTime.parse(json['debut']) : null;
    fin = json['fin'] != null ? DateTime.parse(json['fin']) : null;
    prix = json['prix']?.toDouble();
    appart =
        json['appart'] != null ? Appartement.fromJson(json['appart']) : null;
    moyenPaiement = json['moyenPaiement'] != null
        ? MoyenPaiement.fromString(json['moyenPaiement'])
        : null;
    reference = json['reference'];
    frais = json['frais']?.toDouble();
    proprio = json['proprio'] != null
        ? Proprietaire.fromJson(json['proprio'])
        : null;
    avanceReservation = json['avanceReservation'] != null
        ? AvanceReservation.fromJson(json['avanceReservation'])
        : null;
    locataire = json['locataire'] != null
        ? Locataire.fromJson(json['locataire'])
        : null;
    statut = json['statut'] != null
        ? ReservationStatus.fromString(json['statut'])
        : null;
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    motif = json['motif'];
    type = json['type'] != null
        ? ReservationType.fromString(json['type'])
        : null;
    clientExterneNom = json['clientExterneNom'];
    clientExterneTelephone = json['clientExterneTelephone'];
    clientExterneEmail = json['clientExterneEmail'];
  }

  /// Factory polymorphique : retourne la sous-classe correspondant au champ
  /// `type` du payload backend.
  factory Reservation.fromJson(Map<String, dynamic> json) {
    final t = (json['type'] as String?)?.toUpperCase();
    switch (t) {
      case 'DEMARCHEUR':
        return ReservationDemarcheur.fromJson(json);
      case 'MANUELLE':
        return ReservationManuelle.fromJson(json);
      case 'PLATEFORME':
      default:
        return ReservationPlateforme.fromJson(json);
    }
  }

  /// Indique si c'est une réservation manuelle (client externe).
  bool get isManuelle => type == ReservationType.manuelle;

  /// Nom du client (locataire plateforme ou client externe).
  String? get clientNom => isManuelle
      ? clientExterneNom
      : '${locataire?.prenom ?? ''} ${locataire?.nom ?? ''}'.trim();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['debut'] = debut?.toIso8601String();
    data['fin'] = fin?.toIso8601String();
    data['prix'] = prix;
    data['appart'] = appart?.toJson();
    if (moyenPaiement != null) {
      data['moyenPaiement'] = moyenPaiement!.toJson();
    }
    data['reference'] = reference;
    data['frais'] = frais;
    if (proprio != null) data['proprio'] = proprio!.toJson();
    if (locataire != null) data['locataire'] = locataire!.toJson();
    if (avanceReservation != null) {
      data['avanceReservation'] = avanceReservation!.toJson();
    }
    if (statut != null) data['statut'] = statut!.value;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (codeReservation != null) {
      data['codeReservation'] = codeReservation!.toJson();
    }
    if (motif != null) data['motif'] = motif;
    if (type != null) data['type'] = type!.value;
    if (clientExterneNom != null) data['clientExterneNom'] = clientExterneNom;
    if (clientExterneTelephone != null) {
      data['clientExterneTelephone'] = clientExterneTelephone;
    }
    if (clientExterneEmail != null) {
      data['clientExterneEmail'] = clientExterneEmail;
    }
    return data;
  }

  DateTimeRange get plage => DateTimeRange(
        start: (debut ?? DateTime.now()).copyWith(hour: 0),
        end: (fin ?? DateTime.now()).copyWith(hour: 23),
      );
}
