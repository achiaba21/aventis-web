import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/rule.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';

/// Service API du référentiel des règles de maison.
///
/// Endpoint public `GET /auth/rules` (brief backend 2026-05-16). 6 règles
/// seedées (no_smoking, pets_allowed, no_parties, quiet_hours, no_loud_music,
/// child_friendly).
class RuleService {
  RuleService._();

  static final RuleService instance = RuleService._();

  static String get _url => '$domain/api/rules';

  /// Récupère la liste complète du référentiel.
  /// Retourne `[]` en cas d'erreur — le caller gère le fallback.
  Future<List<Rule>> fetchAll() async {
    try {
      final dio = DioRequest.instance;
      final resp = await dio.get(_url);
      final List rawList =
          ResponseMapper.tryExtractBodyList(resp.data) ?? const [];
      return rawList
          .whereType<Map>()
          .map((m) => Rule.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      deboger(['[RuleService] fetchAll error: $e']);
      return const [];
    }
  }
}
