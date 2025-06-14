import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/model/user/client.dart';
import 'package:web_flutter/util/formate.dart';

class Message {
  Client? client;
  Seance? seance;
  String? contenu;
  DateTime? createdAt;

  Message({
    this.client,
    this.seance,
    this.contenu,
  });

  Message.fromJson(Map<String, dynamic> json) {
    
      contenu= json['contenu'];
      client= json['client'] != null ? Client.fromJson(json['client']) : null;
      seance= json['seance'] != null ? Seance.fromJson(json['seance']) : null;
      createdAt = toDate(json['createdAt']);
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['contenu'] = contenu;
    data['client'] = client?.toJson();
    data['seance'] = seance?.toJson();
    data['createdAt'] = createdAt?.toIso8601String();

    return data;
  }
}
