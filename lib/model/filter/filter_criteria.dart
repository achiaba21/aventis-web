class FilterCriteria {
  double? prixMin;
  double? prixMax;
  DateTime? dateDebut;
  DateTime? dateFin;
  int? nbLits;
  int? nbChambres;
  int? nbDouches;
  List<String>? commodites;
  List<String>? preferences;
  List<String>? regles;

  FilterCriteria({
    this.prixMin,
    this.prixMax,
    this.dateDebut,
    this.dateFin,
    this.nbLits,
    this.nbChambres,
    this.nbDouches,
    this.commodites,
    this.preferences,
    this.regles,
  });

  FilterCriteria.fromJson(Map<String, dynamic> json) {
    prixMin = json['prix_min']?.toDouble();
    prixMax = json['prix_max']?.toDouble();
    dateDebut = json['date_debut'] != null ? DateTime.parse(json['date_debut']) : null;
    dateFin = json['date_fin'] != null ? DateTime.parse(json['date_fin']) : null;
    nbLits = json['nb_lits'];
    nbChambres = json['nb_chambres'];
    nbDouches = json['nb_douches'];
    commodites = json['commodites'] != null ? List<String>.from(json['commodites']) : null;
    preferences = json['preferences'] != null ? List<String>.from(json['preferences']) : null;
    regles = json['regles'] != null ? List<String>.from(json['regles']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (prixMin != null) data['prix_min'] = prixMin;
    if (prixMax != null) data['prix_max'] = prixMax;
    if (dateDebut != null) data['date_debut'] = dateDebut!.toIso8601String().split('T')[0];
    if (dateFin != null) data['date_fin'] = dateFin!.toIso8601String().split('T')[0];
    if (nbLits != null) data['nb_lits'] = nbLits;
    if (nbChambres != null) data['nb_chambres'] = nbChambres;
    if (nbDouches != null) data['nb_douches'] = nbDouches;
    if (commodites != null && commodites!.isNotEmpty) data['commodites'] = commodites;
    if (preferences != null && preferences!.isNotEmpty) data['preferences'] = preferences;
    if (regles != null && regles!.isNotEmpty) data['regles'] = regles;
    return data;
  }

  bool get hasFilters {
    return prixMin != null ||
        prixMax != null ||
        dateDebut != null ||
        dateFin != null ||
        (nbLits != null && nbLits! > 0) ||
        (nbChambres != null && nbChambres! > 0) ||
        (nbDouches != null && nbDouches! > 0) ||
        (commodites != null && commodites!.isNotEmpty) ||
        (preferences != null && preferences!.isNotEmpty) ||
        (regles != null && regles!.isNotEmpty);
  }

  int get activeFiltersCount {
    int count = 0;
    if (prixMin != null || prixMax != null) count++;
    if (dateDebut != null || dateFin != null) count++;
    if (nbLits != null && nbLits! > 0) count++;
    if (nbChambres != null && nbChambres! > 0) count++;
    if (nbDouches != null && nbDouches! > 0) count++;
    if (commodites != null && commodites!.isNotEmpty) count++;
    if (preferences != null && preferences!.isNotEmpty) count++;
    if (regles != null && regles!.isNotEmpty) count++;
    return count;
  }

  FilterCriteria copyWith({
    double? prixMin,
    double? prixMax,
    DateTime? dateDebut,
    DateTime? dateFin,
    int? nbLits,
    int? nbChambres,
    int? nbDouches,
    List<String>? commodites,
    List<String>? preferences,
    List<String>? regles,
  }) {
    return FilterCriteria(
      prixMin: prixMin ?? this.prixMin,
      prixMax: prixMax ?? this.prixMax,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      nbLits: nbLits ?? this.nbLits,
      nbChambres: nbChambres ?? this.nbChambres,
      nbDouches: nbDouches ?? this.nbDouches,
      commodites: commodites ?? this.commodites,
      preferences: preferences ?? this.preferences,
      regles: regles ?? this.regles,
    );
  }

  void clear() {
    prixMin = null;
    prixMax = null;
    dateDebut = null;
    dateFin = null;
    nbLits = null;
    nbChambres = null;
    nbDouches = null;
    commodites = null;
    preferences = null;
    regles = null;
  }

  @override
  String toString() {
    return 'FilterCriteria(prixMin: $prixMin, prixMax: $prixMax, dateDebut: $dateDebut, dateFin: $dateFin, nbLits: $nbLits, nbChambres: $nbChambres, nbDouches: $nbDouches, commodites: $commodites, preferences: $preferences, regles: $regles)';
  }
}