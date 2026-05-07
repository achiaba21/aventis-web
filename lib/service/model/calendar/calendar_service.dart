import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/response/server_response.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// Service API pour les calendriers enrichis (plages OCCUPE / EN_ATTENTE)
class CalendarService {
  final DioRequest _dio = DioRequest.instance;

  /// Calendrier d'un appartement partenaire vu par le démarcheur
  ///
  /// GET demarcheur/appartements/{id}/calendar
  Future<CalendarResponse> getDemarcheurCalendar(
    int appartId, {
    DateTime? debut,
    DateTime? fin,
  }) async {
    try {
      deboger('[CalendarService] getDemarcheurCalendar appartId=$appartId');
      final params = _buildDateParams(debut, fin);
      final response = await _dio.get(
        'api/demarcheur/appartements/$appartId/calendar',
        queryParameters: params,
      );
      final sr = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (b) => CalendarResponse.fromJson(b as Map<String, dynamic>, appartId: appartId),
      );
      return sr.body;
    } catch (e) {
      ErrorHandler.logError('CALENDAR_GET_DEMARCHEUR', e);
      rethrow;
    }
  }

  /// Calendrier d'un appartement vu par le propriétaire
  ///
  /// GET appartements/{id}/calendar
  Future<CalendarResponse> getProprietaireCalendar(
    int appartId, {
    DateTime? debut,
    DateTime? fin,
  }) async {
    try {
      deboger('[CalendarService] getProprietaireCalendar appartId=$appartId');
      final params = _buildDateParams(debut, fin);
      final response = await _dio.get(
        'api/appartements/$appartId/calendar',
        queryParameters: params,
      );
      final sr = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (b) => CalendarResponse.fromJson(b as Map<String, dynamic>, appartId: appartId),
      );
      return sr.body;
    } catch (e) {
      ErrorHandler.logError('CALENDAR_GET_PROPRIETAIRE', e);
      rethrow;
    }
  }

  Map<String, dynamic>? _buildDateParams(DateTime? debut, DateTime? fin) {
    if (debut == null && fin == null) return null;
    final params = <String, dynamic>{};
    if (debut != null) params['debut'] = _toIso(debut);
    if (fin != null) params['fin'] = _toIso(fin);
    return params;
  }

  String _toIso(DateTime date) => date.toIso8601String().substring(0, 19);
}
