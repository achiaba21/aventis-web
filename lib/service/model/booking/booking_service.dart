import 'package:web_flutter/model/booking/booking.dart';
import 'package:web_flutter/model/booking/booking_status.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/util/function.dart';

class BookingService {
  // URL temporaire - sera remplacée par l'URL réelle du serveur
  static const String urlCreateBooking = "booking/create";
  static const String urlGetUserBookings = "booking/user";
  static const String urlCancelBooking = "booking/cancel";

  /// Crée un nouveau booking (temporaire - simulation locale)
  Future<Booking> createBooking(ReservationReq reservationReq) async {
    try {
      // Simulation d'appel API - À remplacer par l'appel réel quand le serveur sera prêt
      await Future.delayed(Duration(seconds: 2)); // Simulation délai réseau

      // Calculs temporaires
      final nombreJours = reservationReq.plage?.duration.inDays ?? 0;
      final prixParNuit = reservationReq.appartement?.prix?.toDouble() ?? 0.0;

      // Appliquer les réductions si disponibles
      double prixParNuitCalcule = prixParNuit;
      if (reservationReq.appartement?.remises != null && nombreJours > 0) {
        final condition = reservationReq.appartement!.remises!.matchCondition(nombreJours);
        if (condition?.montant != null) {
          prixParNuitCalcule = condition!.montant!;
        }
      }

      final prixTotal = prixParNuitCalcule * nombreJours;

      // Création du booking temporaire
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
        appartement: reservationReq.appartement,
        plage: reservationReq.plage,
        status: BookingStatus.en_attente, // Statut initial
        moyenPaiement: reservationReq.moyenPaiement,
        prixTotal: prixTotal,
        prixParNuit: prixParNuitCalcule,
        nombreJours: nombreJours,
        createdAt: DateTime.now(),
      );

      deboger(['Booking créé (temporaire):', booking.toJson()]);

      return booking;

      // Quand le serveur sera prêt, remplacer par :
      // final dio = DioRequest.instance;
      // final result = await dio.postMapped<Booking>(
      //   urlCreateBooking,
      //   data: reservationReq.toJson(),
      // );
      // return result.first;

    } catch (e) {
      deboger(['Erreur création booking:', e]);
      rethrow;
    }
  }

  /// Récupère les bookings de l'utilisateur (temporaire - simulation locale)
  Future<List<Booking>> getUserBookings() async {
    try {
      // Simulation d'appel API
      await Future.delayed(Duration(seconds: 1));

      // Retour d'une liste vide temporairement
      // Sera remplacé par l'appel API réel
      return [];

      // Quand le serveur sera prêt :
      // final dio = DioRequest.instance;
      // return await dio.getMapped<Booking>(urlGetUserBookings);

    } catch (e) {
      deboger(['Erreur récupération bookings:', e]);
      rethrow;
    }
  }

  /// Annule un booking (temporaire - simulation locale)
  Future<void> cancelBooking(int bookingId) async {
    try {
      // Simulation d'appel API
      await Future.delayed(Duration(seconds: 1));

      deboger(['Booking annulé (temporaire):', bookingId]);

      // Quand le serveur sera prêt :
      // final dio = DioRequest.instance;
      // await dio.put("$urlCancelBooking/$bookingId");

    } catch (e) {
      deboger(['Erreur annulation booking:', e]);
      rethrow;
    }
  }
}