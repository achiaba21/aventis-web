import 'package:asfar/util/function.dart';

/// Modèle pour le code de réservation (QR Code)
/// Généré après le paiement d'une réservation
class CodeReservation {
  int? id;
  String? secretKey;
  bool? used;
  DateTime? expired;
  int? reservationId;

  CodeReservation({
    this.id,
    this.secretKey,
    this.used,
    this.expired,
    this.reservationId,
  });

  /// Vérifie si le code est expiré
  bool get isExpired {
    if (expired == null) return true;
    return expired!.isBefore(DateTime.now());
  }

  /// Vérifie si le code est valide (non utilisé et non expiré)
  bool get isValid => !(used ?? true) && !isExpired;

  /// Construit un CodeReservation à partir du JSON
  CodeReservation.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      secretKey = json['secretKey'];
      used = json['used'];
      expired = json['expired'] != null ? DateTime.parse(json['expired']) : null;
      reservationId = json['reservationId'];
    } catch (e) {
      deboger(['Erreur parsing CodeReservation:', e]);
    }
  }

  /// Convertit le CodeReservation en JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['secretKey'] = secretKey;
    data['used'] = used;
    if (expired != null) {
      data['expired'] = expired!.toIso8601String();
    }
    data['reservationId'] = reservationId;
    return data;
  }

  /// Retourne une description lisible du statut du code
  String get statusDescription {
    if (used == true) return 'Utilisé';
    if (isExpired) return 'Expiré';
    return 'Valide';
  }

  /// Copie le code avec des modifications
  CodeReservation copyWith({
    int? id,
    String? secretKey,
    bool? used,
    DateTime? expired,
    int? reservationId,
  }) {
    return CodeReservation(
      id: id ?? this.id,
      secretKey: secretKey ?? this.secretKey,
      used: used ?? this.used,
      expired: expired ?? this.expired,
      reservationId: reservationId ?? this.reservationId,
    );
  }
}
