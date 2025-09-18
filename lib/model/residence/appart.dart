import 'dart:math';

import 'package:web_flutter/model/document/photo_appart.dart';
import 'package:web_flutter/model/remise/remise.dart';
import 'package:web_flutter/model/reservation/commentaire/commentaire.dart';
import 'package:web_flutter/model/residence/offre.dart';
import 'package:web_flutter/model/residence/residence.dart';

class Appartement {
  int? id;
  double? prix;
  String? numero;
  String? titre;
  String? description;
  String? imgUrl;
  int? likes;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<PhotoAppart>? photos;
  Residence? residence;
  Remise? remises;
  bool? visible;
  List<Offre>? offres = [];
  List<Commentaire>? commentaires = [];

  Appartement({
    this.id,
    this.prix,
    this.numero,
    this.titre,
    this.description,
    this.imgUrl,
    this.likes,
    this.createdAt,
    this.updatedAt,
    this.photos,
    this.residence,
    this.remises,
    this.visible,
    this.offres,
    this.commentaires,
  });

  static Appartement fromJsonAll(Map<String, dynamic> json) {
    // Pour l'instant, pas de sous-classes d'Appartement, donc on retourne directement
    // Si des sous-classes sont ajoutées plus tard (ex: AppartementMeuble, AppartementStudio)
    // on peut les vérifier ici de la même manière que User.fromJsonAll
    return Appartement.fromJson(json);
  }

  Appartement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    prix = json['prix']?.toDouble();
    numero = json['numero'];
    titre = json['titre'];
    description = json['description'];
    imgUrl = json['imgUrl'];
    likes = json['likes'];
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    photos = json['photos'] != null
        ? List<PhotoAppart>.from(json['photos'].map((x) => PhotoAppart.fromJson(x)))
        : null;
    residence =
        json['residence'] != null
            ? Residence.fromJson(json['residence'])
            : null;
    remises = json['remises'] != null ? Remise.fromJson(json['remises']) : null;
    visible = json['visible'];
    offres =
        json['offres'] != null
            ? List<Offre>.from(json['offres'].map((x) => Offre.fromJson(x)))
            : null;
    commentaires =
        json['commentaires'] != null
            ? List<Commentaire>.from(
              json['commentaires'].map((x) => Commentaire.fromJson(x)),
            )
            : null;
  }
  double get note {
    return double.parse((Random().nextDouble() * 6).toStringAsFixed(1));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['prix'] = prix;
    data['numero'] = numero;
    data['titre'] = titre;
    data['description'] = description;
    data['imgUrl'] = imgUrl;
    data['likes'] = likes;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    if (photos != null) {
      data['photos'] = photos!.map((x) => x.toJson()).toList();
    }
    if (residence != null) {
      data['residence'] = residence!.toJson();
    }
    if (remises != null) {
      data['remises'] = remises!.toJson();
    }
    data['visible'] = visible;
    if (offres != null) {
      data['offres'] = offres!.map((x) => x.toJson()).toList();
    }
    if (commentaires != null) {
      data['commentaires'] = commentaires!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}
