class CustomException implements Exception {
  String message;

  CustomException([this.message = "Une erreur est survenue"]);
}
