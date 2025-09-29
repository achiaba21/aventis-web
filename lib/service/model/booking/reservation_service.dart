import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/service/dio/dio_request.dart';
import 'package:web_flutter/util/function.dart';

class ReservationService {
  static const String urlCreateReservation = "reservations";
  static const String urlGetUserReservations = "reservations/user";
  static const String urlCancelReservation = "reservations/cancel";

  /// Crée une nouvelle réservation
  Future<Reservation> createReservation(ReservationReq reservationReq) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.post(
        urlCreateReservation,
        data: reservationReq.toJson(),
      );

      // Parser la réponse selon la structure: {body: {success, message, reservation, reference}, message}
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final body = responseData['body'] as Map<String, dynamic>?;

        if (body != null && body['success'] == true) {
          final reservationData = body['reservation'] as Map<String, dynamic>;
          final reservation = Reservation.fromJson(reservationData);

          deboger(['Réservation créée avec succès:', reservation.toJson()]);
          return reservation;
        } else {
          final errorMessage = body?['message'] ?? 'Erreur lors de la création de la réservation';
          throw Exception(errorMessage);
        }
      }

      throw Exception('Format de réponse invalide');

    } catch (e) {
      deboger(['Erreur création réservation:', e]);
      rethrow;
    }
  }

  /// Récupère les réservations de l'utilisateur
  Future<List<Reservation>> getUserReservations() async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get(urlGetUserReservations);

      if (response.data is List) {
        return (response.data as List)
            .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      deboger(['Erreur récupération réservations:', e]);
      rethrow;
    }
  }

  /// Annule une réservation
  Future<void> cancelReservation(int reservationId) async {
    try {
      final dio = DioRequest.instance;
      await dio.put("$urlCancelReservation/$reservationId");

      deboger(['Réservation annulée:', reservationId]);
    } catch (e) {
      deboger(['Erreur annulation réservation:', e]);
      rethrow;
    }
  }
}