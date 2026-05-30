import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Barre de recherche textuelle de lieu (geocoding) — utilisée par
/// `InteractiveMapPicker`.
///
/// S'appuie sur l'atome [InputField] du design system (même rendu que la
/// recherche messagerie / locataire) : fond `bgElev2`, border `line`, focus
/// accent, hint gris non italique. Submit explicite (Enter clavier). Pendant
/// le chargement, l'icône loupe laisse place à un petit spinner. `error`
/// non-null affiche un message inline rouge sous le champ.
class MapSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final bool loading;
  final String? error;
  final ValueChanged<String> onSubmit;
  final ValueChanged<String>? onChanged;
  final String hint;

  const MapSearchBar({
    super.key,
    this.controller,
    this.loading = false,
    this.error,
    required this.onSubmit,
    this.onChanged,
    this.hint = 'Rechercher un quartier, une adresse…',
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  TextEditingController? _internalCtrl;

  TextEditingController get _controller {
    if (widget.controller != null) return widget.controller!;
    return _internalCtrl ??= TextEditingController();
  }

  @override
  void dispose() {
    _internalCtrl?.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final v = value.trim();
    if (v.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(v);
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
      controller: _controller,
      hintText: widget.hint,
      leadingIcon: widget.loading ? null : Icons.search,
      readOnly: widget.loading,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: _submit,
      errorText: widget.error,
      trailing: widget.loading
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            )
          : null,
    );
  }
}
