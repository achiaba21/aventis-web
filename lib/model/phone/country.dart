class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  final String format;
  final int maxLength;
  final RegExp validationRegex;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.format,
    required this.maxLength,
    required this.validationRegex,
  });

  // Pays par défaut populaires
  static Country ghana() => Country(
    name: "Ghana",
    code: "GH",
    dialCode: "+233",
    flag: "🇬🇭",
    format: "## ### ####",
    maxLength: 9,
    validationRegex: RegExp(r'^[0-9]{9}$'),
  );

  static Country coteDIvoire() => Country(
    name: "Côte d'Ivoire",
    code: "CI",
    dialCode: "+225",
    flag: "🇨🇮",
    format: "## ## ## ## ##",
    maxLength: 10,
    validationRegex: RegExp(r'^[0-9]{10}$'),
  );

  static Country france() => Country(
    name: "France",
    code: "FR",
    dialCode: "+33",
    flag: "🇫🇷",
    format: "## ## ## ## ##",
    maxLength: 10,
    validationRegex: RegExp(r'^[0-9]{10}$'),
  );

  static Country burkina() => Country(
    name: "Burkina Faso",
    code: "BF",
    dialCode: "+226",
    flag: "🇧🇫",
    format: "## ## ## ##",
    maxLength: 8,
    validationRegex: RegExp(r'^[0-9]{8}$'),
  );

  static Country mali() => Country(
    name: "Mali",
    code: "ML",
    dialCode: "+223",
    flag: "🇲🇱",
    format: "## ## ## ##",
    maxLength: 8,
    validationRegex: RegExp(r'^[0-9]{8}$'),
  );

  // Format le numéro selon le pattern du pays
  String formatNumber(String? number) {
    if (number == null || number.isEmpty) return '';

    String cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';
    int formatIndex = 0;

    for (int i = 0; i < cleanNumber.length && formatIndex < format.length; i++) {
      if (format[formatIndex] == '#') {
        formatted += cleanNumber[i];
      } else {
        formatted += format[formatIndex];
        i--; // Revenir en arrière pour traiter le même chiffre
      }
      formatIndex++;
    }

    return formatted;
  }

  // Valide le numéro selon les règles du pays
  bool isValidNumber(String? number) {
    String cleanNumber = number?.replaceAll(RegExp(r'[^\d]'), '') ?? "";
    return validationRegex.hasMatch(cleanNumber);
  }

  // Numéro complet avec indicatif
  String getFullNumber(String? nationalNumber) {
    String cleanNumber = nationalNumber?.replaceAll(RegExp(r'[^\d]'), '') ?? "";
    return '$dialCode$cleanNumber';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$flag $name ($dialCode)';
}