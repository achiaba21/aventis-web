import 'package:web_flutter/model/document/fichier.dart';
import 'package:web_flutter/model/document/status.dart';
import 'package:web_flutter/model/user/user.dart';

class Document extends Fichier {
  User? user;
  Status? etats;

  Document({
    super.uuid,
    super.extension,
    super.type,
    super.titre,
    super.path,
    super.size,
    super.createdAt,
    super.updatedAt,
    this.user,
    this.etats,
  });

  static Document fromJsonAll(Map<String, dynamic> json) {
    return Document.fromJson(json);
  }

  Document.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    user = json['user'] != null ? User.fromJsonAll(json['user']) : null;
    etats = json['etats'] != null ? Status.fromJson(json['etats']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (etats != null) {
      data['etats'] = etats!.toJson();
    }
    return data;
  }
}