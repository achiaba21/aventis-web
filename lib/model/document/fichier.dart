import 'package:web_flutter/model/document/file_type.dart';

abstract class Fichier {
  String? uuid;
  String? extension;
  FileType? type;
  String? titre;
  String? path;
  int? size;
  DateTime? createdAt;
  DateTime? updatedAt;

  Fichier({
    this.uuid,
    this.extension,
    this.type,
    this.titre,
    this.path,
    this.size,
    this.createdAt,
    this.updatedAt,
  });

  /// Constructeur depuis JSON - doit être implémenté par les sous-classes
  static Fichier fromJsonAll(Map<String, dynamic> json) {
    throw UnimplementedError('fromJsonAll must be implemented by subclasses');
  }

  /// Constructeur depuis JSON de base pour les champs communs
  Fichier.fromJson(Map<String, dynamic> json) {
    uuid = json['uuid'];
    extension = json['extension'];
    type = json['type'] != null ? FileType.fromJson(json['type']) : null;
    titre = json['titre'];
    path = json['path'];
    size = json['size'];
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
  }

  /// Sérialisation vers JSON de base pour les champs communs
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uuid'] = uuid;
    data['extension'] = extension;
    if (type != null) {
      data['type'] = type!.toJson();
    }
    data['titre'] = titre;
    data['path'] = path;
    data['size'] = size;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }
}