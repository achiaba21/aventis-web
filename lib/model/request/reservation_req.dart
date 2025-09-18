import 'package:flutter/material.dart';
import 'package:web_flutter/model/enumeration/moyen_paiement.dart';
import 'package:web_flutter/model/residence/appart.dart';

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
      data['appartement'] = appartement!.toJson();
    }

    if (plage != null) {
      data['dateDebut'] = plage!.start.toIso8601String();
      data['dateFin'] = plage!.end.toIso8601String();
    }

    data['cur'] = cur;

    if (moyenPaiement != null) {
      data['moyenPaiement'] = _moyenPaiementToString(moyenPaiement!);
    }

    return data;
  }

  // Méthode utilitaire pour convertir MoyenPaiement en String
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
