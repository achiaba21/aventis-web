import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/booking/widget/itinerary_button.dart';
import 'package:asfar/screen/client/locataire/booking/widget/location_label_chip.dart';
import 'package:asfar/screen/client/locataire/booking/widget/mini_map_preview.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/service/model/map/map_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/function.dart';

/// Section "Localisation" du `LocataireDetailScreen` — V9.7c.
///
/// Charge en parallèle deux sources de coordonnées :
/// - `AppartementService.getAppartementById` → `Address.displayLocation`
///   (coords approximatives obfusquées, toujours disponibles).
/// - `MapService.getRealCoordinates` → coords réelles **uniquement** si
///   le locataire a une réservation au statut `PAYER` ou `FINALISER`
///   (sinon 403, retour `null` silencieux).
///
/// Affichage conditionnel :
/// - Loading → skeleton 180px + spinner accent
/// - Réelle dispo → mini-carte centrée + chip "exacte" + bouton Itinéraire
/// - Réelle indispo + approx OK → mini-carte centrée + chip "approximative"
/// - Aucune coord → section masquée (`SizedBox.shrink`)
///
/// Aucun dispatch `MapBloc` : appels directs aux services pour ne pas
/// polluer l'état global utilisé par `LocataireMapScreen` en arrière-plan
/// (cf. décision D1 architecture V9.7c).
class DetailMapSection extends StatefulWidget {
  final int? appartId;
  final String area;
  final String city;
  final double height;

  const DetailMapSection({
    super.key,
    required this.appartId,
    required this.area,
    required this.city,
    this.height = 180,
  });

  @override
  State<DetailMapSection> createState() => _DetailMapSectionState();
}

class _DetailMapSectionState extends State<DetailMapSection> {
  final AppartementService _appartService = AppartementService();
  final MapService _mapService = MapService();

  LatLng? _realLocation;
  LatLng? _approxLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final id = widget.appartId;
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    await Future.wait<void>([
      _loadApproxLocation(id),
      _loadRealLocation(id),
    ]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadApproxLocation(int id) async {
    try {
      final Appartement appart = await _appartService.getAppartementById(id);
      final approx = appart.address?.displayLocation;
      if (!mounted) return;
      setState(() => _approxLocation = approx);
    } catch (e) {
      deboger('DetailMapSection.loadApprox: $e');
    }
  }

  Future<void> _loadRealLocation(int id) async {
    try {
      final real = await _mapService.getRealCoordinates(id);
      if (!mounted) return;
      setState(() => _realLocation = real);
    } catch (e) {
      deboger('DetailMapSection.loadReal: $e');
    }
  }

  void _onItineraryError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Aucune application carte installée'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _DetailMapSkeleton(height: widget.height);
    }

    final LatLng? center = _realLocation ?? _approxLocation;
    if (center == null) {
      // Aucune coordonnée disponible : on masque la section.
      return const SizedBox.shrink();
    }

    final bool isExact = _realLocation != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MiniMapPreview(center: center, height: widget.height),
        const SizedBox(height: 12),
        Row(
          children: [
            LocationLabelChip(isExact: isExact),
            const Spacer(),
            if (isExact)
              ItineraryButton(
                coords: _realLocation!,
                onError: _onItineraryError,
              ),
          ],
        ),
      ],
    );
  }
}

/// Skeleton de chargement (180px bgElev2 + spinner accent 24px).
class _DetailMapSkeleton extends StatelessWidget {
  final double height;

  const _DetailMapSkeleton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      ),
    );
  }
}
