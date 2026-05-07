import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/model/geocoding/geocoding_result.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/util/function.dart';

/// Service de géocodage utilisant l'API Nominatim (OpenStreetMap).
///
/// Permet de convertir des adresses textuelles en coordonnées GPS
/// et vice-versa. Implémente le rate limiting requis par Nominatim (1 req/sec).
class GeocodingService {
  static GeocodingService? _instance;
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  late final Dio _dio;
  DateTime? _lastRequestTime;

  static GeocodingService get instance {
    _instance ??= GeocodingService._internal();
    return _instance!;
  }

  GeocodingService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _nominatimBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'User-Agent': 'AsfarApp/1.0',
        'Accept': 'application/json',
      },
    ));
  }

  /// Respecte le rate limiting de Nominatim (1 req/sec)
  Future<void> _respectRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Exécute une requête API avec gestion d'erreurs centralisée
  Future<T?> _executeRequest<T>(
    String methodName,
    Future<T?> Function() request,
  ) async {
    try {
      await _respectRateLimit();
      return await request();
    } on DioException catch (e) {
      deboger('GeocodingService.$methodName error: ${e.message}');
      return null;
    } catch (e) {
      deboger('GeocodingService.$methodName error: $e');
      return null;
    }
  }

  /// Géocode une requête textuelle
  /// Retourne le premier résultat ou null si aucun résultat
  Future<GeocodingResult?> geocode(String query) async {
    if (query.trim().isEmpty) return null;

    return _executeRequest('geocode', () async {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 1,
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> results = response.data;
        if (results.isNotEmpty) {
          return GeocodingResult.fromJson(results.first);
        }
      }
      return null;
    });
  }

  /// Géocode une Address à partir de son nom + commune
  /// Retourne les coordonnées ou null si échec
  Future<LatLng?> geocodeAddress(Address address) async {
    final query = _buildQueryFromAddress(address);
    if (query == null) return null;

    final result = await geocode(query);
    return result?.latLng;
  }

  /// Construit la requête de recherche à partir d'une Address
  String? _buildQueryFromAddress(Address address) {
    final parts = <String>[];

    if (address.nom != null && address.nom!.isNotEmpty) {
      parts.add(address.nom!);
    }

    if (address.commune?.nom != null) {
      parts.add(address.commune!.nom!);
    }

    if (address.commune?.ville?.nom != null) {
      parts.add(address.commune!.ville!.nom!);
    }

    if (address.commune?.ville?.region?.pays?.nom != null) {
      parts.add(address.commune!.ville!.region!.pays!.nom!);
    }

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  /// Géocodage inverse : coordonnées → adresse textuelle
  Future<String?> reverseGeocode(LatLng coords) async {
    return _executeRequest('reverseGeocode', () async {
      final response = await _dio.get(
        '/reverse',
        queryParameters: {
          'lat': coords.latitude,
          'lon': coords.longitude,
          'format': 'json',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['display_name'] as String?;
      }
      return null;
    });
  }

  /// Recherche avec autocomplétion (retourne plusieurs résultats)
  ///
  /// [countrycodes] : code(s) ISO 3166-1 alpha-2 pour restreindre la recherche
  /// (ex: 'ci' pour Côte d'Ivoire). Null = recherche mondiale.
  Future<List<GeocodingResult>> autocomplete(
    String query, {
    int limit = 5,
    String? countrycodes,
  }) async {
    if (query.trim().isEmpty) return [];

    final result = await _executeRequest<List<GeocodingResult>>('autocomplete', () async {
      final params = <String, dynamic>{
        'q': query,
        'format': 'json',
        'limit': limit,
        'addressdetails': 1,
      };
      if (countrycodes != null) params['countrycodes'] = countrycodes;

      final response = await _dio.get(
        '/search',
        queryParameters: params,
      );

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> results = response.data;
        return results.map((json) => GeocodingResult.fromJson(json)).toList();
      }
      return <GeocodingResult>[];
    });

    return result ?? [];
  }
}
