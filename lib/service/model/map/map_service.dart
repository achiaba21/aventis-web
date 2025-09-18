import 'dart:math';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/map/map_residence.dart';
import 'package:web_flutter/service/dio/dio_request.dart';
import 'package:web_flutter/util/function.dart';

class MapService {
  final DioRequest _dioRequest = DioRequest.instance;

  Future<List<MapResidence>> getMapResidences({
    required LatLng center,
    double radiusKm = 10.0,
  }) async {
    try {
      final response = await _dioRequest.get(
        "$domain/auth/map/residences",
        queryParameters: {
          'lat': center.latitude,
          'lng': center.longitude,
          'radius': radiusKm,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => MapResidence.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des résidences: ${response.statusCode}');
      }
    } on DioException catch (e) {
      deboger('Erreur MapService.getMapResidences: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      deboger('Erreur MapService.getMapResidences: $e');
      throw Exception('Erreur lors du chargement des résidences');
    }
  }

  Future<List<MapResidence>> getFilteredMapResidences({
    required LatLng center,
    double radiusKm = 10.0,
    FilterCriteria? filter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'lat': center.latitude,
        'lng': center.longitude,
        'radius': radiusKm,
      };

      if (filter != null) {
        if (filter.prixMin != null) queryParams['prixMin'] = filter.prixMin;
        if (filter.prixMax != null) queryParams['prixMax'] = filter.prixMax;
        if (filter.dateDebut != null) queryParams['dateDebut'] = filter.dateDebut!.toIso8601String();
        if (filter.dateFin != null) queryParams['dateFin'] = filter.dateFin!.toIso8601String();
        if (filter.nbLits != null) queryParams['nbLits'] = filter.nbLits;
        if (filter.nbChambres != null) queryParams['nbChambres'] = filter.nbChambres;
        if (filter.nbDouches != null) queryParams['nbDouches'] = filter.nbDouches;
        if (filter.commodites != null && filter.commodites!.isNotEmpty) {
          queryParams['commodites'] = filter.commodites!.join(',');
        }
      }

      final response = await _dioRequest.get(
        "$domain/auth/map/residences/filtered",
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => MapResidence.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des résidences filtrées: ${response.statusCode}');
      }
    } on DioException catch (e) {
      deboger('Erreur MapService.getFilteredMapResidences: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      deboger('Erreur MapService.getFilteredMapResidences: $e');
      throw Exception('Erreur lors du chargement des résidences filtrées');
    }
  }

  Future<List<MapResidence>> getResidencesByIds(List<int> residenceIds) async {
    try {
      final response = await _dioRequest.post(
        "$domain/auth/map/residences/batch",
        data: {'ids': residenceIds},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => MapResidence.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des résidences: ${response.statusCode}');
      }
    } on DioException catch (e) {
      deboger('Erreur MapService.getResidencesByIds: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      deboger('Erreur MapService.getResidencesByIds: $e');
      throw Exception('Erreur lors du chargement des résidences');
    }
  }

  Future<List<MapCluster>> getClusteredResidences({
    required LatLng center,
    double radiusKm = 10.0,
    double clusterRadiusKm = 0.5,
    FilterCriteria? filter,
  }) async {
    final residences = await getFilteredMapResidences(
      center: center,
      radiusKm: radiusKm,
      filter: filter,
    );

    return _performClustering(residences, clusterRadiusKm);
  }

  List<MapCluster> _performClustering(List<MapResidence> residences, double clusterRadiusKm) {
    final List<MapCluster> clusters = [];
    final List<MapResidence> processed = [];

    for (final residence in residences) {
      if (processed.contains(residence) || !residence.hasValidDisplayCoordinates) {
        continue;
      }

      final List<MapResidence> nearbyResidences = [residence];
      processed.add(residence);

      for (final other in residences) {
        if (processed.contains(other) || !other.hasValidDisplayCoordinates) {
          continue;
        }

        final distance = _calculateDistance(
          residence.displayPosition,
          other.displayPosition,
        );

        if (distance <= clusterRadiusKm) {
          nearbyResidences.add(other);
          processed.add(other);
        }
      }

      final clusterCenter = _calculateClusterCenter(nearbyResidences);
      clusters.add(MapCluster(
        residences: nearbyResidences,
        center: clusterCenter,
        radius: clusterRadiusKm,
      ));
    }

    return clusters;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Rayon de la Terre en km
    final double lat1Rad = point1.latitude * (pi / 180);
    final double lat2Rad = point2.latitude * (pi / 180);
    final double deltaLatRad = (point2.latitude - point1.latitude) * (pi / 180);
    final double deltaLngRad = (point2.longitude - point1.longitude) * (pi / 180);

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  LatLng _calculateClusterCenter(List<MapResidence> residences) {
    if (residences.isEmpty) return const LatLng(0, 0);

    double totalLat = 0;
    double totalLng = 0;
    int count = 0;

    for (final residence in residences) {
      if (residence.hasValidDisplayCoordinates) {
        totalLat += residence.displayLat!;
        totalLng += residence.displayLongi!;
        count++;
      }
    }

    if (count == 0) return const LatLng(0, 0);

    return LatLng(totalLat / count, totalLng / count);
  }

  Future<MapResidence?> getResidenceDetails(int residenceId) async {
    try {
      final response = await _dioRequest.get(
        "$domain/auth/map/residences/$residenceId",
      );

      if (response.statusCode == 200) {
        return MapResidence.fromJson(response.data);
      } else {
        throw Exception('Erreur lors du chargement des détails: ${response.statusCode}');
      }
    } on DioException catch (e) {
      deboger('Erreur MapService.getResidenceDetails: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      deboger('Erreur MapService.getResidenceDetails: $e');
      throw Exception('Erreur lors du chargement des détails');
    }
  }

  Future<LatLng?> getRealCoordinates(int residenceId) async {
    try {
      final response = await _dioRequest.get(
        "$domain/auth/map/residences/$residenceId/real-location",
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return LatLng(data['lat'], data['lng']);
      } else {
        return null;
      }
    } catch (e) {
      deboger('Erreur MapService.getRealCoordinates: $e');
      return null;
    }
  }
}