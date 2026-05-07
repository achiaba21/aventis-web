import 'package:asfar/model/phone/country.dart';

class PhoneNumber {
  final Country? country;
  final String? nationalNumber;
  final String? rawNumber;

  const PhoneNumber({
     this.country,
     this.nationalNumber,
     this.rawNumber,
  });

  // Numéro formaté selon le pays
  String get formattedNumber => country?.formatNumber(nationalNumber) ?? "";

  // Numéro complet avec indicatif
  String get internationalFormat => country?.getFullNumber(nationalNumber) ?? "";

  // Validation du numéro
  bool get isValid => country?.isValidNumber(nationalNumber) ?? false;

  // Numéro nettoyé (chiffres uniquement)
  String get cleanNumber => nationalNumber?.replaceAll(RegExp(r'[^\d]'), '') ?? "";

  // Numéro pour affichage
  String get displayNumber => formattedNumber.isNotEmpty ? formattedNumber : nationalNumber ?? "";

  // Créer depuis un numéro brut
  factory PhoneNumber.fromRaw(String rawNumber, Country country) {
    String cleanNumber = rawNumber.replaceAll(RegExp(r'[^\d]'), '');
    return PhoneNumber(
      country: country,
      nationalNumber: cleanNumber,
      rawNumber: rawNumber,
    );
  }

  // Créer un numéro vide
  factory PhoneNumber.empty(Country country) {
    return PhoneNumber(
      country: country,
      nationalNumber: '',
      rawNumber: '',
    );
  }

  // Copier avec modifications
  PhoneNumber copyWith({
    Country? country,
    String? nationalNumber,
    String? rawNumber,
  }) {
    return PhoneNumber(
      country: country ?? this.country,
      nationalNumber: nationalNumber ?? this.nationalNumber,
      rawNumber: rawNumber ?? this.rawNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumber &&
          runtimeType == other.runtimeType &&
          country == other.country &&
          nationalNumber == other.nationalNumber;

  @override
  int get hashCode => country.hashCode ^ nationalNumber.hashCode;

  @override
  String toString() => internationalFormat;
}