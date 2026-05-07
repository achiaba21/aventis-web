import 'package:asfar/util/formate.dart';

/// Type de client dans un message (selon l'API)
enum ClientType {
  locataire('LOCATAIRE'),
  proprietaire('PROPRIETAIRE');

  const ClientType(this.value);
  final String value;

  static ClientType fromString(String value) {
    return ClientType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ClientType.locataire,
    );
  }
}

/// Modèle Message conforme à l'API backend
/// Structure: MessageResponse
class Message {
  int? id;
  int? clientId;
  String? clientNom;
  ClientType? clientType;
  String? contenu;
  bool? lu;
  DateTime? createdAt;

  Message({
    this.id,
    this.clientId,
    this.clientNom,
    this.clientType,
    this.contenu,
    this.lu,
    this.createdAt,
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    clientId = json['clientId'];
    clientNom = json['clientNom'];
    clientType = json['clientType'] != null
        ? ClientType.fromString(json['clientType'])
        : null;
    contenu = json['contenu'];
    lu = json['lu'];
    createdAt = toDate(json['createdAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['clientId'] = clientId;
    data['clientNom'] = clientNom;
    if (clientType != null) {
      data['clientType'] = clientType!.value;
    }
    data['contenu'] = contenu;
    data['lu'] = lu;
    data['createdAt'] = createdAt?.toIso8601String();
    return data;
  }
}
