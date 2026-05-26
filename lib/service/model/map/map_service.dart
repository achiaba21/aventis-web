import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/map/map_filtered_response.dart';
import 'package:asfar/model/map/map_search_result.dart';
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
  /// Réponse : [MapFilteredResponse] qui contient les appartements
  /// (`displayLat/displayLongi` obfusqués ±200m) et le `zoneName` (reverse
  /// geocode backend, R-BACK2). Tolère l'ancien format List pour rétro-compat
  /// avant la livraison backend du wrapper.
  Future<MapFilteredResponse> getFilteredMapAppartements({
    required LatLng center,
    double radiusKm = 10.0,
    FilterCriteria? filter,
  }) async {
    try {
      // R-BACK3 : le rayon est désormais piloté par le backend (config admin,
      // défaut 5 km). Le param `radius` est ignoré côté serveur — on ne
      // l'envoie plus pour la propreté du payload.
      final Map<String, dynamic> queryParams = {
        'lat': center.latitude,
        'lng': center.longitude,
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
        return MapFilteredResponse.fromJson(response.data);
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

  /// Recherche textuelle de lieu (geocoding backend Asfar — R-BACK1).
  ///
  /// Appelle `GET /api/map/search?q={query}` et renvoie un [MapSearchResult]
  /// avec lat/lng + nom de zone reconnaissable. Utilisé par la search bar
  /// de l'`InteractiveMapPicker` pour recentrer la carte sur une zone.
  ///
  /// Throws :
  /// - `Exception("Aucun lieu trouvé pour '$query'")` si 404
  /// - `Exception("Erreur réseau: ...")` autre cas
  Future<MapSearchResult> searchPlace(String query) async {
    try {
      final response = await _dioRequest.get(
        "$domain/api/map/search",
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        return MapSearchResult.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception("Aucun lieu trouvé pour '$query'");
      } else {
        throw Exception(
            'Erreur lors de la recherche: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Aucun lieu trouvé pour '$query'");
      }
      deboger('Erreur MapService.searchPlace: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      deboger('Erreur MapService.searchPlace: $e');
      rethrow;
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
