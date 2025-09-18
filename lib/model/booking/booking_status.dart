enum BookingStatus {
  en_attente,
  confirme,
  refuse,
  annule,
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.en_attente:
        return "En attente";
      case BookingStatus.confirme:
        return "Confirmé";
      case BookingStatus.refuse:
        return "Refusé";
      case BookingStatus.annule:
        return "Annulé";
    }
  }

  String get value {
    switch (this) {
      case BookingStatus.en_attente:
        return "en_attente";
      case BookingStatus.confirme:
        return "confirme";
      case BookingStatus.refuse:
        return "refuse";
      case BookingStatus.annule:
        return "annule";
    }
  }

  static BookingStatus fromString(String value) {
    switch (value) {
      case "en_attente":
        return BookingStatus.en_attente;
      case "confirme":
        return BookingStatus.confirme;
      case "refuse":
        return BookingStatus.refuse;
      case "annule":
        return BookingStatus.annule;
      default:
        return BookingStatus.en_attente;
    }
  }
}