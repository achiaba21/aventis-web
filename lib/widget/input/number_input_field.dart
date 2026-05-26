import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Champ de saisie numérique unifié du design system Asfar Premium.
///
/// Couvre tous les inputs nombre du projet :
/// - **Montants FCFA** → `formatThousands: true`, `suffix: 'FCFA'`
///   (saisie `75000` → affiché `75 000 FCFA`)
/// - **Nombres simples** (capacités, nuits, etc.) → propriétés par défaut
///   (saisie `7` → affiché `7`)
///
/// Comportement commun à tous les modes :
/// - Clavier numérique pur (pas de `+`, `*`, `#`)
/// - Filtre `digitsOnly` ⇒ aucun caractère non numérique
/// - `onChanged(int? value)` typed (null si champ vide)
/// - Style mono optionnel pour les colonnes financières
class NumberInputField extends StatefulWidget {
  final String? eyebrow;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final int? initialValue;
  final void Function(int? value)? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;

  /// Formate la saisie avec séparateurs de milliers (`75 000`). À activer
  /// pour les montants ; laisser `false` pour les compteurs simples.
  final bool formatThousands;

  /// Suffixe affiché à droite du champ (ex. `FCFA`, `nuits`). Null = pas de
  /// suffixe.
  final String? suffix;

  /// Préfixe icône optionnel (ex. `Icons.attach_money`).
  final IconData? leadingIcon;

  /// Longueur maximale en chiffres saisis. Utile pour `OTP`, `capacités`, etc.
  final int? maxDigits;

  /// Style mono (chiffres tabulaires) pour les colonnes financières.
  final bool useMonoStyle;

  /// Style texte override (priorité sur [useMonoStyle]). Permet aux call sites
  /// hero d'imposer fontSize/poids custom (ex. wizard prix par nuit).
  final TextStyle? textStyle;

  const NumberInputField({
    super.key,
    this.eyebrow,
    this.hintText,
    this.errorText,
    this.helperText,
    this.initialValue,
    this.onChanged,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.formatThousands = false,
    this.suffix,
    this.leadingIcon,
    this.maxDigits,
    this.useMonoStyle = false,
    this.textStyle,
  });

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  late final TextEditingController _ctrl;
  late final bool _ownsController;
  late final List<TextInputFormatter> _formatters;

  @override
  void initState() {
    super.initState();
    final external = widget.controller;
    if (external != null) {
      _ctrl = external;
      _ownsController = false;
    } else {
      _ctrl = TextEditingController();
      _ownsController = true;
    }
    _formatters = [
      FilteringTextInputFormatter.digitsOnly,
      if (widget.maxDigits != null)
        LengthLimitingTextInputFormatter(widget.maxDigits),
      if (widget.formatThousands) const _ThousandsFormatter(),
    ];
    final iv = widget.initialValue;
    if (iv != null && iv >= 0 && _ctrl.text.isEmpty) {
      _ctrl.text = widget.formatThousands
          ? FcfaFormatter.groupThousands(iv)
          : iv.toString();
    } else if (widget.formatThousands && _ctrl.text.isNotEmpty) {
      // Le controller externe contient déjà une valeur (cas édition) → on la
      // reformatte pour appliquer les séparateurs de milliers.
      final digits = _ctrl.text.replaceAll(RegExp(r'[^\d]'), '');
      final parsed = int.tryParse(digits);
      if (parsed != null) {
        _ctrl.text = FcfaFormatter.groupThousands(parsed);
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) _ctrl.dispose();
    super.dispose();
  }

  void _onTextChange(String value) {
    final clean = value.replaceAll(RegExp(r'[^\d]'), '');
    if (clean.isEmpty) {
      widget.onChanged?.call(null);
      return;
    }
    widget.onChanged?.call(int.tryParse(clean));
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.body.copyWith(color: AppColors.text);
    final resolvedStyle = widget.textStyle ??
        (widget.useMonoStyle ? AppTextStyles.mono(baseStyle) : baseStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.eyebrow != null) ...[
          Text(widget.eyebrow!, style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _ctrl,
          focusNode: widget.focusNode,
          keyboardType: const TextInputType.numberWithOptions(
              signed: false, decimal: false),
          enabled: widget.enabled,
          inputFormatters: _formatters,
          onChanged: _onTextChange,
          style: resolvedStyle,
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperStyle:
                AppTextStyles.small.copyWith(color: AppColors.text3),
            prefixIcon: widget.leadingIcon != null
                ? Icon(widget.leadingIcon, size: 18, color: AppColors.text3)
                : null,
            suffixText: widget.suffix,
            suffixStyle: AppTextStyles.small.copyWith(
              fontSize: 13,
              color: AppColors.text2,
              fontWeight: FontWeight.w600,
            ),
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
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Formatter qui applique un groupage des milliers (`75 000`) sur les
/// chiffres saisis. Utilise [FcfaFormatter.groupThousands] pour rester
/// aligné sur le formatage d'affichage (espace insécable).
class _ThousandsFormatter extends TextInputFormatter {
  const _ThousandsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }
    final value = int.tryParse(digits);
    if (value == null) return oldValue;
    final formatted = FcfaFormatter.groupThousands(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
