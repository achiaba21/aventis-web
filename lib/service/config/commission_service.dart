import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

/// Service API du taux de commission Asfar — endpoint public
/// `GET /auth/config/commission`.
///
/// Source de vérité unique : la valeur peut être modifiée côté admin
/// (cf. brief backend 2026-05-16). Le mobile re-fetch à chaque ouverture
/// du step 5 wizard pour rester en phase.
class CommissionService {
  CommissionService._();

  static final CommissionService instance = CommissionService._();

  static String get _url => '$domain/auth/config/commission';

  /// Récupère le taux de commission en pourcentage (ex. `5.0` pour 5 %).
  /// Retourne `null` en cas d'erreur — le caller gère le fallback.
  Future<double?> fetchTaux() async {
    try {
      final dio = DioRequest.instance;
      final resp = await dio.get(_url);
      final data = resp.data;
      final Map<String, dynamic>? body = data is Map<String, dynamic>
          ? data
          : (data is Map && data['body'] is Map
              ? Map<String, dynamic>.from(data['body'] as Map)
              : null);
      final raw = body?['taux'];
      if (raw is num) return raw.toDouble();
      return null;
    } catch (e) {
      deboger(['[CommissionService] fetchTaux error: $e']);
      return null;
    }
  }
}
