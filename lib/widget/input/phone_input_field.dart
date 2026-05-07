import 'package:flutter/material.dart';
import 'package:asfar/model/phone/country.dart';
import 'package:asfar/model/phone/phone_number.dart';
import 'package:asfar/service/phone/countries_service.dart';
import 'package:asfar/widget/input/country_selector_widget.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/phone_input_formatter.dart';
import 'package:asfar/theme/app_colors.dart';

class PhoneInputField extends StatefulWidget {
  const PhoneInputField({
    super.key,
    this.libelle,
    this.controller,
    this.initialCountry,
    this.onCountryChanged,
    this.onPhoneChanged,
    this.validator,
    this.showCountrySelector = true,
    this.enabled = true,
  });

  final String? libelle;
  final TextEditingController? controller;
  final Country? initialCountry;
  final Function(Country)? onCountryChanged;
  final Function(PhoneNumber)? onPhoneChanged;
  final String? Function(String?)? validator;
  final bool showCountrySelector;
  final bool enabled;

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late Country _selectedCountry;
  late TextEditingController _phoneController;
  PhoneInputFormatter? _formatter;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? CountriesService.getDefaultCountry();
    _phoneController = widget.controller ?? TextEditingController();
    _formatter = PhoneInputFormatter(_selectedCountry);

    // Écouter les changements du contrôleur
    _phoneController.addListener(_onPhoneTextChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneTextChanged);
    if (widget.controller == null) {
      _phoneController.dispose();
    }
    super.dispose();
  }

  void _onPhoneTextChanged() {
    final phoneNumber = PhoneNumber.fromRaw(_phoneController.text, _selectedCountry);
    widget.onPhoneChanged?.call(phoneNumber);
  }

  void _onCountryChanged(Country country) {
    setState(() {
      _selectedCountry = country;
      _formatter = PhoneInputFormatter(country);
    });

    // Reformater le texte existant avec le nouveau pays
    final currentText = _phoneController.text;
    final cleanNumber = currentText.replaceAll(RegExp(r'[^\d]'), '');
    final formattedText = country.formatNumber(cleanNumber);

    _phoneController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );

    widget.onCountryChanged?.call(country);
    _onPhoneTextChanged();
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      libelle: widget.libelle,
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      leftIcon: widget.showCountrySelector ? _buildCountrySelector() : null,
      rightIcon: _buildValidationIcon(),
      inputFormatters: _formatter != null ? [_formatter!] : null,
      validator: _buildValidator(),
      placeHolder: _selectedCountry.format,
      onChange: (value) {
        // Le callback onChange est géré via le listener du contrôleur
        return value;
      },
    );
  }

  Widget _buildCountrySelector() {
    if (!widget.enabled) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedCountry.flag),
            SizedBox(width: 4),
            Text(
              _selectedCountry.dialCode,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return CountrySelector(
      selectedCountry: _selectedCountry,
      onCountrySelected: _onCountryChanged,
    );
  }

  Widget? _buildValidationIcon() {
    final phoneNumber = PhoneNumber.fromRaw(_phoneController.text, _selectedCountry);

    if (_phoneController.text.isEmpty) {
      return null;
    }

    if (phoneNumber.isValid) {
      return Icon(
        Icons.check_circle,
        color: AppColors.success,
        size: 20,
      );
    } else {
      return Icon(
        Icons.error,
        color: AppColors.error,
        size: 20,
      );
    }
  }

  String? Function(String?)? _buildValidator() {
    return (value) {
      // Validation personnalisée du widget
      if (widget.validator != null) {
        final customValidation = widget.validator!(value);
        if (customValidation != null) {
          return customValidation;
        }
      }

      // Validation téléphone par défaut
      if (value == null || value.isEmpty) {
        return 'Veuillez saisir un numéro de téléphone';
      }

      final phoneNumber = PhoneNumber.fromRaw(value, _selectedCountry);
      if (!phoneNumber.isValid) {
        return 'Numéro de téléphone invalide pour ${_selectedCountry.name}';
      }

      return null;
    };
  }

  // Méthodes publiques pour contrôler le widget
  PhoneNumber get phoneNumber => PhoneNumber.fromRaw(_phoneController.text, _selectedCountry);

  Country get selectedCountry => _selectedCountry;

  void setCountry(Country country) {
    _onCountryChanged(country);
  }

  void setPhoneNumber(String phoneNumber) {
    _phoneController.text = phoneNumber;
  }

  void clear() {
    _phoneController.clear();
  }
}