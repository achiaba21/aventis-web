import 'package:flutter/src/widgets/icon_data.dart';
import 'package:web_flutter/model/residence/commodite/commodite.dart';

class ChauffeEau extends Commodite {
  bool? chauffeEau;

  ChauffeEau({
    int? id,
    String? nom,
    String? description,
    this.chauffeEau = true,
  }) : super(id: id, nom: nom, description: description);

  ChauffeEau.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    chauffeEau = json['chauffeEau'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['chauffeEau'] = chauffeEau;
    return data;
  }

  @override
  // TODO: implement icon
  IconData? get icon => null;

  @override
  String? get svgPath => null;
}
