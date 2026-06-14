import 'package:asfar/model/reservation/receipt.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/response/response_mapper.dart';

/// Service pour gérer les reçus de réservation
class ReceiptService {
  // Singleton
  static final ReceiptService _instance = ReceiptService._internal();
  factory ReceiptService() => _instance;
  ReceiptService._internal();

  static const String _baseUrl = "api/user/reservations";
  static const String _receiptsUrl = "api/user/receipts";

  /// Récupère la facture d'une réservation
  Future<Receipt?> getReservationReceipt(String reference) async {
    try {
      final dio = DioRequest.instance;
      final response = await dio.get('$_baseUrl/$reference/receipt');

      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        final receipt = Receipt.fromJson(body);
        deboger(['✅ Facture récupérée pour $reference: ${receipt.numeroRecu}']);
        return receipt;
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

      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        final receipt = Receipt.fromJson(body);
        deboger(['✅ Reçu acompte récupéré: ${receipt.numeroRecu}']);
        return receipt;
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

      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        final receipt = Receipt.fromJson(body);
        deboger(['✅ Reçu définitif récupéré: ${receipt.numeroRecu}']);
        return receipt;
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

      final body = ResponseMapper.tryExtractBody(response.data);
      if (body != null) {
        final receipt = Receipt.fromJson(body);
        deboger(['✅ Reçu récupéré: ${receipt.numeroRecu}']);
        return receipt;
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

      final body = ResponseMapper.tryExtractBodyList(response.data);
      if (body != null) {
        final receipts = body
            .map((item) => Receipt.fromJson(item as Map<String, dynamic>))
            .toList();
        deboger(['✅ ${receipts.length} reçus utilisateur récupérés']);
        return receipts;
      }

      return [];
    } catch (e) {
      deboger(['❌ Erreur récupération tous les reçus:', e]);
      rethrow;
    }
  }
}
