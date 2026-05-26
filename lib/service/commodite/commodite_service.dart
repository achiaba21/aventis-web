import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

/// Service API du référentiel commodités — endpoint public `GET /auth/commodites`.
///
/// Aligné sur le backend post-2026-05-16 qui expose la table de référence des
/// commodités (18 entries seedées). Cf. brief mobile « Refonte commodités ».
///
/// Le mapping `value → IconData` reste côté Flutter (`Commodite.getIcon()`).
class CommoditeService {
  CommoditeService._();

  static final CommoditeService instance = CommoditeService._();

  static String get _url => '$domain/auth/commodites';

  /// Récupère la liste complète des commodités du référentiel backend.
  ///
  /// Retourne `[]` en cas d'erreur (silencieux — le caller gère le fallback).
  Future<List<Commodite>> fetchAll() async {
    try {
      final dio = DioRequest.instance;
      final resp = await dio.get(_url);
      final data = resp.data;
      final List rawList = data is List
          ? data
          : (data is Map && data['body'] is List)
              ? data['body'] as List
              : const [];
      return rawList
          .whereType<Map>()
          .map((m) => Commodite.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      deboger(['[CommoditeService] fetchAll error: $e']);
      return const [];
    }
  }
}
