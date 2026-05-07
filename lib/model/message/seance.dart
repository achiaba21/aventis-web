import 'package:asfar/model/message/message.dart';
import 'package:asfar/util/formate.dart';

/// Modèle Seance conforme à l'API backend
/// Structure: SeanceResponse
class Seance {
  int? id;
  int? proprietaireId;
  String? proprietaireNom;
  int? locataireId;
  String? locataireNom;
  String? reservationReference;
  bool? active;
  int? messagesNonLus;
  Message? dernierMessage;
  DateTime? createdAt;

  Seance({
    this.id,
    this.proprietaireId,
    this.proprietaireNom,
    this.locataireId,
    this.locataireNom,
    this.reservationReference,
    this.active,
    this.messagesNonLus,
    this.dernierMessage,
    this.createdAt,
  });

  /// Retourne le nom du contact (l'autre personne dans la conversation)
  /// selon le type d'utilisateur connecté
  String? getContactName(int currentUserId) {
    if (currentUserId == locataireId) {
      return proprietaireNom;
    } else if (currentUserId == proprietaireId) {
      return locataireNom;
    }
    return proprietaireNom ?? locataireNom;
  }

  /// Retourne l'ID du contact (l'autre personne dans la conversation)
  int? getContactId(int currentUserId) {
    if (currentUserId == locataireId) {
      return proprietaireId;
    } else if (currentUserId == proprietaireId) {
      return locataireId;
    }
    return proprietaireId ?? locataireId;
  }

  Seance.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    proprietaireId = json['proprietaireId'];
    proprietaireNom = json['proprietaireNom'];
    locataireId = json['locataireId'];
    locataireNom = json['locataireNom'];
    reservationReference = json['reservationReference'];
    active = json['active'];
    messagesNonLus = json['messagesNonLus'];
    dernierMessage = json['dernierMessage'] != null
        ? Message.fromJson(json['dernierMessage'])
        : null;
    createdAt = toDate(json['createdAt']);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['proprietaireId'] = proprietaireId;
    data['proprietaireNom'] = proprietaireNom;
    data['locataireId'] = locataireId;
    data['locataireNom'] = locataireNom;
    data['reservationReference'] = reservationReference;
    data['active'] = active;
    data['messagesNonLus'] = messagesNonLus;
    if (dernierMessage != null) {
      data['dernierMessage'] = dernierMessage!.toJson();
    }
    data['createdAt'] = createdAt?.toIso8601String();
    return data;
  }
}
