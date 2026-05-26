import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/model/phone/country.dart';
import 'package:asfar/service/phone/countries_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Champ de saisie de numéro de téléphone du design system Asfar Premium.
///
/// Reproduit l'apparence de `InputField` (fond bgElev2, border focus accent or)
/// avec en plus un préfixe pays cliquable ainsi qu'un formatage live des
/// chiffres selon le format du pays sélectionné.
///
/// 2026-05-18 : le picker pays est désactivé visuellement (pays fixe Côte
/// d'Ivoire) car l'app cible un seul marché. L'infra `CountriesService` reste
/// branchable plus tard sans changer l'API du widget.
///
/// API :
/// - [onChanged] reçoit la version internationale `+225XXXXXXXXXX` (sans
///   espaces) à chaque saisie. Si le numéro est vide → string vide.
/// - [initialValue] peut être :
///   - un numéro national (`07 88 12 34` ou `0788123456`) → display formatté
///   - un numéro international (`+22507881234`) → préfixe pays retiré, reste affiché
class PhoneInputField extends StatefulWidget {
  final String? eyebrow;
  final String? hintText;
  final String? errorText;
  final String? initialValue;
  final void Function(String fullPhone)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;

  const PhoneInputField({
    super.key,
    this.eyebrow,
    this.hintText,
    this.errorText,
    this.initialValue,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.enabled = true,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late final Country _country;
  late final TextEditingController _ctrl;
  late final _PhoneFormatter _formatter;
  final bool _ownsController;

  _PhoneInputFieldState() : _ownsController = false;

  @override
  void initState() {
    super.initState();
    _country = CountriesService.getDefaultCountry();
    _formatter = _PhoneFormatter(_country);
    final externalController = widget.controller;
    if (externalController != null) {
      _ctrl = externalController;
    } else {
      _ctrl = TextEditingController();
    }
    final seed = _seedNational(widget.initialValue);
    if (seed.isNotEmpty && _ctrl.text.isEmpty) {
      _ctrl.text = _country.formatNumber(seed);
    }
  }

  @override
  void dispose() {
    if (_ownsController) _ctrl.dispose();
    super.dispose();
  }

  String _seedNational(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    var s = raw.trim();
    if (s.startsWith(_country.dialCode)) {
      s = s.substring(_country.dialCode.length);
    } else if (s.startsWith(_country.dialCode.replaceAll('+', ''))) {
      s = s.substring(_country.dialCode.length - 1);
    }
    return s.replaceAll(RegExp(r'[^\d]'), '');
  }

  void _onTextChange(String value) {
    final national = value.replaceAll(RegExp(r'[^\d]'), '');
    final full = national.isEmpty ? '' : _country.getFullNumber(national);
    widget.onChanged?.call(full);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.eyebrow != null) ...[
          Text(widget.eyebrow!, style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            _CountryPrefixChip(country: _country),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _ctrl,
                focusNode: widget.focusNode,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                enabled: widget.enabled,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _formatter,
                ],
                onChanged: _onTextChange,
                style: AppTextStyles.body.copyWith(color: AppColors.text),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? _country.format,
                  hintStyle:
                      AppTextStyles.body.copyWith(color: AppColors.text3),
                  errorText: widget.errorText,
                  filled: true,
                  fillColor: AppColors.bgElev2,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    borderSide: const BorderSide(color: AppColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    borderSide: const BorderSide(
                        color: AppColors.accent, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    borderSide: const BorderSide(color: AppColors.danger),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    borderSide: const BorderSide(
                        color: AppColors.danger, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pastille préfixe drapeau + dial code, non-cliquable tant que le picker
/// multi-pays n'est pas activé.
class _CountryPrefixChip extends StatelessWidget {
  final Country country;

  const _CountryPrefixChip({required this.country});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            country.dialCode,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formatter qui applique `country.format` (« ## ## ## ## ## ») au flux de
/// chiffres saisis, tronque au-delà de `country.maxLength`.
class _PhoneFormatter extends TextInputFormatter {
  final Country country;

  _PhoneFormatter(this.country);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits =
        newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final limited = digits.length > country.maxLength
        ? digits.substring(0, country.maxLength)
        : digits;
    final formatted = country.formatNumber(limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
