import 'package:flutter/services.dart';

/// TextInputFormatter pour formater les nombres avec séparateurs de milliers
/// Permet uniquement les chiffres et le point décimal
class NumberInputFormatter extends TextInputFormatter {
  NumberInputFormatter({
    this.allowDecimals = true,
    this.decimalDigits = 2,
  });

  final bool allowDecimals;
  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si le texte est vide, on le laisse tel quel
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Nettoyer le texte : enlever tous les espaces et caractères non valides
    String cleanText = newValue.text.replaceAll(' ', '');

    // Vérifier les caractères autorisés
    if (allowDecimals) {
      // Autoriser chiffres et point
      if (!RegExp(r'^[0-9.]*$').hasMatch(cleanText)) {
        return oldValue;
      }

      // Vérifier qu'il n'y a qu'un seul point
      if (cleanText.split('.').length > 2) {
        return oldValue;
      }

      // Limiter le nombre de décimales
      if (cleanText.contains('.')) {
        final parts = cleanText.split('.');
        if (parts.length == 2 && parts[1].length > decimalDigits) {
          cleanText = '${parts[0]}.${parts[1].substring(0, decimalDigits)}';
        }
      }
    } else {
      // Autoriser uniquement les chiffres
      if (!RegExp(r'^[0-9]*$').hasMatch(cleanText)) {
        return oldValue;
      }
    }

    // Séparer partie entière et décimale
    final parts = cleanText.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Formater la partie entière avec des espaces tous les 3 chiffres
    String formattedInteger = _formatIntegerPart(integerPart);

    // Reconstruire le texte formaté
    String formattedText = formattedInteger;
    if (decimalPart != null) {
      formattedText += '.$decimalPart';
    }

    // Calculer la nouvelle position du curseur
    int cursorPosition = _calculateCursorPosition(
      oldValue.text,
      newValue.text,
      formattedText,
      newValue.selection.baseOffset,
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  /// Formate la partie entière avec des espaces tous les 3 chiffres
  String _formatIntegerPart(String integerPart) {
    if (integerPart.isEmpty) return '';

    final buffer = StringBuffer();
    int count = 0;

    // Parcourir de droite à gauche
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(integerPart[i]);
      count++;
    }

    // Inverser le résultat
    return buffer.toString().split('').reversed.join('');
  }

  /// Calcule la position correcte du curseur après formatage
  int _calculateCursorPosition(
    String oldText,
    String newText,
    String formattedText,
    int cursorOffset,
  ) {
    // Si on est à la fin du texte
    if (cursorOffset >= newText.length) {
      return formattedText.length;
    }

    // Compter le nombre de chiffres avant le curseur dans le texte non formaté
    int digitsBeforeCursor = 0;
    int currentPos = 0;

    for (int i = 0; i < cursorOffset && i < newText.length; i++) {
      if (newText[i] != ' ') {
        digitsBeforeCursor++;
      }
    }

    // Trouver la position correspondante dans le texte formaté
    int digitCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] != ' ') {
        digitCount++;
      }
      if (digitCount >= digitsBeforeCursor) {
        currentPos = i + 1;
        break;
      }
    }

    return currentPos.clamp(0, formattedText.length);
  }

  /// Formate un nombre pour l'affichage avec séparateurs de milliers
  static String formatAmount(num value, {int decimalDigits = 0}) {
    final parts = value.toStringAsFixed(decimalDigits).split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(' ');
      buffer.write(intPart[i]);
      count++;
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return decimalDigits > 0 && parts.length > 1
        ? '$formatted.${parts[1]}'
        : formatted;
  }

  /// Retire le formatage pour obtenir le nombre brut
  static String unformat(String formattedText) {
    return formattedText.replaceAll(' ', '');
  }

  /// Convertit le texte formaté en double
  static double? parseDouble(String formattedText) {
    final clean = unformat(formattedText);
    return double.tryParse(clean);
  }

  /// Convertit le texte formaté en int
  static int? parseInt(String formattedText) {
    final clean = unformat(formattedText);
    return int.tryParse(clean);
  }
}
