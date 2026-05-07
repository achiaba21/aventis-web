import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/locolite/lieux/commune.dart';
import 'package:asfar/model/locolite/lieux/ville.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/map_filter_section.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/texte_filter_section.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class FilterBar extends StatelessWidget {
  final TextEditingController nbPiecesController;
  final List<Ville> villes;
  final List<Commune> communes;
  final Ville? selectedVille;
  final Commune? selectedCommune;
  final ValueChanged<Ville?> onVilleChanged;
  final ValueChanged<Commune?> onCommuneChanged;
  final LatLng? mapCenter;
  final VoidCallback onPickLocation;
  final VoidCallback onClearLocation;
  final VoidCallback onReset;

  const FilterBar({
    super.key,
    required this.nbPiecesController,
    required this.villes,
    required this.communes,
    required this.selectedVille,
    required this.selectedCommune,
    required this.onVilleChanged,
    required this.onCommuneChanged,
    required this.mapCenter,
    required this.onPickLocation,
    required this.onClearLocation,
    required this.onReset,
  });

  bool get _hasActiveFilters {
    final hasText = nbPiecesController.text.trim().isNotEmpty;
    final hasVille = selectedVille != null;
    final hasCommune = selectedCommune != null;
    final hasMap = mapCenter != null;
    return hasText || hasVille || hasCommune || hasMap;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.all(Espacement.paddingBloc),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TexteFilterSection(
            villes: villes,
            communes: communes,
            selectedVille: selectedVille,
            selectedCommune: selectedCommune,
            onVilleChanged: onVilleChanged,
            onCommuneChanged: onCommuneChanged,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _NbPiecesField(controller: nbPiecesController)),
              const SizedBox(width: 12),
              MapFilterSection(
                mapCenter: mapCenter,
                onPickLocation: onPickLocation,
                onClearLocation: onClearLocation,
              ),
            ],
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onReset,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.restart_alt, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  TextSeed('Réinitialiser', fontSize: 12, color: AppColors.textMuted),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NbPiecesField extends StatelessWidget {
  final TextEditingController controller;

  const _NbPiecesField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Nb de pièces',
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(Icons.door_front_door_outlined, color: AppColors.textMuted, size: 18),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc,
          vertical: 10,
        ),
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
