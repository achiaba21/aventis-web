import 'package:web_flutter/model/remise/condition.dart';

class Remise {
  int? id;
  List<Condition>? conditions;

  Remise({
    this.id,
    this.conditions,
  });

  /// Trouve la condition correspondante basée sur le nombre de jours
  /// Retourne la dernière condition valide (days <= nombre de jours fourni)
  Condition? matchCondition(int days) {
    if (conditions == null || conditions!.isEmpty) return null;

    Condition? lastCond;
    for (Condition condition in conditions!) {
      if (condition.days != null && condition.days! <= days) {
        lastCond = condition;
      }
    }
    return lastCond;
  }

  static Remise fromJsonAll(Map<String, dynamic> json) {
    return Remise.fromJson(json);
  }

  Remise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conditions = json['conditions'] != null
        ? List<Condition>.from(json['conditions'].map((x) => Condition.fromJson(x)))
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (conditions != null) {
      data['conditions'] = conditions!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}