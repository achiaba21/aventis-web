import 'package:asfar/model/reservation/receipt.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';

/// Service pour gérer les reçus de réservation
class ReceiptService {
  // Singleton
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  static const String _baseUrl = "user/reservations";
  static const String _receiptsUrl = "user/receipts";

  /// Récupère la facture d'une réservation
  Future<Receipt?> getReservationReceipt(String reference) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get('$_baseUrl/$reference/receipt');

      if (response.data is Map<String, dynamic>) {
        final body = response.data['body'];
        if (body is Map<String, dynamic>) {
          final receipt = Receipt.fromJson(body);
          deboger(['✅ Facture récupérée pour $reference: ${receipt.numeroRecu}']);
          return receipt;
        }
      }

      return null;
    } catch (e) {
      deboger(['❌ Erreur récupération facture:', e]);
      rethrow;
    }
  }

  /// Récupère le reçu d'acompte d'une réservation
  Future<Receipt?> getAcompteReceipt(String reference) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get('$_baseUrl/$reference/receipts/ACOMPTE');

      if (response.data is Map<String, dynamic>) {
        final body = response.data['body'];
        if (body is Map<String, dynamic>) {
          final receipt = Receipt.fromJson(body);
          deboger(['✅ Reçu acompte récupéré: ${receipt.numeroRecu}']);
          return receipt;
        }
      }

      return null;
    } catch (e) {
      deboger(['❌ Erreur récupération reçu acompte:', e]);
      rethrow;
    }
  }

  /// Récupère le reçu définitif d'une réservation
  Future<Receipt?> getDefinitifReceipt(String reference) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get('$_baseUrl/$reference/receipts/DEFINITIF');

      if (response.data is Map<String, dynamic>) {
        final body = response.data['body'];
        if (body is Map<String, dynamic>) {
          final receipt = Receipt.fromJson(body);
          deboger(['✅ Reçu définitif récupéré: ${receipt.numeroRecu}']);
          return receipt;
        }
      }

      return null;
    } catch (e) {
      deboger(['❌ Erreur récupération reçu définitif:', e]);
      rethrow;
    }
  }

  /// Récupère un reçu par son numéro
  Future<Receipt?> getReceiptByNumber(String numeroRecu) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get('$_receiptsUrl/$numeroRecu');

      if (response.data is Map<String, dynamic>) {
        final body = response.data['body'];
        if (body is Map<String, dynamic>) {
          final receipt = Receipt.fromJson(body);
          deboger(['✅ Reçu récupéré: ${receipt.numeroRecu}']);
          return receipt;
        }
      }

      return null;
    } catch (e) {
      deboger(['❌ Erreur récupération reçu par numéro:', e]);
      rethrow;
    }
  }

  /// Récupère tous les reçus de l'utilisateur connecté
  Future<List<Receipt>> getAllUserReceipts() async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get(_receiptsUrl);

      if (response.data is Map<String, dynamic>) {
        final body = response.data['body'];
        if (body is List) {
          final receipts = body
              .map((item) => Receipt.fromJson(item as Map<String, dynamic>))
              .toList();
          deboger(['✅ ${receipts.length} reçus utilisateur récupérés']);
          return receipts;
        }
      }

      return [];
    } catch (e) {
      deboger(['❌ Erreur récupération tous les reçus:', e]);
      rethrow;
    }
  }
}
