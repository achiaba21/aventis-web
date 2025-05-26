import 'package:web_flutter/model/user/client.dart';

class Commentaire {
  int? id;
  int? note;
  String? contenu;
  DateTime? createdAt;
  DateTime? updatedAt;
  Client? client;

  Commentaire({this.id, this.note, this.client, this.contenu});

  Commentaire.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    note = json['note'];
    contenu = json['contenu'];
    client = json['client'] != null ? Client.fromJson(json['client']) : null;
    createdAt = DateTime.tryParse(json['createdAt']);
    updatedAt = DateTime.tryParse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['note'] = note;
    if (client != null) {
      data['client'] = client!.toJson();
    }
    data['contenu'] = contenu;
    return data;
  }
}
