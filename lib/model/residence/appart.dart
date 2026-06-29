import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/enumeration/appartement_status.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/model/reservation/commentaire/commentaire.dart';
import 'package:asfar/model/residence/appartement_rule.dart';
import 'package:asfar/model/residence/offre.dart';
import 'package:asfar/model/residence/rule.dart';
import 'package:asfar/model/user/participant_mini.dart';

class Appartement {
  int? id;
  double? prix;
  String? numero;
  String? titre;
  String? description;
  String? imgUrl;

  /// Token public (hex, 32 car.) du partage web des photos du bien :
  /// `{domain}/share/{partageToken}`. Attribué par le backend. Nullable :
  /// absent sur de très vieux objets → bouton « Partager » masqué.
  String? partageToken;

  int? likes;
  bool? isVisible;
  AppartementStatus? status;

  /// Commune renvoyée à plat par le DTO backend (`appart.communeNom`)
  /// depuis BACKEND-FLAT-APPART. Source principale pour `localiteLabel` —
  /// l'`Address` nested reste un fallback legacy.
  String? communeNom;

  /// Ville renvoyée à plat par le DTO backend (`appart.villeNom`).
  String? villeNom;
  int? nbLits;
  int? nbChambres;
  int? nbDouches;
  AppartementTypeLocation? typeLocation;
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

  /// Legacy : ancien format `[{iconName, text, isAllowed}]`. Conservé pour
  /// rétro-compat de lecture des annonces stockées dans cet ancien format.
  /// **NE PAS** utiliser pour les nouvelles annonces — préférer
  /// [appartementRules] qui sérialise le nouveau format backend.
  List<Rule>? rules = [];

  /// Nouveau format `[{rule: {id}, isAllowed: bool}]` aligné sur le brief
  /// backend 2026-05-17. Si renseigné, prioritaire sur [rules] côté `toJson`.
  List<AppartementRule>? appartementRules;

  /// Mini-vue du propriétaire renvoyée par le DTO démarcheur depuis backend
  /// 2026-05-18 (`AppartementForDemarcheurDto.ProprietaireMini`). Null pour
  /// les endpoints qui ne l'exposent pas (ex. dashboard locataire).
  ParticipantMini? proprietaire;

  /// Latitude obfusquée — prévu pour R14 (`GET api/demarcheur/appartements`).
  /// Null tant que le backend ne l'expose pas.
  double? lat;

  /// Longitude obfusquée — prévu pour R14. Null tant que le backend ne l'expose pas.
  double? lon;

  Appartement({
    this.id,
    this.prix,
    this.numero,
    this.titre,
    this.description,
    this.imgUrl,
    this.partageToken,
    this.likes,
    this.isVisible,
    this.status,
    this.communeNom,
    this.villeNom,
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
    this.appartementRules,
    this.proprietaire,
    this.lat,
    this.lon,
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
    partageToken = json['partageToken'];
    likes = json['likes'];
    isVisible = json['visible'] ?? json['isVisible'];
    // Le statut de modération peut arriver sous plusieurs clés selon l'endpoint
    // backend (`status` documenté, mais `statut`/`etat` ailleurs dans l'API).
    final dynamic rawStatus =
        json['status'] ?? json['statut'] ?? json['etat'] ?? json['etats'];
    status = AppartementStatusExtension.fromString(rawStatus?.toString());
    communeNom = json['communeNom'] as String?;
    villeNom = json['villeNom'] as String?;
    nbLits = json['nbLits'];
    nbChambres = json['nbChambres'];
    nbDouches = json['nbDouches'];
    // Type de logement : parsing strict puis fallback legacy combiné avec
    // nbChambres (cf. business-spec §4.6 — annonces existantes en string libre).
    final rawType = json['typeLocation'] as String?;
    final rawNbChambres = json['nbChambres'] as int?;
    typeLocation = AppartementTypeLocation.fromBackend(rawType) ??
        (rawType != null && rawType.isNotEmpty
            ? AppartementTypeLocation.fromLegacy(rawType, rawNbChambres)
            : null);
    regles = json['regles'];
    brouillon = json['brouillon'];
    note = (json['note'] as num?)?.toDouble();
    // `tryParse` (et non `parse`) : une date malformée ne doit jamais faire
    // échouer le parsing de toute l'annonce — elle retombe simplement à null.
    createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
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
    // Le backend retourne `appartementRules` au nouveau format
    // `[{rule:{id,value,...}, isAllowed}]` depuis 2026-05-17. On parse via
    // `AppartementRule.fromJson` (qui accepte aussi `allowed` legacy) ET on
    // remplit `rules` legacy pour les call sites qui n'ont pas encore migré
    // (lecture seule).
    final dynamic rulesJson = json['appartementRules'] ?? json['rules'];
    if (rulesJson is List) {
      appartementRules = rulesJson
          .whereType<Map>()
          .map((m) => AppartementRule.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      // Mirror legacy : projeter les Rule embarquées avec leur isAllowed
      // pour rétro-compat de lecture.
      rules = appartementRules!
          .where((ar) => ar.rule != null)
          .map((ar) => ar.rule!.copyWith(isAllowed: ar.isAllowed))
          .toList();
    }
    // Le backend expose l'hôte sous la clé 'proprio' (DTO réduit, contrat
    // 2026-06-11) ; 'proprietaire' reste lue pour les payloads antérieurs.
    final dynamic proprioJson = json['proprio'] ?? json['proprietaire'];
    if (proprioJson is Map) {
      proprietaire =
          ParticipantMini.fromJson(Map<String, dynamic>.from(proprioJson));
    }
    lat = (json['lat'] as num?)?.toDouble();
    lon = (json['lon'] as num?)?.toDouble();
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
    String? communeNom,
    String? villeNom,
    int? nbLits,
    int? nbChambres,
    int? nbDouches,
    AppartementTypeLocation? typeLocation,
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
    List<AppartementRule>? appartementRules,
    ParticipantMini? proprietaire,
    double? lat,
    double? lon,
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
      communeNom: communeNom ?? this.communeNom,
      villeNom: villeNom ?? this.villeNom,
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
      appartementRules: appartementRules ?? this.appartementRules,
      proprietaire: proprietaire ?? this.proprietaire,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
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
    data['partageToken'] = partageToken;
    data['likes'] = likes;
    data['isVisible'] = isVisible;
    data['status'] = status?.name;
    data['communeNom'] = communeNom;
    data['villeNom'] = villeNom;
    data['nbLits'] = nbLits;
    data['nbChambres'] = nbChambres;
    data['nbDouches'] = nbDouches;
    data['typeLocation'] = typeLocation?.value;
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
    // Priorité au nouveau format `appartementRules` (brief backend 2026-05-17) :
    // [{rule: {id}, isAllowed: bool}, ...]. Fallback sur `rules` legacy si
    // seul l'ancien format est disponible (lecture de drafts pré-refacto).
    if (appartementRules != null && appartementRules!.isNotEmpty) {
      data['appartementRules'] =
          appartementRules!.map((x) => x.toJson()).toList();
    } else if (rules != null && rules!.isNotEmpty) {
      data['appartementRules'] = rules!.map((x) => x.toJson()).toList();
    }
    if (proprietaire != null) {
      data['proprietaire'] = proprietaire!.toJson();
    }
    data['lat'] = lat;
    data['lon'] = lon;
    return data;
  }

  /// Libellé de localisation prioritaire : champs aplatis backend
  /// (`communeNom`/`villeNom`) puis fallback sur l'`Address` legacy.
  /// Retourne une chaîne vide si aucune source n'est disponible.
  String get localiteLabel {
    if (communeNom != null && villeNom != null) {
      return '$communeNom, $villeNom';
    }
    if (communeNom != null) return communeNom!;
    if (villeNom != null) return villeNom!;
    if (address?.hasFallbackLocation == true) {
      return address!.locationDisplayName;
    }
    return '';
  }
}
