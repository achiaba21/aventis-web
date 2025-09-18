import 'package:flutter/material.dart';
import 'package:web_flutter/model/booking/booking_status.dart';
import 'package:web_flutter/model/enumeration/moyen_paiement.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/model/user/user.dart';

class Booking {
  int? id;
  Appartement? appartement;
  DateTimeRange? plage;
  BookingStatus? status;
  MoyenPaiement? moyenPaiement;
  double? prixTotal;
  double? prixParNuit;
  int? nombreJours;
  User? client;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? motifRefus;

  Booking({
    this.id,
    this.appartement,
    this.plage,
    this.status,
    this.moyenPaiement,
    this.prixTotal,
    this.prixParNuit,
    this.nombreJours,
    this.client,
    this.createdAt,
    this.updatedAt,
    this.motifRefus,
  });

  static Booking fromJsonAll(Map<String, dynamic> json) {
    return Booking.fromJson(json);
  }

  Booking.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appartement = json['appartement'] != null
        ? Appartement.fromJsonAll(json['appartement'])
        : null;

    // Conversion des dates en DateTimeRange
    if (json['dateDebut'] != null && json['dateFin'] != null) {
      final dateDebut = DateTime.parse(json['dateDebut']);
      final dateFin = DateTime.parse(json['dateFin']);
      plage = DateTimeRange(start: dateDebut, end: dateFin);
    }

    status = json['status'] != null
        ? BookingStatusExtension.fromString(json['status'])
        : null;

    // Conversion du moyen de paiement
    moyenPaiement = json['moyenPaiement'] != null
        ? _moyenPaiementFromString(json['moyenPaiement'])
        : null;

    prixTotal = json['prixTotal']?.toDouble();
    prixParNuit = json['prixParNuit']?.toDouble();
    nombreJours = json['nombreJours'];

    client = json['client'] != null
        ? User.fromJsonAll(json['client'])
        : null;

    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null;
    updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null;
    motifRefus = json['motifRefus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    if (appartement != null) {
      data['appartement'] = appartement!.toJson();
    }

    if (plage != null) {
      data['dateDebut'] = plage!.start.toIso8601String();
      data['dateFin'] = plage!.end.toIso8601String();
    }

    if (status != null) {
      data['status'] = status!.value;
    }

    if (moyenPaiement != null) {
      data['moyenPaiement'] = _moyenPaiementToString(moyenPaiement!);
    }

    data['prixTotal'] = prixTotal;
    data['prixParNuit'] = prixParNuit;
    data['nombreJours'] = nombreJours;

    if (client != null) {
      data['client'] = client!.toJson();
    }

    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    data['motifRefus'] = motifRefus;

    return data;
  }

  // Méthodes utilitaires pour MoyenPaiement
  static MoyenPaiement _moyenPaiementFromString(String value) {
    switch (value) {
      case 'OM':
        return MoyenPaiement.OM;
      case 'MOOV_MONNEY':
        return MoyenPaiement.MOOV_MONNEY;
      case 'MOMO':
        return MoyenPaiement.MOMO;
      case 'WAVE':
        return MoyenPaiement.WAVE;
      default:
        return MoyenPaiement.OM;
    }
  }

  static String _moyenPaiementToString(MoyenPaiement moyen) {
    switch (moyen) {
      case MoyenPaiement.OM:
        return 'OM';
      case MoyenPaiement.MOOV_MONNEY:
        return 'MOOV_MONNEY';
      case MoyenPaiement.MOMO:
        return 'MOMO';
      case MoyenPaiement.WAVE:
        return 'WAVE';
    }
  }
}