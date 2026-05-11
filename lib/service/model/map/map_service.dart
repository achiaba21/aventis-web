import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

/// Service réseau pour la carte interactive locataire — V9.7b.
///
/// Consomme `/api/map/appartements/filtered` (liste markers obfusqués) et
/// `/api/map/appartements/{id}/real-location` (coordonnées réelles
/// post-réservation). Pas de clustering côté Flutter (MVP V9.7b).
class MapService {
  final DioRequest _dioRequest = DioRequest.instance;

  /// Récupère les appartements à afficher dans une zone, avec filtres
  /// optionnels alignés sur `LocataireSearchScreen`.
  ///
  /// Réponse : `List<MapAppartement>` avec `displayLat/displayLongi` obfusqués
  /// (±200m). Les `realLat/realLongi` sont toujours `null` sur cet endpoint.
  Future<List<MapAppartement>> getFilteredMapAppartements({
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
        if (filter.dateDebut != null) {
          queryParams['dateDebut'] = filter.dateDebut!.toIso8601String();
        }
        if (filter.dateFin != null) {
          queryParams['dateFin'] = filter.dateFin!.toIso8601String();
        }
        if (filter.nbLits != null) queryParams['nbLits'] = filter.nbLits;
        if (filter.nbChambres != null) {
          queryParams['nbChambres'] = filter.nbChambres;
        }
        if (filter.nbDouches != null) {
          queryParams['nbDouches'] = filter.nbDouches;
        }
        if (filter.commodites != null && filter.commodites!.isNotEmpty) {
          queryParams['commodites'] = filter.commodites!.join(',');
        }
      }

      final response = await _dioRequest.get(
        "$domain/api/map/appartements/filtered",
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) =>
                MapAppartement.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Erreur lors du chargement des appartements: ${response.statusCode}');
      }
    } on DioException catch (e) {
      deboger('Erreur MapService.getFilteredMapAppartements: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      deboger('Erreur MapService.getFilteredMapAppartements: $e');
      throw Exception('Erreur lors du chargement des appartements');
    }
  }

  /// Récupère les coordonnées réelles d'un appartement.
  ///
  /// Accessible uniquement si le locataire a une réservation confirmée
  /// (CONFIRMER/PAYER/FINALISER). Sinon le backend renvoie 403 et cette
  /// méthode retourne `null` sans exception (UI affiche la version obfusquée).
  Future<LatLng?> getRealCoordinates(int appartementId) async {
    try {
      final response = await _dioRequest.get(
        "$domain/api/map/appartements/$appartementId/real-location",
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final double? lat = (data['lat'] as num?)?.toDouble();
        final double? lng = (data['lng'] as num?)?.toDouble();
        if (lat == null || lng == null) return null;
        return LatLng(lat, lng);
      }
      return null;
    } catch (e) {
      deboger('Erreur MapService.getRealCoordinates: $e');
      return null;
    }
  }
}
