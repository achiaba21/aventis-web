import 'package:flutter/material.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/number_input_formatter.dart';

/// Widget spécialisé pour la saisie de nombres (prix, montants, quantités)
/// Formate automatiquement avec séparateurs de milliers
class NumberInputField extends StatelessWidget {
  const NumberInputField({
    super.key,
    this.libelle,
    this.placeHolder,
    this.initialValue,
    this.onValueChanged,
    this.validator,
    this.allowDecimals = true,
    this.decimalDigits = 2,
    this.minValue,
    this.maxValue,
    this.leftIcon,
    this.rightIcon,
  });

  final String? libelle;
  final String? placeHolder;
  final double? initialValue;
  final Function(double?)? onValueChanged;
  final String? Function(double?)? validator;
  final bool allowDecimals;
  final int decimalDigits;
  final double? minValue;
  final double? maxValue;
  final Widget? leftIcon;
  final Widget? rightIcon;

  @override
  Widget build(BuildContext context) {
    // Formater la valeur initiale si elle existe
    String? formattedInitialValue;
    if (initialValue != null) {
      formattedInitialValue = helpAmountFormate(
        initialValue,
        decim: allowDecimals,
      );
    }

    return InputField(
      libelle: libelle,
      placeHolder: placeHolder,
      initialValue: formattedInitialValue,
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowDecimals,
        signed: false,
      ),
      leftIcon: leftIcon,
      rightIcon: rightIcon,
      inputFormatters: [
        NumberInputFormatter(
          allowDecimals: allowDecimals,
          decimalDigits: decimalDigits,
        ),
      ],
      onChange: (formattedValue) {
        if (onValueChanged != null) {
          // Convertir le texte formaté en double
          final value = NumberInputFormatter.parseDouble(formattedValue ?? '');
          onValueChanged!(value);
        }
      },
      validator: validator != null
          ? (formattedValue) {
              final value = NumberInputFormatter.parseDouble(formattedValue ?? '');
              return validator!(value);
            }
          : (formattedValue) {
              // Validation par défaut
              if (formattedValue == null || formattedValue.isEmpty) {
                return null; // Pas d'erreur si vide (sauf si required)
              }

              final value = NumberInputFormatter.parseDouble(formattedValue);
              if (value == null) {
                return "Nombre invalide";
              }

              // Vérifier min/max
              if (minValue != null && value < minValue!) {
                return "La valeur doit être au moins ${helpAmountFormate(minValue, decim: allowDecimals)}";
              }
              if (maxValue != null && value > maxValue!) {
                return "La valeur doit être au maximum ${helpAmountFormate(maxValue, decim: allowDecimals)}";
              }

              return null;
            },
    );
  }
}
