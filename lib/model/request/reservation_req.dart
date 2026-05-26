import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/residence/appart.dart';

class ReservationReq {
  Appartement? appartement;
  DateTimeRange? plage;
  String? cur;
  MoyenPaiement? moyenPaiement;

  ReservationReq({
    this.appartement,
    this.plage,
    this.cur,
    this.moyenPaiement,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (appartement != null) {
      data['appart'] = appartement!.toJsonReq();
    }

    if (plage != null) {
      data['debut'] = plage!.start.toIso8601String();
      data['fin'] = plage!.end.toIso8601String();
    }

    data['cur'] = cur;

    if (moyenPaiement != null) {
      data['moyenPaiement'] = _moyenPaiementToString(moyenPaiement!);
    }

    return data;
  }

  // Méthode utilitaire pour convertir MoyenPaiement en String
  static String _moyenPaiementToString(MoyenPaiement moyen) => moyen.value;
}
