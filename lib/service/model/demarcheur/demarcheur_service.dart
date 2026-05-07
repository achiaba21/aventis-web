import 'package:asfar/model/request/demarcheur_reservation_req.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/response/server_response.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// Service API pour les opérations du démarcheur
class DemarcheurService {
  final DioRequest _dio = DioRequest.instance;

  static const _urlAppartements = 'api/demarcheur/appartements';
  static const _urlReservations = 'api/demarcheur/reservations';

  /// Récupère la liste des appartements des propriétaires partenaires
  Future<List<Appartement>> getAppartements() async {
    try {
      deboger('[DemarcheurService] getAppartements');
      final response = await _dio.get(_urlAppartements);
      final serverResponse = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (body) =>
            (body as List? ?? [])
                .map((e) => Appartement.fromJson(e as Map<String, dynamic>))
                .toList(),
      );
      return serverResponse.body;
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_GET_APPARTEMENTS', e);
      rethrow;
    }
  }

  /// Récupère les réservations du démarcheur
  Future<List<Reservation>> getReservations() async {
    try {
      deboger('[DemarcheurService] getReservations');
      final response = await _dio.get(_urlReservations);
      final serverResponse = ServerResponse.fromJson(
        response.data as Map<String, dynamic>,
        (body) =>
            (body as List? ?? [])
                .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
                .toList(),
      );
      return serverResponse.body;
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_GET_RESERVATIONS', e);
      rethrow;
    }
  }

  /// Soumet une demande de réservation pour un client prospecté
  Future<Reservation> createReservation(DemarcheurReservationReq req) async {
    try {
      deboger('[DemarcheurService] createReservation appartId=${req.appartId}');
      final response = await _dio.post(_urlReservations, data: req.toJson());
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      // Le backend retourne { success, reference, reservation }
      final reservationJson =
          data['reservation'] as Map<String, dynamic>? ?? data;
      return Reservation.fromJson(reservationJson);
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_CREATE_RESERVATION', e);
      rethrow;
    }
  }
}
