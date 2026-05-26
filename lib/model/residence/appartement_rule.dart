import 'package:asfar/model/residence/rule.dart';

/// Liaison entre un `Appartement` et une `Rule` du référentiel, portant la
/// valeur effective `isAllowed` pour cette annonce.
///
/// Sérialisé via le payload `appartementRules` aligné sur le contrat backend
/// 2026-05-17 :
/// ```json
/// { "rule": { "id": 1 }, "isAllowed": false }
/// ```
///
/// **Naming :** le backend attend strictement `isAllowed` (pas `allowed`).
/// Si on omet ce champ, le serveur applique `rule.defaultAllowed` comme
/// fallback silencieux → le choix du proprio est perdu.
///
/// Le `Rule` enfant ne contient que `id` côté payload sortant — le backend
/// résout les autres champs depuis le référentiel. Côté `fromJson`, on accepte
/// les 2 variantes (`isAllowed` ou `allowed`) pour robustesse historique.
class AppartementRule {
  int? id;
  Rule? rule;
  bool? isAllowed;

  AppartementRule({this.id, this.rule, this.isAllowed});

  AppartementRule.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    final r = json['rule'];
    if (r is Map<String, dynamic>) {
      rule = Rule.fromJson(r);
    } else if (r is Map) {
      rule = Rule.fromJson(Map<String, dynamic>.from(r));
    }
    // Accepte les 2 noms pour robustesse — le contrat backend strict est
    // `isAllowed` (cf. brief 2026-05-17).
    isAllowed = (json['isAllowed'] ?? json['allowed']) as bool?;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (rule != null) data['rule'] = {'id': rule!.id};
    if (isAllowed != null) data['isAllowed'] = isAllowed;
    return data;
  }
}
