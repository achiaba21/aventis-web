import 'package:flutter/services.dart';
import 'package:asfar/model/phone/country.dart';

class PhoneInputFormatter extends TextInputFormatter {
  final Country country;

  PhoneInputFormatter(this.country);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Garder seulement les chiffres
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limiter à la longueur maximale du pays
    if (newText.length > country.maxLength) {
      newText = newText.substring(0, country.maxLength);
    }

    // Formater selon le pattern du pays
    String formattedText = _applyFormat(newText, country.format);

    // Calculer la nouvelle position du curseur
    int newOffset = _calculateCursorPosition(
      oldValue.text,
      newValue.text,
      formattedText,
      newValue.selection.baseOffset,
    );

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, formattedText.length),
      ),
    );
  }

  String _applyFormat(String number, String format) {
    if (number.isEmpty) return '';

    String formatted = '';
    int numberIndex = 0;

    for (int i = 0; i < format.length && numberIndex < number.length; i++) {
      if (format[i] == '#') {
        formatted += number[numberIndex];
        numberIndex++;
      } else {
        formatted += format[i];
      }
    }

    return formatted;
  }

  int _calculateCursorPosition(
    String oldText,
    String newText,
    String formattedText,
    int cursorPosition,
  ) {
    // Si on supprime des caractères
    if (newText.length < oldText.length) {
      // Compter les chiffres avant la position du curseur
      int digitsBeforeCursor = 0;
      for (int i = 0; i < cursorPosition && i < newText.length; i++) {
        if (RegExp(r'\d').hasMatch(newText[i])) {
          digitsBeforeCursor++;
        }
      }

      // Trouver la position correspondante dans le texte formaté
      int newPosition = 0;
      int digitCount = 0;
      for (int i = 0; i < formattedText.length; i++) {
        if (RegExp(r'\d').hasMatch(formattedText[i])) {
          digitCount++;
          if (digitCount > digitsBeforeCursor) {
            break;
          }
        }
        newPosition++;
      }
      return newPosition;
    } else {
      // Pour l'ajout de caractères, placer le curseur à la fin
      return formattedText.length;
    }
  }
}