enum AppartementStatus {
  DISPONIBLE,
  OCCUPE,
  EN_MAINTENANCE,
  INACTIF,
}

extension AppartementStatusExtension on AppartementStatus {
  String get value {
    return name;
  }

  static AppartementStatus? fromString(String? value) {
    if (value == null) return null;
    try {
      return AppartementStatus.values.firstWhere(
        (e) => e.name == value,
      );
    } catch (e) {
      return null;
    }
  }
}
