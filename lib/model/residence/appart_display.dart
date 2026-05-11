import 'package:asfar/model/residence/appart.dart';

/// Extension de présentation sur `Appartement` — usage UI.
///
/// Centralise les getters dérivés utilisés par les cards et écrans (tone,
/// titre safe, area, city, price int, rating, reviewsCount, isSuperhost,
/// etc.) afin que les widgets puissent consommer `Appartement` directement
/// sans passer par un DTO intermédiaire.
extension AppartementDisplay on Appartement {
  /// Tone du gradient placeholder (1-4). Déterministe par appartement —
  /// chaque appart a toujours le même tone visuel.
  int get tone => ((id ?? 0) % 4) + 1;

  /// Titre sécurisé (fallback « Sans titre »).
  String get titleSafe => titre?.isNotEmpty == true ? titre! : 'Sans titre';

  /// Nom de la commune (quartier), vide si absent.
  String get areaName => address?.commune?.nom ?? '';

  /// Nom de la ville, vide si absent.
  String get cityName => address?.commune?.ville?.nom ?? '';

  /// Prix arrondi en int (FCFA).
  int get priceAmount => (prix ?? 0).round();

  /// Note d'évaluation (alias de `note`).
  double get rating => note;

  /// Nombre d'avis.
  int get reviewsCount => commentaires?.length ?? 0;

  /// Lits.
  int get bedsCount => nbLits ?? 0;

  /// Douches.
  int get bathsCount => nbDouches ?? 0;

  /// Surface en m² — pas encore exposée par le backend, retourne 0.
  int get surfaceM2 => 0;

  /// Heuristique « super-host » : note élevée + suffisamment d'avis.
  bool get isSuperhost => rating >= 4.8 && reviewsCount >= 50;

  /// Identifiant String stable (utile pour navigation, favoris, BLoC).
  String get displayId => '${id ?? 0}';

  /// URL d'image à afficher (imgUrl racine, fallback null → ImgPh tone).
  String? get displayImageUrl => imgUrl;
}
