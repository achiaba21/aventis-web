import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/locolite/lieux/commune.dart';
import 'package:asfar/model/locolite/lieux/ville.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/demarcheur/detail/demarcheur_appart_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/filter_bar.dart';
import 'package:asfar/screen/client/demarcheur/profile/demarcheur_profile_screen.dart';
import 'package:asfar/screen/map/location_picker_map_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/helper/haversine_helper.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/text/text_seed.dart';

class DemarcheurHome extends StatefulWidget {
  const DemarcheurHome({super.key});

  @override
  State<DemarcheurHome> createState() => _DemarcheurHomeState();
}

class _DemarcheurHomeState extends State<DemarcheurHome> {
  final _nbPiecesController = TextEditingController();
  Ville? _selectedVille;
  Commune? _selectedCommune;
  LatLng? _mapCenter;

  @override
  void initState() {
    super.initState();
    context.read<DemarcheurBloc>().add(LoadDemarcheurAppartements());
    _nbPiecesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nbPiecesController.dispose();
    super.dispose();
  }

  List<Appartement> _applyFilters(List<Appartement> all) {
    return all.where((appart) {
      final nbFilter = int.tryParse(_nbPiecesController.text.trim());
      if (nbFilter != null && appart.nbChambres != nbFilter) return false;

      if (_mapCenter != null) {
        final loc = appart.address?.displayLocation;
        if (loc == null) return false;
        if (distanceKm(loc, _mapCenter!) > 5.0) return false;
      } else {
        if (_selectedVille != null) {
          final villeId = appart.address?.commune?.ville?.id;
          if (villeId != _selectedVille!.id) return false;
        }
        if (_selectedCommune != null) {
          final communeId = appart.address?.commune?.id;
          if (communeId != _selectedCommune!.id) return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _openMap() async {
    final result = await pushScreen<LatLng>(
      context,
      LocationPickerMapScreen(initialPosition: _mapCenter),
    );
    if (result != null && mounted) {
      setState(() {
        _mapCenter = result;
        _selectedVille = null;
        _selectedCommune = null;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _nbPiecesController.clear();
      _selectedVille = null;
      _selectedCommune = null;
      _mapCenter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextSeed(
          "Appartements partenaires",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<DemarcheurBloc>().add(LoadDemarcheurAppartements());
            },
            icon: const Icon(Icons.refresh),
            color: AppColors.accent,
            tooltip: "Rafraîchir",
          ),
          IconButton(
            onPressed: () => pushScreen(context, const DemarcheurProfileScreen()),
            icon: const Icon(Icons.person_outline),
            color: AppColors.accent,
            tooltip: "Profil",
          ),
        ],
      ),
      body: BlocBuilder<DemarcheurBloc, DemarcheurState>(
        builder: (context, state) {
          if (state is DemarcheurLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DemarcheurError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context
                  .read<DemarcheurBloc>()
                  .add(LoadDemarcheurAppartements()),
            );
          }

          if (state is DemarcheurAppartementsLoaded) {
            if (state.appartements.isEmpty) return _EmptyView();
            final filtered = _applyFilters(state.appartements);

            final villes = state.appartements
                .map((a) => a.address?.commune?.ville)
                .whereType<Ville>()
                .fold<Map<int, Ville>>({}, (map, v) {
                  if (v.id != null) map[v.id!] = v;
                  return map;
                })
                .values
                .toList()
              ..sort((a, b) => (a.nom ?? '').compareTo(b.nom ?? ''));

            final communes = state.appartements
                .where((a) =>
                    _selectedVille == null ||
                    a.address?.commune?.ville?.id == _selectedVille!.id)
                .map((a) => a.address?.commune)
                .whereType<Commune>()
                .fold<Map<int, Commune>>({}, (map, c) {
                  if (c.id != null) map[c.id!] = c;
                  return map;
                })
                .values
                .toList()
              ..sort((a, b) => (a.nom ?? '').compareTo(b.nom ?? ''));

            return Column(
              children: [
                FilterBar(
                  nbPiecesController: _nbPiecesController,
                  villes: villes,
                  communes: communes,
                  selectedVille: _selectedVille,
                  selectedCommune: _selectedCommune,
                  onVilleChanged: (v) => setState(() {
                    _selectedVille = v;
                    _selectedCommune = null;
                    _mapCenter = null;
                  }),
                  onCommuneChanged: (c) => setState(() {
                    _selectedCommune = c;
                    _mapCenter = null;
                  }),
                  mapCenter: _mapCenter,
                  onPickLocation: _openMap,
                  onClearLocation: () => setState(() => _mapCenter = null),
                  onReset: _resetFilters,
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyFilterView()
                      : _AppartementsList(
                          appartements: filtered,
                          onTap: (appart) => pushScreen(
                            context,
                            DemarcheurAppartDetailScreen(appartement: appart),
                          ),
                        ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _AppartementsList extends StatelessWidget {
  final List<Appartement> appartements;
  final void Function(Appartement) onTap;

  const _AppartementsList({
    required this.appartements,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      itemCount: appartements.length,
      separatorBuilder: (_, __) => SizedBox(height: Espacement.gapSection),
      itemBuilder: (context, index) {
        return _AppartementCard(
          appartement: appartements[index],
          onTap: onTap,
        );
      },
    );
  }
}

class _AppartementCard extends StatelessWidget {
  final Appartement appartement;
  final void Function(Appartement) onTap;

  const _AppartementCard({
    required this.appartement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(appartement),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _AppartThumbnail(appartement: appartement),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSeed(
                    appartement.titre ??
                        appartement.numero ??
                        "Appartement ${appartement.id}",
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  if (appartement.prix != null) ...[
                    const SizedBox(height: 4),
                    TextSeed(
                      "${appartement.prix!.toStringAsFixed(0)} FCFA / nuit",
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.accent,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            TextSeed(
              message,
              fontSize: 14,
              color: AppColors.textMuted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apartment, size: 64, color: AppColors.inactive),
            const SizedBox(height: 16),
            TextSeed(
              "Aucun appartement partenaire disponible",
              fontSize: 16,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextSeed(
              "Contactez un propriétaire pour être associé à ses appartements.",
              fontSize: 13,
              color: AppColors.textMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.inactive),
            const SizedBox(height: 16),
            TextSeed(
              "Aucun appartement ne correspond aux filtres",
              fontSize: 15,
              textAlign: TextAlign.center,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppartThumbnail extends StatelessWidget {
  final Appartement appartement;

  const _AppartThumbnail({required this.appartement});

  String? get _photoPath {
    final photos = appartement.photos;
    if (photos != null && photos.isNotEmpty) return photos.first.path;
    return appartement.imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    final path = _photoPath;
    if (path != null && path.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ImageNet(path, size: 48, radius: 10),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.door_front_door_outlined,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }
}
