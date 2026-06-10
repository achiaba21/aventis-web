import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Service API du taux de commission Asfar — endpoint public
/// `GET /auth/config/commission`.
///
/// Source de vérité unique : la valeur peut être modifiée côté admin
/// (cf. brief backend 2026-05-16). Le mobile re-fetch à chaque ouverture
/// du step 5 wizard pour rester en phase.
///
/// La dernière valeur récupérée est **mise en cache** (app settings) pour
/// servir de repli hors-ligne — préférable à une constante codée en dur qui
/// dérive du taux réel configuré par l'admin.
class CommissionService {
  CommissionService._();

  static final CommissionService instance = CommissionService._();

  /// Clé de cache du dernier taux connu (en pourcentage).
  static const String _cacheKey = 'commission_taux_percent';

  static String get _url => '$domain/auth/config/commission';

  /// Récupère le taux de commission en pourcentage (ex. `5.0` pour 5 %).
  /// En cas de succès, met la valeur en cache. Retourne `null` en cas
  /// d'erreur — le caller gère le fallback (cache puis constante).
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
      if (raw is num) {
        final taux = raw.toDouble();
        await _persist(taux);
        return taux;
      }
      return null;
    } catch (e) {
      deboger(['[CommissionService] fetchTaux error: $e']);
      return null;
    }
  }

  /// Dernier taux connu mis en cache (en pourcentage), ou `null` si jamais
  /// récupéré sur cet appareil.
  double? cachedTaux() {
    try {
      return StorageService.instance.getAppSetting<double>(_cacheKey);
    } catch (e) {
      deboger(['[CommissionService] cachedTaux error: $e']);
      return null;
    }
  }

  /// Persiste le dernier taux connu (best-effort, n'échoue jamais le fetch).
  Future<void> _persist(double taux) async {
    try {
      await StorageService.instance.setAppSetting<double>(_cacheKey, taux);
    } catch (e) {
      deboger(['[CommissionService] persist error: $e']);
    }
  }
}
