import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Dropdown searchable utilisé pour Ville / Commune dans le wizard d'ajout.
///
/// Reproduit `proprietaire-extras.jsx::SearchableSelect` (lignes 288-366)
/// **sans l'option "Autre — saisir manuellement"** (hors scope MVP V9.1).
///
/// Field cliquable → `showModalBottomSheet` avec search + ListView filtrée.
class SearchableSelect extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChange;
  final String? placeholder;

  const SearchableSelect({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChange,
    this.placeholder,
  });

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SearchablePickerSheet(
        label: label,
        options: options,
        currentValue: value,
        placeholder: placeholder ?? 'Rechercher…',
      ),
    );
    if (selected != null) onChange(selected);
  }

  @override
  Widget build(BuildContext context) {
    final String display = value ??
        'Sélectionner — ${label.toLowerCase()}';
    final Color displayColor =
        value != null ? AppColors.text : AppColors.text3;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openPicker(context),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgElev2,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.line, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        display,
                        style: TextStyle(
                          fontSize: 14,
                          color: displayColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: AppColors.text3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal sheet contenant la search + liste filtrée.
class _SearchablePickerSheet extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? currentValue;
  final String placeholder;

  const _SearchablePickerSheet({
    required this.label,
    required this.options,
    required this.currentValue,
    required this.placeholder,
  });

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.isEmpty) return widget.options;
    final q = _query.toLowerCase();
    return widget.options
        .where((o) => o.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 8, 18, 18 + viewInsets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bgElev3,
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.label, style: AppTextStyles.h3),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontSize: 14, color: AppColors.text),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              prefixIcon: const Icon(Icons.search,
                  size: 18, color: AppColors.text3),
              filled: true,
              fillColor: AppColors.bgElev2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide:
                    const BorderSide(color: AppColors.line, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide:
                    const BorderSide(color: AppColors.line, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: _filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Aucun résultat pour « $_query »',
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.text3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final option = _filtered[i];
                      final bool selected = option == widget.currentValue;
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(option),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentSoft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: selected
                                        ? AppColors.accent
                                        : AppColors.text,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check,
                                    size: 16, color: AppColors.accent),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
