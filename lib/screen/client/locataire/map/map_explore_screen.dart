import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/bloc/map_bloc/map_bloc.dart';
import 'package:web_flutter/bloc/map_bloc/map_event.dart';
import 'package:web_flutter/bloc/map_bloc/map_state.dart';
import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/map/map_residence.dart';
import 'package:web_flutter/screen/client/locataire/home/owner_appartements_screen.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/util/dialog/open_dialog.dart';
import 'package:web_flutter/widget/bottom_dialogue/filter_option.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/loader/circular_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class MapExploreScreen extends StatefulWidget {
  static const String routeName = "/map-explore";

  const MapExploreScreen({super.key});

  @override
  State<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends State<MapExploreScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isClusterMode = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() => _isLoadingLocation = false);

      if (mounted) {
        final center = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        context.read<MapBloc>().add(LoadMapResidences(center: center));
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      // Utiliser une position par défaut (Abidjan)
      if (mounted) {
        final defaultCenter = const LatLng(5.3478, -4.0267);
        context.read<MapBloc>().add(LoadMapResidences(center: defaultCenter));
      }
    }
  }

  void _onMapMoved(MapCamera position, bool hasGesture) {
    if (hasGesture && mounted) {
      final center = position.center;
      context.read<MapBloc>().add(UpdateMapCenter(center));
    }
  }

  void _onResidenceMarkerTapped(MapResidence residence) {
    context.read<MapBloc>().add(SelectMapResidence(residence.id!));
  }

  void _onClusterMarkerTapped(MapCluster cluster) {
    // Zoomer sur le cluster ou afficher la liste des résidences
    if (cluster.residences.length == 1) {
      _onResidenceMarkerTapped(cluster.residences.first);
    } else {
      _showClusterDialog(cluster);
    }
  }

  void _showClusterDialog(MapCluster cluster) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${cluster.residences.length} résidences'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: cluster.residences.length,
            itemBuilder: (context, index) {
              final residence = cluster.residences[index];
              return ListTile(
                title: Text(residence.nom ?? 'Résidence'),
                subtitle: Text(residence.apartmentCountText),
                trailing: Text(residence.formattedPriceRange),
                onTap: () {
                  Navigator.of(context).pop();
                  _onResidenceMarkerTapped(residence);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showResidenceDetails(MapResidence residence) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      residence.nom ?? 'Résidence',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      residence.addressDescription ?? 'Adresse non disponible',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Appartements',
                            residence.apartmentCountText,
                            Icons.home,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildInfoCard(
                            'Prix',
                            residence.formattedPriceRange,
                            Icons.monetization_on,
                          ),
                        ),
                      ],
                    ),
                    if (residence.communeName != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        'Commune',
                        residence.communeName!,
                        Icons.location_city,
                      ),
                    ],
                    const SizedBox(height: 24),
                    PlainButton(
                      value: 'Voir les appartements',
                      onPress: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          OwnerAppartementsScreen.routeName,
                          arguments: {
                            'ownerId': residence.proprietaire?.id,
                            'ownerName': residence.proprietaire?.nom ?? 'Propriétaire',
                            'residenceId': residence.id,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildResidenceMarkers(List<MapResidence> residences) {
    return residences.map((residence) {
      if (!residence.hasValidDisplayCoordinates) return null;

      return Marker(
        point: residence.displayPosition,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _onResidenceMarkerTapped(residence),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${residence.appartementCount ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).where((marker) => marker != null).cast<Marker>().toList();
  }

  List<Marker> _buildClusterMarkers(List<MapCluster> clusters) {
    return clusters.map((cluster) {
      return Marker(
        point: cluster.center,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _onClusterMarkerTapped(cluster),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${cluster.totalApartments}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des résidences'),
        actions: [
          IconButton(
            icon: Icon(_isClusterMode ? Icons.scatter_plot : Icons.grain),
            onPressed: () {
              setState(() => _isClusterMode = !_isClusterMode);
              context.read<MapBloc>().add(ToggleClusterMode(_isClusterMode));
            },
            tooltip: _isClusterMode ? 'Mode normal' : 'Mode cluster',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Consumer<AppData>(
                  builder: (context, appData, child) {
                    return FilterOption(
                      onApplyFilter: (filter) {
                        context.read<MapBloc>().add(UpdateMapFilter(filter));
                      },
                      initialCriteria: context.read<MapBloc>().currentFilter,
                    );
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MapBloc>().add(const RefreshMapData());
            },
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        listener: (context, state) {
          if (state is MapResidenceSelected) {
            _showResidenceDetails(state.selectedResidence);
          } else if (state is MapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: state.canRetry
                    ? SnackBarAction(
                        label: 'Réessayer',
                        onPressed: () {
                          context.read<MapBloc>().add(const RefreshMapData());
                        },
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_isLoadingLocation) {
            return const Center(child: CircularProgress());
          }

          if (state is MapInitial || state is MapLoading) {
            return const Center(child: CircularProgress());
          }

          if (state is MapEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  TextSeed(state.message),
                  const SizedBox(height: 16),
                  PlainButton(
                    value: 'Réessayer',
                    onPress: () {
                      context.read<MapBloc>().add(const RefreshMapData());
                    },
                  ),
                ],
              ),
            );
          }

          final center = _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : const LatLng(5.3478, -4.0267);

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13.0,
              onPositionChanged: _onMapMoved,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.asfar.web_flutter',
              ),
              MarkerLayer(
                markers: [
                  // Marqueur de position actuelle
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 30,
                      height: 30,
                      child: const CircleIcon(
                        image: Icons.my_location,
                        color: Colors.blue,
                      ),
                    ),
                  // Marqueurs des résidences ou clusters
                  if (state is MapResidencesLoaded)
                    ..._buildResidenceMarkers(state.residences),
                  if (state is MapClustersLoaded)
                    ..._buildClusterMarkers(state.clusters),
                  if (state is MapResidenceSelected) ...[
                    if (state.isClusterMode && state.clusters != null)
                      ..._buildClusterMarkers(state.clusters!)
                    else if (state.allResidences != null)
                      ..._buildResidenceMarkers(state.allResidences!),
                  ],
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_currentPosition != null) {
            _mapController.move(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              15.0,
            );
          } else {
            await _getCurrentLocation();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}