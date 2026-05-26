import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/user/participant_mini.dart';
import 'package:asfar/screen/client/demarcheur/listings/listing_filters.dart';
import 'package:asfar/screen/client/demarcheur/listings/widget/listing_partenaire_picker.dart';
import 'package:asfar/screen/client/demarcheur/listings/widget/listing_zone_picker.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran plein de filtres pour "Choisir un logement".
///
/// Sections dynamiques (masquées si < 2 valeurs uniques) :
/// - Pièces : chips multi-select (AsfarChip)
/// - Partenaire : picker bottom sheet (tile + coche)
/// - Zone : picker bottom sheet (tile + coche)
///
/// Retourne un [ListingFilters] validé via [Navigator.pop] ou `null` si annulé.
class ListingFilterScreen extends StatefulWidget {
  final List<Appartement> allApparts;
  final ListingFilters current;

  const ListingFilterScreen({
    super.key,
    required this.allApparts,
    required this.current,
  });

  @override
  State<ListingFilterScreen> createState() => _ListingFilterScreenState();
}

class _ListingFilterScreenState extends State<ListingFilterScreen> {
  late ListingFilters _draft;

  // Options extraites du dataset
  late final List<AppartementTypeLocation> _availableTypes;
  late final List<ParticipantMini> _availablePartenaires;
  late final List<String> _availableZones;

  @override
  void initState() {
    super.initState();
    _draft = widget.current;
    _availableTypes = _extractTypes();
    _availablePartenaires = _extractPartenaires();
    _availableZones = _extractZones();
  }

  List<AppartementTypeLocation> _extractTypes() {
    final seen = <AppartementTypeLocation>{};
    for (final a in widget.allApparts) {
      if (a.typeLocation != null) seen.add(a.typeLocation!);
    }
    // Respecter l'ordre de l'enum
    return AppartementTypeLocation.values
        .where(seen.contains)
        .toList();
  }

  List<ParticipantMini> _extractPartenaires() {
    final seen = <int, ParticipantMini>{};
    for (final a in widget.allApparts) {
      final p = a.proprietaire;
      if (p != null) seen.putIfAbsent(p.id, () => p);
    }
    return seen.values.toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  List<String> _extractZones() {
    final seen = <String>{};
    for (final a in widget.allApparts) {
      if (a.communeNom != null && a.communeNom!.isNotEmpty) {
        seen.add(a.communeNom!);
      }
    }
    return seen.toList()..sort();
  }

  int get _resultCount => _draft.apply(widget.allApparts).length;

  void _toggleType(AppartementTypeLocation type) {
    final updated = Set<AppartementTypeLocation>.from(_draft.typeLocations);
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    setState(() => _draft = _draft.copyWith(typeLocations: updated));
  }

  Future<void> _pickPartenaire() async {
    final result = await ListingPartenairePicker.show(
      context,
      partenaires: _availablePartenaires,
      selectedId: _draft.proprietaireId,
    );
    if (!mounted) return;
    // result == null signifie "Tous" — on efface le filtre
    setState(() => _draft = _draft.copyWith(proprietaireId: result));
  }

  Future<void> _pickZone() async {
    final result = await ListingZonePicker.show(
      context,
      zones: _availableZones,
      selected: _draft.communeNom,
    );
    if (!mounted) return;
    setState(() => _draft = _draft.copyWith(communeNom: result));
  }

  String get _partenaireLabel {
    if (_draft.proprietaireId == null) return 'Tous les partenaires';
    final p = _availablePartenaires
        .where((p) => p.id == _draft.proprietaireId)
        .firstOrNull;
    return p?.fullName ?? 'Tous les partenaires';
  }

  String get _zoneLabel => _draft.communeNom ?? 'Toutes les zones';

  @override
  Widget build(BuildContext context) {
    final showTypes = _availableTypes.isNotEmpty;
    final showPartenaires = _availablePartenaires.isNotEmpty;
    final showZones = _availableZones.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Filtres',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
        trailing: _draft.isEmpty
            ? null
            : TextButton(
                onPressed: () =>
                    setState(() => _draft = const ListingFilters()),
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        trailingWidth: 110,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                children: [
                  if (showTypes) ...[
                    Text('PIÈCES', style: AppTextStyles.eyebrow),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableTypes.map((t) {
                        return AsfarChip(
                          label: t.label,
                          active: _draft.typeLocations.contains(t),
                          onTap: () => _toggleType(t),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.line, height: 1),
                    const SizedBox(height: 24),
                  ],
                  if (showPartenaires) ...[
                    Text('PARTENAIRE', style: AppTextStyles.eyebrow),
                    const SizedBox(height: 12),
                    _PickerRow(
                      label: _partenaireLabel,
                      active: _draft.proprietaireId != null,
                      onTap: _pickPartenaire,
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.line, height: 1),
                    const SizedBox(height: 24),
                  ],
                  if (showZones) ...[
                    Text('ZONE', style: AppTextStyles.eyebrow),
                    const SizedBox(height: 12),
                    _PickerRow(
                      label: _zoneLabel,
                      active: _draft.communeNom != null,
                      onTap: _pickZone,
                    ),
                  ],
                  if (!showTypes && !showPartenaires && !showZones)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(
                        child: Text(
                          'Aucun filtre disponible pour ces logements.',
                          style: TextStyle(
                            color: AppColors.text3,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _ApplyButton(
              count: _resultCount,
              onPressed: () => Navigator.of(context).pop(_draft),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PickerRow({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: active ? AppColors.accent : AppColors.line,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: active ? AppColors.accent : AppColors.text,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: active ? AppColors.accent : AppColors.text3,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _ApplyButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              count == 0
                  ? 'Appliquer'
                  : 'Appliquer ($count logement${count > 1 ? 's' : ''})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
