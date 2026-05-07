import 'package:asfar/model/document/fichier.dart';
import 'package:asfar/model/residence/appart.dart';

class PhotoAppart extends Fichier {
  Appartement? appartement;

  PhotoAppart({
    super.uuid,
    super.extension,
    super.type,
    super.titre,
    super.path,
    super.size,
    super.createdAt,
    super.updatedAt,
    this.appartement,
  });

  static PhotoAppart fromJsonAll(Map<String, dynamic> json) {
    return PhotoAppart.fromJson(json);
  }

  PhotoAppart.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    appartement = json['appartement'] != null
        ? Appartement.fromJsonAll(json['appartement'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (appartement != null) {
      data['appartement'] = appartement!.toJson();
    }
    return data;
  }
}