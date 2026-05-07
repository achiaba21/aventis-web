import 'dart:async';

import 'package:flutter/material.dart';
import 'package:asfar/model/geocoding/geocoding_result.dart';
import 'package:asfar/service/geocoding/geocoding_service.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Barre de recherche de lieux avec autocomplétion Nominatim.
///
/// Affiche un champ texte avec suggestions déroulantes.
/// Restreint la recherche à la Côte d'Ivoire (countrycodes: 'ci').
class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    required this.onLocationSelected,
  });

  /// Appelé quand l'utilisateur sélectionne une suggestion.
  final ValueChanged<GeocodingResult> onLocationSelected;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<GeocodingResult> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isLoading = true);

    final results = await GeocodingService.instance.autocomplete(
      query,
      limit: 5,
      countrycodes: 'ci',
    );

    if (mounted) {
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    }
  }

  void _onSuggestionSelected(GeocodingResult result) {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.text = result.name ?? result.displayName;
    _controller.addListener(_onTextChanged);

    setState(() => _suggestions = []);
    _focusNode.unfocus();
    widget.onLocationSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SearchField(
          controller: _controller,
          focusNode: _focusNode,
          isLoading: _isLoading,
        ),
        if (_suggestions.isNotEmpty)
          _SuggestionsList(
            suggestions: _suggestions,
            onSelected: _onSuggestionSelected,
          ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Rechercher un lieu, quartier, ville...',
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
        suffixIcon: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _SuggestionsList extends StatelessWidget {
  const _SuggestionsList({
    required this.suggestions,
    required this.onSelected,
  });

  final List<GeocodingResult> suggestions;
  final ValueChanged<GeocodingResult> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) => _SuggestionItem(
          result: suggestions[index],
          onTap: () => onSelected(suggestions[index]),
        ),
      ),
    );
  }
}

class _SuggestionItem extends StatelessWidget {
  const _SuggestionItem({
    required this.result,
    required this.onTap,
  });

  final GeocodingResult result;
  final VoidCallback onTap;

  String get _label {
    final parts = <String>[];
    if (result.name != null && result.name!.isNotEmpty) parts.add(result.name!);
    if (result.commune != null && result.commune!.isNotEmpty) parts.add(result.commune!);
    if (result.city != null && result.city!.isNotEmpty) parts.add(result.city!);
    return parts.isNotEmpty ? parts.join(', ') : result.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: TextSeed(
                _label,
                fontSize: 13,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
