import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/model/reservation/commentaire/commentaire.dart';
import 'package:asfar/model/residence/offre.dart';
import 'package:asfar/model/residence/rule.dart';

class Appartement {
  int? id;
  double? prix;
  String? numero;
  String? titre;
  String? description;
  String? imgUrl;
  int? likes;
  bool? isVisible;
  AppartementStatus? status;
  int? nbLits;
  int? nbChambres;
  int? nbDouches;
  String? typeLocation;
  String? regles;
  bool? brouillon;

  /// Note moyenne persistée (0-5). `null` si jamais notée — l'UI doit alors
  /// retomber sur la moyenne des `commentaires` via `AppartementDisplay.rating`.
  double? note;

  DateTime? createdAt;
  DateTime? updatedAt;
  List<PhotoAppart>? photos;
  Address? address;
  Remise? remises;
  List<Offre>? offres = [];
  List<Commentaire>? commentaires = [];
  List<Rule>? rules = [];

  Appartement({
    this.id,
    this.prix,
    this.numero,
    this.titre,
    this.description,
    this.imgUrl,
    this.likes,
    this.isVisible,
    this.status,
    this.nbLits,
    this.nbChambres,
    this.nbDouches,
    this.typeLocation,
    this.regles,
    this.brouillon,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.photos,
    this.address,
    this.remises,
    this.offres,
    this.commentaires,
    this.rules,
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
    isVisible = json['visible'] ?? json['isVisible'];
    status = AppartementStatusExtension.fromString(json['status']);
    nbLits = json['nbLits'];
    nbChambres = json['nbChambres'];
    nbDouches = json['nbDouches'];
    typeLocation = json['typeLocation'];
    regles = json['regles'];
    brouillon = json['brouillon'];
    note = (json['note'] as num?)?.toDouble();
    createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null;
    updatedAt = json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null;
    photos = json['photos'] != null
        ? List<PhotoAppart>.from(json['photos'].map((x) => PhotoAppart.fromJson(x)))
        : null;
    // Fusion défensive : si l'address n'est pas au top-level mais que le backend
    // l'a placée dans residence.address (legacy avant BACKEND-FLAT-APPART),
    // on la récupère ici. Ce comportement est temporaire — voir
    // AppartementBackendMapper et le TODO BACKEND-FLAT-APPART.
    final dynamic addressJson = json['address']
        ?? (json['residence'] is Map ? (json['residence']['address']) : null);
    address = addressJson is Map
        ? Address.fromJson(Map<String, dynamic>.from(addressJson))
        : null;
    remises = json['remises'] != null ? Remise.fromJson(json['remises']) : null;
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
    // Backend exposes `appartementRules` (champ JPA). Le champ `rules` est
    // accepté en fallback pour les anciens DTOs / le cache local.
    final dynamic rulesJson = json['appartementRules'] ?? json['rules'];
    rules = rulesJson != null
        ? List<Rule>.from(rulesJson.map((x) => Rule.fromJson(x)))
        : null;
  }

  /// Crée une copie de l'appartement avec les valeurs spécifiées
  Appartement copyWith({
    int? id,
    double? prix,
    String? numero,
    String? titre,
    String? description,
    String? imgUrl,
    int? likes,
    bool? isVisible,
    AppartementStatus? status,
    int? nbLits,
    int? nbChambres,
    int? nbDouches,
    String? typeLocation,
    String? regles,
    bool? brouillon,
    double? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<PhotoAppart>? photos,
    Address? address,
    Remise? remises,
    List<Offre>? offres,
    List<Commentaire>? commentaires,
    List<Rule>? rules,
  }) {
    return Appartement(
      id: id ?? this.id,
      prix: prix ?? this.prix,
      numero: numero ?? this.numero,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      imgUrl: imgUrl ?? this.imgUrl,
      likes: likes ?? this.likes,
      isVisible: isVisible ?? this.isVisible,
      status: status ?? this.status,
      nbLits: nbLits ?? this.nbLits,
      nbChambres: nbChambres ?? this.nbChambres,
      nbDouches: nbDouches ?? this.nbDouches,
      typeLocation: typeLocation ?? this.typeLocation,
      regles: regles ?? this.regles,
      brouillon: brouillon ?? this.brouillon,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photos: photos ?? this.photos,
      address: address ?? this.address,
      remises: remises ?? this.remises,
      offres: offres ?? this.offres,
      commentaires: commentaires ?? this.commentaires,
      rules: rules ?? this.rules,
    );
  }
  Map<String, dynamic> toJsonReq(){
    final Map<String, dynamic> data = <String, dynamic>{};
     data['id'] = id;
     return data;
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
    data['isVisible'] = isVisible;
    data['status'] = status?.name;
    data['nbLits'] = nbLits;
    data['nbChambres'] = nbChambres;
    data['nbDouches'] = nbDouches;
    data['typeLocation'] = typeLocation;
    data['regles'] = regles;
    data['brouillon'] = brouillon;
    data['note'] = note;
    data['createdAt'] = createdAt?.toIso8601String();
    data['updatedAt'] = updatedAt?.toIso8601String();
    if (photos != null) {
      data['photos'] = photos!.map((x) => x.toJson()).toList();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (remises != null) {
      data['remises'] = remises!.toJson();
    }
    if (offres != null) {
      data['offres'] = offres!.map((x) => x.toJson()).toList();
    }
    if (commentaires != null) {
      data['commentaires'] = commentaires!.map((x) => x.toJson()).toList();
    }
    if (rules != null) {
      data['appartementRules'] = rules!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}
