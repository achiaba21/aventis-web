class FilterOptions {
  List<String> commodites;
  List<String> preferences;
  List<String> regles;
  double prixMin;
  double prixMax;

  FilterOptions({
    required this.commodites,
    required this.preferences,
    required this.regles,
    required this.prixMin,
    required this.prixMax,
  });

  FilterOptions.fromJson(Map<String, dynamic> json)
      : commodites = List<String>.from(json['commodites'] ?? []),
        preferences = List<String>.from(json['preferences'] ?? []),
        regles = List<String>.from(json['regles'] ?? []),
        prixMin = (json['prix_min'] ?? 0).toDouble(),
        prixMax = (json['prix_max'] ?? 10000000).toDouble();

  Map<String, dynamic> toJson() {
    return {
      'commodites': commodites,
      'preferences': preferences,
      'regles': regles,
      'prix_min': prixMin,
      'prix_max': prixMax,
    };
  }

  @override
  String toString() {
    return 'FilterOptions(commodites: $commodites, preferences: $preferences, regles: $regles, prixMin: $prixMin, prixMax: $prixMax)';
  }
}