import 'dart:math';

import 'package:web_flutter/model/reservation/commentaire/commentaire.dart';
import 'package:web_flutter/model/residence/offre.dart';
import 'package:web_flutter/model/residence/residence.dart';

class Appartement {
  int? id;
  double? prix;
  String? numro;
  String? titre;
  String? description;
  String? imgUrl;
  int? likes;
  Residence? residence;
  List<Offre>? offres = [];
  List<Commentaire>? commentaires = [];

  Appartement({
    this.id,
    this.prix,
    this.numro,
    this.titre,
    this.description,
    this.imgUrl,
    this.likes,
    this.residence,
    this.offres,
    this.commentaires,
  });

  Appartement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    prix = json['prix']?.toDouble();
    numro = json['numro'];
    titre = json['titre'];
    description = json['description'];
    imgUrl = json['imgUrl'];
    likes = json['likes'];
    residence =
        json['residence'] != null
            ? Residence.fromJson(json['residence'])
            : null;
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
    data['numro'] = numro;
    data['titre'] = titre;
    data['description'] = description;
    data['imgUrl'] = imgUrl;
    data['likes'] = likes;
    if (residence != null) {
      data['residence'] = residence!.toJson();
    }
    if (offres != null) {
      data['offres'] = offres!.map((x) => x.toJson()).toList();
    }
    if (commentaires != null) {
      data['commentaires'] = commentaires!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}
