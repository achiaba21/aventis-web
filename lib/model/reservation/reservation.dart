import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/util/function.dart';
import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/avance_reservation.dart';
import 'package:asfar/model/reservation/code_reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/model/user/proprietaire.dart';

enum ReservationStatus {
  enAttente('EN_ATTENTE'),
  confirmee('CONFIRMER'),
  payee('PAYER'), // Correspond au serveur: PAYER
  finalisee('FINALISER'), // Correspond au serveur: FINALISER
  refusee('REFUSEE'),
  annulee('ANULLE'), // Correspond au serveur: ANULLE
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

class Reservation {
  int? id;
  DateTime? debut;
  DateTime? fin;
  double? prix;
  Appartement? appart;
  String? numeroCompte;
  MoyenPaiement? moyenPaiement;
  String? reference;
  double? frais;
  Locataire? locataire;
  Proprietaire? proprio;
  AvanceReservation? avanceReservation;
  ReservationStatus? statut;
  DateTime? createdAt;
  CodeReservation? codeReservation;

  double? montantCommission;

  // Champs pour les réservations manuelles
  ReservationType? type;
  String? clientExterneNom;
  String? clientExterneTelephone;
  String? clientExterneEmail;

  Reservation({
    this.id,
    this.debut,
    this.fin,
    this.prix,
    this.appart,
    this.numeroCompte,
    this.moyenPaiement,
    this.reference,
    this.frais,
    this.proprio,
    this.avanceReservation,
    this.statut,
    this.createdAt,
    this.codeReservation,
    this.montantCommission,
    this.type,
    this.clientExterneNom,
    this.clientExterneTelephone,
    this.clientExterneEmail,
  });

  /// Indique si c'est une réservation manuelle
  bool get isManuelle => type == ReservationType.manuelle;

  /// Nom du client (locataire plateforme ou client externe)
  String? get clientNom => isManuelle
      ? clientExterneNom
      : '${locataire?.prenom ?? ''} ${locataire?.nom ?? ''}'.trim();

  Reservation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    debut = json['debut'] != null ? DateTime.parse(json['debut']) : null;
    fin = json['fin'] != null ? DateTime.parse(json['fin']) : null;
    prix = json['prix'];
    appart =
        json['appart'] != null ? Appartement.fromJson(json['appart']) : null;
    numeroCompte = json['numeroCompte'];
    moyenPaiement =
        json['moyenPaiement'] != null
            ? MoyenPaiement.fromString(json['moyenPaiement'])
            : null;
    reference = json['reference'];
    frais = json['frais'];
    proprio =
        json['proprio'] != null ? Proprietaire.fromJson(json['proprio']) : null;
    avanceReservation =
        json['avanceReservation'] != null
            ? AvanceReservation.fromJson(json['avanceReservation'])
            : null;
    locataire =
        json['locataire'] != null
            ? Locataire.fromJson(json['locataire'])
            : null;
    statut =
        json['statut'] != null
            ? ReservationStatus.fromString(json['statut'])
            : null;
    createdAt =
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    // Note: codeReservation n'est pas inclus dans la réponse du serveur
    // Il doit être chargé séparément via l'endpoint dédié

    montantCommission = (json['montantCommission'] as num?)?.toDouble();

    // Champs pour les réservations manuelles
    type = json['type'] != null
        ? ReservationType.fromString(json['type'])
        : null;
    clientExterneNom = json['clientExterneNom'];
    clientExterneTelephone = json['clientExterneTelephone'];
    clientExterneEmail = json['clientExterneEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['debut'] = debut?.toIso8601String();
    data['fin'] = fin?.toIso8601String();
    data['prix'] = prix;
    data['appart'] = appart?.toJson();
    data['numeroCompte'] = numeroCompte;
    if (moyenPaiement != null) {
      data['moyenPaiement'] = moyenPaiement!.toJson();
    }
    data['reference'] = reference;
    data['frais'] = frais;
    if (proprio != null) {
      data['proprio'] = proprio!.toJson();
    }
    if (locataire != null) data['locataire'] = locataire!.toJson();
    if (avanceReservation != null) {
      data['avanceReservation'] = avanceReservation!.toJson();
    }
    if (statut != null) {
      data['statut'] = statut!.value;
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt!.toIso8601String();
    }
    if (codeReservation != null) {
      data['codeReservation'] = codeReservation!.toJson();
    }
    if (montantCommission != null) {
      data['montantCommission'] = montantCommission;
    }
    // Champs pour les réservations manuelles
    if (type != null) {
      data['type'] = type!.value;
    }
    if (clientExterneNom != null) {
      data['clientExterneNom'] = clientExterneNom;
    }
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
