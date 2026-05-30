import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Barre de recherche textuelle de lieu (geocoding) — utilisée par
/// `InteractiveMapPicker`.
///
/// Submit explicite (clavier Enter ou tap sur la loupe). Le parent gère
/// l'appel backend et passe `loading: true` pendant la requête, puis
/// `error` non-null si la recherche a échoué (affiché inline rouge).
///
/// Style : container `bgElev1` + border `line` (focus → border accent 1.5px),
/// shadow douce pour ressortir sur la carte dark.
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
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  TextEditingController get _controller {
    if (widget.controller != null) return widget.controller!;
    return _internalCtrl ??= TextEditingController();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _internalCtrl?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    _focusNode.unfocus();
    widget.onSubmit(value);
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _hasFocus ? AppColors.accent : AppColors.line;
    final borderWidth = _hasFocus ? 1.5 : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              InkWell(
                onTap: widget.loading ? null : _submit,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: widget.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accent),
                          ),
                        )
                      : const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.text2,
                        ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => _submit(),
                  enabled: !widget.loading,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: AppColors.text3,
                      fontStyle: FontStyle.italic,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 14),
            child: Text(
              widget.error!,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
