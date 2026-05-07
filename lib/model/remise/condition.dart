class Condition {
  int? id;
  double? montant;
  int? days;

  Condition({
    this.id,
    this.montant,
    this.days,
  });

  static Condition fromJsonAll(Map<String, dynamic> json) {
    return Condition.fromJson(json);
  }

  Condition.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    montant = json['montant']?.toDouble();
    days = json['days'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['montant'] = montant;
    data['days'] = days;
    return data;
  }
}