import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/pays_bloc/pays_bloc.dart';
import 'package:asfar/bloc/pays_bloc/pays_event.dart';
import 'package:asfar/bloc/pays_bloc/pays_state.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/locolite/lieux/commune.dart';
import 'package:asfar/model/locolite/lieux/pays.dart';
import 'package:asfar/model/locolite/lieux/ville.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/gps_capture_card.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/searchable_select.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/wizard_stepper_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Étape 2 du wizard d'ajout d'appartement — titre, localisation, capacité.
///
/// V9.1b : consomme `PaysBloc` (déjà providé dans `main.dart:109`) pour
/// charger l'arbre Pays → Region → Ville → Commune depuis le backend
/// (`GET /api/lieux/pays`). Plus de constantes hardcodées : l'admin Asfar
/// peut désormais ajouter/retirer villes/communes via la BDD.
class StepLocationAndCapacity extends StatefulWidget {
  final Address? address;
  final String? title;
  final String? description;
  final int chambres;
  final int douches;
  final bool isLoadingGeo;
  final void Function(String field, dynamic value) onFieldChange;
  final VoidCallback onRequestGps;

  const StepLocationAndCapacity({
    super.key,
    required this.address,
    required this.title,
    required this.description,
    required this.chambres,
    required this.douches,
    required this.isLoadingGeo,
    required this.onFieldChange,
    required this.onRequestGps,
  });

  @override
  State<StepLocationAndCapacity> createState() =>
      _StepLocationAndCapacityState();
}

class _StepLocationAndCapacityState extends State<StepLocationAndCapacity> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<PaysBloc>().state;
      if (state is PaysInitial || state is PaysError) {
        // Backend 2026-05-13 : `/api/lieux/pays/CI` retourne l'arbre nested
        // complet (régions → villes → communes) seedé pour la Côte d'Ivoire.
        // On évite `LoadAllPays` qui chargerait tous les pays (inutile ici).
        context.read<PaysBloc>().add(LoadPaysByCode('ci'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaysBloc, PaysState>(
      builder: (context, paysState) {
        final List<Ville> allVilles = _flatVilles(paysState);
        final Ville? selectedVille = _findVille(
          allVilles,
          widget.address?.commune?.ville?.nom,
        );
        final List<Commune> communesForCity =
            selectedVille?.communes ?? const [];

        return _StepLocationContent(
          address: widget.address,
          title: widget.title,
          description: widget.description,
          chambres: widget.chambres,
          douches: widget.douches,
          isLoadingGeo: widget.isLoadingGeo,
          onFieldChange: widget.onFieldChange,
          onRequestGps: widget.onRequestGps,
          paysState: paysState,
          allVilles: allVilles,
          selectedVille: selectedVille,
          communesForCity: communesForCity,
        );
      },
    );
  }

  /// Aplatit `Pays > Region > Ville` en une liste plate de villes.
  List<Ville> _flatVilles(PaysState state) {
    final List<Pays> pays = _paysListFrom(state);
    final List<Ville> villes = [];
    for (final p in pays) {
      for (final region in p.regions ?? const <dynamic>[]) {
        for (final v in region.villes ?? const []) {
          villes.add(v);
        }
      }
    }
    return villes;
  }

  List<Pays> _paysListFrom(PaysState state) {
    if (state is AllPaysLoaded) return state.paysList;
    if (state is SinglePaysLoaded) return [state.pays];
    return const [];
  }

  Ville? _findVille(List<Ville> villes, String? name) {
    if (name == null) return null;
    for (final v in villes) {
      if (v.nom == name) return v;
    }
    return null;
  }
}

class _StepLocationContent extends StatelessWidget {
  final Address? address;
  final String? title;
  final String? description;
  final int chambres;
  final int douches;
  final bool isLoadingGeo;
  final void Function(String field, dynamic value) onFieldChange;
  final VoidCallback onRequestGps;
  final PaysState paysState;
  final List<Ville> allVilles;
  final Ville? selectedVille;
  final List<Commune> communesForCity;

  const _StepLocationContent({
    required this.address,
    required this.title,
    required this.description,
    required this.chambres,
    required this.douches,
    required this.isLoadingGeo,
    required this.onFieldChange,
    required this.onRequestGps,
    required this.paysState,
    required this.allVilles,
    required this.selectedVille,
    required this.communesForCity,
  });

  @override
  Widget build(BuildContext context) {
    final Address current = address ?? Address();
    final String? cityName = selectedVille?.nom;
    final String? communeName = current.commune?.nom;
    final LatLng? gps = current.exactLocation;
    final bool isLoadingPays = paysState is PaysLoading;

    final villeOptions = allVilles
        .map((v) => v.nom ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final communeOptions = communesForCity
        .map((c) => c.nom ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Localisation', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Choisissez la ville, la commune, puis précisez le quartier.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        _LabeledTextField(
          label: "Titre de l'annonce",
          initialValue: title ?? '',
          hint: 'ex. Belle 2 pièces — Cocody',
          onChanged: (v) => onFieldChange('titre', v),
        ),
        SearchableSelect(
          label: 'Ville',
          value: cityName,
          options: villeOptions,
          placeholder: isLoadingPays
              ? 'Chargement…'
              : 'Rechercher une ville…',
          onChange: (v) => _onCityChange(v, current),
        ),
        SearchableSelect(
          label: 'Commune',
          value: communeName,
          options: communeOptions,
          placeholder: cityName == null
              ? "Sélectionnez d'abord une ville"
              : 'Rechercher une commune…',
          onChange: (v) => _onCommuneChange(v, current),
        ),
        _LabeledTextField(
          label: 'Quartier',
          initialValue: current.nom ?? '',
          hint: 'ex. II Plateaux Vallon, Riviera Bonoumin…',
          helperText: 'Saisie libre — votre quartier précis ou résidence.',
          onChanged: (v) => onFieldChange('addressNom', v),
        ),
        GpsCaptureCard(
          gps: gps,
          loading: isLoadingGeo,
          onCapture: onRequestGps,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: WizardStepperRow(
                label: 'Chambres',
                value: chambres,
                min: 0,
                max: 10,
                onChange: (v) => onFieldChange('nbChambres', v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WizardStepperRow(
                label: 'SdB',
                value: douches,
                min: 0,
                max: 10,
                onChange: (v) => onFieldChange('nbDouches', v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _LabeledTextField(
          label: 'Description (optionnel)',
          initialValue: description ?? '',
          hint:
              'Résidence meublée lumineuse, proche commerces, gardiennage 24/7…',
          maxLines: 5,
          minLines: 3,
          onChanged: (v) => onFieldChange('description', v),
        ),
      ],
    );
  }

  void _onCityChange(String newCityName, Address current) {
    Ville? matched;
    for (final v in allVilles) {
      if (v.nom == newCityName) {
        matched = v;
        break;
      }
    }
    if (matched == null) return;

    // Reset commune (incohérent avec ancienne ville).
    final updated = Address(
      id: current.id,
      lat: current.lat,
      longi: current.longi,
      nom: current.nom,
      description: current.description,
      geoLat: current.geoLat,
      geoLongi: current.geoLongi,
      commune: Commune(ville: matched),
    );
    onFieldChange('address', updated);
  }

  void _onCommuneChange(String newCommuneName, Address current) {
    Commune? matched;
    for (final c in communesForCity) {
      if (c.nom == newCommuneName) {
        matched = c;
        break;
      }
    }
    if (matched == null) return;

    // Préserver la ville (déjà sélectionnée) en l'associant à la commune.
    final ville = current.commune?.ville ?? selectedVille;
    final updated = Address(
      id: current.id,
      lat: current.lat,
      longi: current.longi,
      nom: current.nom,
      description: current.description,
      geoLat: current.geoLat,
      geoLongi: current.geoLongi,
      commune: Commune(
        id: matched.id,
        nom: matched.nom,
        code: matched.code,
        ville: ville,
      ),
    );
    onFieldChange('address', updated);
  }
}

class _LabeledTextField extends StatefulWidget {
  final String label;
  final String initialValue;
  final String hint;
  final String? helperText;
  final int? minLines;
  final int? maxLines;
  final ValueChanged<String> onChanged;

  const _LabeledTextField({
    required this.label,
    required this.initialValue,
    required this.hint,
    required this.onChanged,
    this.helperText,
    this.minLines,
    this.maxLines = 1,
  });

  @override
  State<_LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<_LabeledTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _LabeledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _ctrl.text && !_ctrl.selection.isValid) {
      _ctrl.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label.toUpperCase(), style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            onChanged: widget.onChanged,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            style: const TextStyle(fontSize: 14, color: AppColors.text),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.small.copyWith(
                fontSize: 13,
                color: AppColors.text3,
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          if (widget.helperText != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.helperText!,
              style: AppTextStyles.small.copyWith(
                fontSize: 11,
                height: 1.5,
                color: AppColors.text3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
