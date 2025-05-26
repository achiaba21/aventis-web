import 'package:flutter/material.dart';
import 'package:web_flutter/model/reservation/avance_reservation.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/model/user/locataire.dart';
import 'package:web_flutter/model/user/proprietaire.dart';

class Reservation {
  int? id;
  DateTime? debut;
  DateTime? fin;
  double? prix;
  Appartement? appart;
  String? numeroCompte;
  String? moyenPaiement;
  String? reference;
  double? frais;
  Locataire? locataire;
  Proprietaire? proprio;
  AvanceReservation? avanceReservation;

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
  });

  Reservation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    debut = json['debut'] != null ? DateTime.parse(json['debut']) : null;
    fin = json['fin'] != null ? DateTime.parse(json['fin']) : null;
    prix = json['prix'];
    appart =
        json['appart'] != null ? Appartement.fromJson(json['appart']) : null;
    numeroCompte = json['numeroCompte'];
    moyenPaiement = json['moyenPaiement'];
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
      data['moyenPaiement'] = moyenPaiement!;
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
    return data;
  }

  DateTimeRange get plage =>
      DateTimeRange(start: debut ?? DateTime.now(), end: fin ?? DateTime.now());
}
