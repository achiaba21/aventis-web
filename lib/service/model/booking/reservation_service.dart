import 'package:asfar/model/reservation/code_reservation.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/request/reservation_req.dart';
import 'package:asfar/model/request/reservation_manuelle_req.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';

class ReservationService {
  static const api = "api/";
  static const String urlCreateReservation = "${api}user/reservations";
  static const String urlGetUserReservations = "${api}user/reservations";
  static const String urlGetProprietaireReservations =
      "${api}user/reservations/owner";
  static const String urlCreateManualReservation =
      "${api}user/reservations/owner/manual";
  static const String urlCancelReservation = "${api}user/reservations";
  static const String urlConfirmReservation = "${api}user/reservations";

  /// V9.2 — Récupère une réservation par sa référence (ex: `ASF-7K2N9`).
  ///
  /// Utilisé par les cards système du chat (`ReservationMessageCard`) pour
  /// fetch les détails au mount. Route `GET /api/user/reservations/{ref}`.
  Future<Reservation> getByReference(String reference) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get("${api}user/reservations/$reference");
      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null && body.containsKey('id')) {
        return Reservation.fromJson(body);
      }
      throw Exception('Format de réponse invalide pour getByReference');
    } catch (e) {
      deboger('ReservationService.getByReference: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle réservation
  Future<Reservation> createReservation(ReservationReq reservationReq) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.post(
        urlCreateReservation,
        data: reservationReq.toJson(),
      );

      // Parser la réponse selon la structure: {body: {success, message, reservation, reference}, message}
      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        if (body['success'] == true) {
          final reservationData = body['reservation'] as Map<String, dynamic>;
          final reservation = Reservation.fromJson(reservationData);

          deboger(['Réservation créée avec succès:', reservation.toJson()]);
          return reservation;
        }
        final errorMessage =
            body['message'] ?? 'Erreur lors de la création de la réservation';
        throw Exception(errorMessage);
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      deboger(['Erreur création réservation:', e]);
      rethrow;
    }
  }

  /// Récupère les réservations de l'utilisateur
  ///
  /// [page] / [size] (optionnels) : pagination côté serveur. Sans ces
  /// paramètres, l'appel reste strictement identique (liste complète).
  Future<List<Reservation>> getUserReservations({int? page, int? size}) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get(
        urlGetUserReservations,
        queryParameters: (page != null || size != null)
            ? {
                if (page != null) 'page': page,
                if (size != null) 'size': size,
              }
            : null,
      );

      // Le serveur retourne {body: [...], message: "success"}
      // (tolère aussi une liste retournée directement)
      final body = ResponseMapper.tryExtractBodyList(response.data);
      if (body != null) {
        return body
            .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      deboger(['Erreur récupération réservations:', e]);
      rethrow;
    }
  }

  /// Récupère les réservations du propriétaire (réservations reçues sur ses appartements)
  ///
  /// [page] / [size] (optionnels) : pagination côté serveur. Sans ces
  /// paramètres, l'appel reste strictement identique (liste complète).
  Future<List<Reservation>> getProprietaireReservations({
    int? page,
    int? size,
  }) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get(
        urlGetProprietaireReservations,
        queryParameters: (page != null || size != null)
            ? {
                if (page != null) 'page': page,
                if (size != null) 'size': size,
              }
            : null,
      );

      // Le serveur retourne {body: [...], message: "success"}
      // (tolère aussi une liste retournée directement)
      final body = ResponseMapper.tryExtractBodyList(response.data);
      if (body != null) {
        return body
            .map((item) => Reservation.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      deboger(['Erreur récupération réservations propriétaire:', e]);
      rethrow;
    }
  }

  /// Crée une réservation manuelle (propriétaire).
  ///
  /// Permet au propriétaire d'enregistrer une réservation effectuée
  /// en dehors de la plateforme (pas de frais). Depuis le backend
  /// 2026-05-13, la résa est créée directement au statut `FINALISER`
  /// (auparavant `CONFIRMER`).
  Future<Reservation> createManualReservation(
    ReservationManuelleReq req,
  ) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.post(
        urlCreateManualReservation,
        data: req.toJson(),
      );

      // Parser la réponse selon la structure du serveur
      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        // Si body contient directement la réservation
        if (body.containsKey('id')) {
          final reservation = Reservation.fromJson(body);
          deboger(['Réservation manuelle créée:', reservation.toJson()]);
          return reservation;
        }
        // Si body contient un champ reservation
        if (body.containsKey('reservation')) {
          final reservation = Reservation.fromJson(
            body['reservation'] as Map<String, dynamic>,
          );
          deboger(['Réservation manuelle créée:', reservation.toJson()]);
          return reservation;
        }

        // Fallback: body est directement la réservation
        final reservation = Reservation.fromJson(body);
        deboger(['Réservation manuelle créée:', reservation.toJson()]);
        return reservation;
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      deboger(['Erreur création réservation manuelle:', e]);
      rethrow;
    }
  }

  /// Annule une réservation
  Future<void> cancelReservation(String reference, {String? motif}) async {
    try {
      final dio = DioRequest.instance;
      await dio.post(
        "$urlCancelReservation/$reference/cancel",
        data: {if (motif != null) 'motif': motif},
      );

      deboger([
        'Réservation annulée:',
        reference,
        'Motif:',
        motif ?? 'Non spécifié',
      ]);
    } catch (e) {
      deboger(['Erreur annulation réservation:', e]);
      rethrow;
    }
  }

  /// Confirme une réservation (propriétaire)
  Future<void> confirmReservation(String reference) async {
    try {
      final dio = DioRequest.instance;
      await dio.post("$urlConfirmReservation/$reference/confirm");

      deboger(['Réservation confirmée:', reference]);
    } catch (e) {
      deboger(['Erreur confirmation réservation:', e]);
      rethrow;
    }
  }

  /// Refuse une réservation (propriétaire)
  Future<void> refuseReservation(String reference, {String? motif}) async {
    try {
      final dio = DioRequest.instance;
      await dio.post(
        "$urlConfirmReservation/$reference/refuse",
        data: {if (motif != null) 'motif': motif},
      );

      deboger([
        'Réservation refusée:',
        reference,
        'Motif:',
        motif ?? 'Non spécifié',
      ]);
    } catch (e) {
      deboger(['Erreur refus réservation:', e]);
      rethrow;
    }
  }

  /// Effectue le paiement d'une réservation (client/locataire)
  Future<void> payReservation(String reference) async {
    try {
      final dio = DioRequest.instance;
      await dio.post("$urlCreateReservation/$reference/pay");

      deboger(['Paiement effectué pour la réservation:', reference]);
    } catch (e) {
      deboger(['Erreur paiement réservation:', e]);
      rethrow;
    }
  }

  /// Récupère le code de réservation (QR Code) pour une réservation
  Future<CodeReservation> getReservationCode(String reference) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get("$urlCreateReservation/$reference/code");

      // Parser la réponse selon la structure du serveur
      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        final codeReservation = CodeReservation.fromJson(body);
        // SEC-04 : le code secret de réservation ne doit jamais être loggé
        deboger(['Code de réservation récupéré']);
        return codeReservation;
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      deboger(['Erreur récupération code réservation:', e]);
      rethrow;
    }
  }

  /// Met à jour une réservation manuelle (propriétaire).
  ///
  /// Endpoint backend attendu : `PUT /api/user/reservations/owner/manual/{ref}`.
  /// Restriction backend : autorisé uniquement si statut ∈ {EN_ATTENTE, CONFIRMER}.
  /// Voir `BACKEND_NOTES_RESERVATION_DETAIL.md`.
  Future<Reservation> updateManualReservation(
    String reference,
    ReservationManuelleReq req,
  ) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.put(
        "${api}user/reservations/owner/manual/$reference",
        data: req.toJson(),
      );

      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        if (body.containsKey('id')) {
          return Reservation.fromJson(body);
        }
        if (body['reservation'] is Map<String, dynamic>) {
          return Reservation.fromJson(
            body['reservation'] as Map<String, dynamic>,
          );
        }
      }

      throw Exception('Format de réponse invalide');
    } catch (e) {
      deboger(['Erreur mise à jour réservation manuelle:', e]);
      rethrow;
    }
  }

  /// Finalise une réservation après scan du QR code (propriétaire)
  /// Le secretKey est scanné depuis le QR code du locataire
  Future<void> finalizeReservation(String secretKey) async {
    try {
      final dio = DioRequest.instance;
      // TODO: Endpoint à définir - sera fourni plus tard
      // Exemple supposé: POST /user/reservations/finalize avec {secretKey: "..."}
      await dio.post(
        "$urlCreateReservation/finalize",
        data: {'secretKey': secretKey},
      );

      // SEC-04 : le code secret de réservation ne doit jamais être loggé
      deboger(['Réservation finalisée']);
    } catch (e) {
      deboger(['Erreur finalisation réservation:', e]);
      rethrow;
    }
  }
}
