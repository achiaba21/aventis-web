/// Statut d'une plage dans le calendrier
enum PlageStatut {
  disponible('DISPONIBLE'),
  occupe('OCCUPE'),
  enAttente('EN_ATTENTE');

  const PlageStatut(this.value);
  final String value;

  static PlageStatut fromString(String value) {
    return PlageStatut.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => PlageStatut.disponible,
    );
  }

  bool get isClickable => this == PlageStatut.disponible;
}

/// Type d'une plage dans le calendrier
enum PlageType {
  reservation('RESERVATION'),
  blocage('BLOCAGE'),
  disponibilite('DISPONIBILITE'),
  demarcheur('DEMARCHEUR');

  const PlageType(this.value);
  final String value;

  static PlageType fromString(String value) {
    return PlageType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => PlageType.disponibilite,
    );
  }
}

/// Une plage de disponibilité retournée par l'API calendrier
class CalendarPlage {
  final DateTime debut;
  final DateTime fin;
  final PlageStatut statut;
  final PlageType type;
  final String? reference;
  final String? demarcheurNom;
  final String? demarcheurTelephone;
  final double montant;
  final double? montantCommission;

  CalendarPlage({
    required this.debut,
    required this.fin,
    required this.statut,
    required this.type,
    this.reference,
    this.demarcheurNom,
    this.demarcheurTelephone,
    this.montant = 0.0,
    this.montantCommission,
  });

  factory CalendarPlage.fromJson(Map<String, dynamic> json) {
    return CalendarPlage(
      debut: DateTime.parse(json['debut'] as String),
      fin: DateTime.parse(json['fin'] as String),
      statut: PlageStatut.fromString(json['statut'] as String),
      type: PlageType.fromString(json['type'] as String? ?? ''),
      reference: json['reference'] as String?,
      demarcheurNom: json['demarcheurNom'] as String?,
      demarcheurTelephone: json['demarcheurTelephone'] as String?,
      montant: (json['montant'] as num?)?.toDouble() ?? 0.0,
      montantCommission: (json['montantCommission'] as num?)?.toDouble(),
    );
  }

  /// Vérifie si un jour donné est couvert par cette plage
  bool containsDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(debut.year, debut.month, debut.day);
    final e = DateTime(fin.year, fin.month, fin.day);
    return (d.isAtSameMomentAs(s) || d.isAfter(s)) && d.isBefore(e);
  }
}

/// Réponse complète de l'API calendrier pour un appartement
class CalendarResponse {
  final int appartId;
  final List<CalendarPlage> plages;

  CalendarResponse({required this.appartId, required this.plages});

  /// [appartId] est utilisé comme fallback si la réponse serveur ne contient pas ce champ
  factory CalendarResponse.fromJson(Map<String, dynamic> json,
      {int? appartId}) {
    final plagesJson = (json['plages'] as List<dynamic>?) ?? [];
    return CalendarResponse(
      appartId: (json['appartId'] as int?) ?? appartId ?? 0,
      plages: plagesJson
          .map((p) => CalendarPlage.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
