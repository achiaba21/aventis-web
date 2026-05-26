/// Modèle d'une règle de maison (référentiel backend partagé).
///
/// Aligné sur `GET /auth/rules` (brief backend 2026-05-16) :
/// - [id] : clé technique stable
/// - [value] : clé sémantique stable (`no_smoking`, `pets_allowed`, ...)
/// - [iconName] : nom Material Design utilisable directement
/// - [text] : libellé FR à afficher
/// - [defaultAllowed] : valeur par défaut suggérée par le référentiel
/// - [isAllowed] : valeur effective stockée sur une annonce (legacy/transition)
class Rule {
  int? id;
  String? value;
  String? iconName;
  String? text;
  bool? defaultAllowed;
  bool? isAllowed;

  Rule({
    this.id,
    this.value,
    this.iconName,
    this.text,
    this.defaultAllowed,
    this.isAllowed,
  });

  Rule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    iconName = json['iconName'];
    text = json['text'];
    defaultAllowed = json['defaultAllowed'];
    isAllowed = json['isAllowed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (value != null) data['value'] = value;
    if (iconName != null) data['iconName'] = iconName;
    if (text != null) data['text'] = text;
    if (defaultAllowed != null) data['defaultAllowed'] = defaultAllowed;
    if (isAllowed != null) data['isAllowed'] = isAllowed;
    return data;
  }

  Rule copyWith({
    int? id,
    String? value,
    String? iconName,
    String? text,
    bool? defaultAllowed,
    bool? isAllowed,
  }) {
    return Rule(
      id: id ?? this.id,
      value: value ?? this.value,
      iconName: iconName ?? this.iconName,
      text: text ?? this.text,
      defaultAllowed: defaultAllowed ?? this.defaultAllowed,
      isAllowed: isAllowed ?? this.isAllowed,
    );
  }
}
