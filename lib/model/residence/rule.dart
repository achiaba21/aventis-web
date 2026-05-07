import 'package:asfar/model/residence/appart.dart';

/// Modèle représentant une règle de maison pour un appartement
class Rule {
  int? id;
  String? iconName; // Nom de l'icône (ex: "smoke_free", "pets", etc.)
  String? text; // Texte de la règle
  bool? isAllowed; // true = autorisé, false = interdit
  // Appartement? appartement;

  Rule({
    this.id,
    this.iconName,
    this.text,
    this.isAllowed,
    // this.appartement,
  });

  Rule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    iconName = json['iconName'];
    text = json['text'];
    isAllowed = json['isAllowed'];
    // appartement = json['appartement'] != null
    //     ? Appartement.fromJson(json['appartement'])
    //     : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['iconName'] = iconName;
    data['text'] = text;
    data['isAllowed'] = isAllowed;
    // if (appartement != null) {
    //   data['appartement'] = appartement!.toJson();
    // }
    return data;
  }

  Rule copyWith({
    int? id,
    String? iconName,
    String? text,
    bool? isAllowed,
    Appartement? appartement,
  }) {
    return Rule(
      id: id ?? this.id,
      iconName: iconName ?? this.iconName,
      text: text ?? this.text,
      isAllowed: isAllowed ?? this.isAllowed,
      // appartement: appartement ?? this.appartement,
    );
  }
}
