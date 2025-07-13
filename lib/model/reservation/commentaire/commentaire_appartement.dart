import 'package:web_flutter/model/reservation/commentaire/commentaire.dart';
import 'package:web_flutter/model/residence/appart.dart';

class CommentaireAppartement extends Commentaire {
  Appartement? appartement;

  CommentaireAppartement({
    super.id,
    super.note,
    super.contenu,

    this.appartement,
  });

  CommentaireAppartement.fromJson(Map<String, dynamic> json)
    : super.fromJson(json) {
    appartement =
        json['appartement'] != null
            ? Appartement.fromJson(json['appartement'])
            : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();

    if (appartement != null) {
      data['appartement'] = appartement!.toJson();
    }
    return data;
  }
}
