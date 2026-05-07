import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/config/map_config.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/city_coordinates.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/map/map_style_layer.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Étape 1 du wizard : sélection de l'adresse via une carte plein écran
/// avec un bottom sheet sticky pour l'adresse textuelle.
class Step1Address extends StatefulWidget {
  const Step1Address({super.key});

  @override
  State<Step1Address> createState() => _Step1AddressState();
}

class _Step1AddressState extends State<Step1Address> {
  late final MapController _mapController;
  Timer? _textDebounce;
  Timer? _mapDebounce;
  String? _lastAddressNom;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _textDebounce?.cancel();
    _mapDebounce?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _mapDebounce?.cancel();
    _mapDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<AppartementWizardBloc>().add(
            UpdateField('addressLatLng', camera.center),
          );
    });
  }

  void _onAddressTextChanged(String? value) {
    _textDebounce?.cancel();
    _textDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<AppartementWizardBloc>().add(
            UpdateField('addressNom', value),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppartementWizardBloc, AppartementWizardState>(
      buildWhen: (prev, next) =>
          prev.draft.address?.lat != next.draft.address?.lat ||
          prev.draft.address?.longi != next.draft.address?.longi ||
          prev.draft.address?.nom != next.draft.address?.nom ||
          prev.isLoadingGeo != next.isLoadingGeo,
      builder: (context, state) {
        final address = state.draft.address;
        final initialCenter = (address?.lat != null && address?.longi != null)
            ? LatLng(address!.lat!, address.longi!)
            : CityCoordinates.getCoordinates(null);

        // Synchroniser le contrôleur de map si la position change
        // (ex : après réception du GPS auto-détecté).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (address?.lat != null && address?.longi != null) {
            try {
              _mapController.move(
                LatLng(address!.lat!, address.longi!),
                _mapController.camera.zoom,
              );
            } catch (_) {
              // Map pas encore prête — sera bien centrée à l'init
            }
          }
        });

        // Synchroniser le texte adresse uniquement si la valeur change
        // (sinon le contrôleur InputField perdrait le focus en boucle)
        if (_lastAddressNom != address?.nom) {
          _lastAddressNom = address?.nom;
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: MapConfig.userPositionZoom,
                onPositionChanged: _onMapPositionChanged,
              ),
              children: const [
                MapStyleLayer(isDarkMode: false),
              ],
            ),
            // Pin centré (le marqueur reste fixe, c'est la carte qui bouge)
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppColors.accent,
                    shadows: [
                      Shadow(color: AppColors.shadowStrong, blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ),
            if (state.isLoadingGeo) const _LoadingOverlay(),
            // Bottom sheet sticky avec adresse texte
            Align(
              alignment: Alignment.bottomCenter,
              child: _AddressBottomSheet(
                initialValue: address?.nom,
                onChanged: _onAddressTextChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.overlayLight,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(Espacement.radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
              SizedBox(width: Espacement.gapSection),
              TextSeed("Recherche de votre position...", fontSize: 13),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressBottomSheet extends StatelessWidget {
  const _AddressBottomSheet({
    required this.initialValue,
    required this.onChanged,
  });

  final String? initialValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Espacement.paddingBloc),
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(Espacement.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.place, size: 18, color: AppColors.accent),
              SizedBox(width: Espacement.gapItem),
              TextSeed(
                "Adresse de votre bien",
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: Espacement.gapSection),
          InputField(
            placeHolder: "Cocody, Angré 8e Tranche",
            initialValue: initialValue,
            onChange: (value) {
              onChanged(value);
              return null;
            },
          ),
          SizedBox(height: Espacement.gapItem),
          TextSeed(
            "Faites glisser la carte pour ajuster l'emplacement",
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
