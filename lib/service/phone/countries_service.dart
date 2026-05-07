import 'package:asfar/model/phone/country.dart';

class CountriesService {
  static const List<Country> _countries = [
    // Pays d'Afrique de l'Ouest (prioritaires)
    // Ghana
    // Côte d'Ivoire
    // Burkina Faso
    // Mali
    // + autres pays fréquents
  ];

  // Obtenir tous les pays disponibles
  static List<Country> getAllCountries() {
    return [
      Country.ghana(),
      Country.coteDIvoire(),
      Country.burkina(),
      Country.mali(),
      Country.france(),
      // Ajouter d'autres pays selon les besoins
      Country(
        name: "Sénégal",
        code: "SN",
        dialCode: "+221",
        flag: "🇸🇳",
        format: "## ### ## ##",
        maxLength: 9,
        validationRegex: RegExp(r'^[0-9]{9}$'),
      ),
      Country(
        name: "Niger",
        code: "NE",
        dialCode: "+227",
        flag: "🇳🇪",
        format: "## ## ## ##",
        maxLength: 8,
        validationRegex: RegExp(r'^[0-9]{8}$'),
      ),
      Country(
        name: "Togo",
        code: "TG",
        dialCode: "+228",
        flag: "🇹🇬",
        format: "## ## ## ##",
        maxLength: 8,
        validationRegex: RegExp(r'^[0-9]{8}$'),
      ),
      Country(
        name: "Bénin",
        code: "BJ",
        dialCode: "+229",
        flag: "🇧🇯",
        format: "## ## ## ##",
        maxLength: 8,
        validationRegex: RegExp(r'^[0-9]{8}$'),
      ),
    ];
  }

  // Obtenir les pays les plus utilisés
  static List<Country> getPopularCountries() {
    return [
      Country.ghana(),
      Country.coteDIvoire(),
      Country.burkina(),
      Country.mali(),
    ];
  }

  // Rechercher un pays par code
  static Country? getCountryByCode(String code) {
    try {
      return getAllCountries().firstWhere(
        (country) => country.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Rechercher un pays par indicatif
  static Country? getCountryByDialCode(String dialCode) {
    try {
      return getAllCountries().firstWhere(
        (country) => country.dialCode == dialCode,
      );
    } catch (e) {
      return null;
    }
  }

  // Rechercher des pays par nom
  static List<Country> searchCountries(String query) {
    if (query.isEmpty) return getAllCountries();

    final lowerQuery = query.toLowerCase();
    return getAllCountries().where((country) {
      return country.name.toLowerCase().contains(lowerQuery) ||
          country.code.toLowerCase().contains(lowerQuery) ||
          country.dialCode.contains(query);
    }).toList();
  }

  // Pays par défaut (Côte d'Ivoire)
  static Country getDefaultCountry() {
    return Country.coteDIvoire();
  }

  // Détecter le pays depuis un numéro international
  static Country? detectCountryFromNumber(String phoneNumber) {
    // Nettoyer le numéro
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (!cleanNumber.startsWith('+')) {
      return null;
    }

    // Essayer de matcher avec les indicatifs existants
    for (final country in getAllCountries()) {
      if (cleanNumber.startsWith(country.dialCode)) {
        return country;
      }
    }

    return null;
  }
}