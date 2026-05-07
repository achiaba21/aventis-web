/// Types de charges prédéfinis pour les résidences meublées en Côte d'Ivoire
enum TypeCharge {
  loyer,        // Loyer du local/bâtiment
  electricite,  // Facture CIE
  eau,          // Facture SODECI
  internet,     // Abonnement FAI (Orange, MTN, Moov)
  television,   // Canal+, Startimes, etc.
  menage,       // Service de nettoyage
  gardiennage,  // Sécurité/Gardien
  maintenance,  // Réparations et entretien
  impotFoncier, // Impôt foncier annuel
  patente,      // Taxe professionnelle
  agence,       // Frais d'agence immobilière
  assurance,    // Assurance habitation
  autre,        // Charge personnalisée
}

extension TypeChargeExtension on TypeCharge {
  /// Valeur envoyée au serveur (MAJUSCULE)
  String get value => name.toUpperCase();

  String get label {
    switch (this) {
      case TypeCharge.loyer:
        return 'Loyer';
      case TypeCharge.electricite:
        return 'Électricité (CIE)';
      case TypeCharge.eau:
        return 'Eau (SODECI)';
      case TypeCharge.internet:
        return 'Internet';
      case TypeCharge.television:
        return 'Télévision';
      case TypeCharge.menage:
        return 'Ménage';
      case TypeCharge.gardiennage:
        return 'Gardiennage';
      case TypeCharge.maintenance:
        return 'Maintenance';
      case TypeCharge.impotFoncier:
        return 'Impôt foncier';
      case TypeCharge.patente:
        return 'Patente';
      case TypeCharge.agence:
        return 'Frais d\'agence';
      case TypeCharge.assurance:
        return 'Assurance';
      case TypeCharge.autre:
        return 'Autre';
    }
  }

  String get icon {
    switch (this) {
      case TypeCharge.loyer:
        return '🏠';
      case TypeCharge.electricite:
        return '⚡';
      case TypeCharge.eau:
        return '💧';
      case TypeCharge.internet:
        return '📶';
      case TypeCharge.television:
        return '📺';
      case TypeCharge.menage:
        return '🧹';
      case TypeCharge.gardiennage:
        return '👮';
      case TypeCharge.maintenance:
        return '🔧';
      case TypeCharge.impotFoncier:
        return '🏛️';
      case TypeCharge.patente:
        return '📋';
      case TypeCharge.agence:
        return '🏢';
      case TypeCharge.assurance:
        return '🛡️';
      case TypeCharge.autre:
        return '📦';
    }
  }

  /// Parse une valeur (supporte MAJUSCULE et minuscule)
  static TypeCharge fromString(String value) {
    final lowerValue = value.toLowerCase();
    return TypeCharge.values.firstWhere(
      (e) => e.name == lowerValue,
      orElse: () => TypeCharge.autre,
    );
  }
}
