import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/model/reservation/receipt.dart';
import 'package:asfar/service/model/booking/receipt_service.dart';
import 'package:asfar/util/function.dart';

/// État des reçus
abstract class ReceiptState {
  const ReceiptState();
}

/// État initial
class ReceiptInitial extends ReceiptState {
  const ReceiptInitial();
}

/// Chargement en cours
class ReceiptLoading extends ReceiptState {
  const ReceiptLoading();
}

/// Reçus chargés avec succès
class ReceiptsLoaded extends ReceiptState {
  final List<Receipt> receipts;
  final String? reservationReference;

  const ReceiptsLoaded({
    required this.receipts,
    this.reservationReference,
  });

  /// Reçu d'acompte
  Receipt? get acompteReceipt => receipts
      .where((r) => r.typeRecu == ReceiptType.acompte)
      .firstOrNull;

  /// Reçu définitif
  Receipt? get definitifReceipt => receipts
      .where((r) => r.typeRecu == ReceiptType.definitif)
      .firstOrNull;

  /// A un reçu d'acompte
  bool get hasAcompte => acompteReceipt != null;

  /// A un reçu définitif
  bool get hasDefinitif => definitifReceipt != null;
}

/// Un seul reçu chargé
class SingleReceiptLoaded extends ReceiptState {
  final Receipt receipt;

  const SingleReceiptLoaded({required this.receipt});
}

/// Erreur de chargement
class ReceiptError extends ReceiptState {
  final String message;

  const ReceiptError({required this.message});
}

/// Cubit pour gérer les reçus de réservation
class ReceiptCubit extends Cubit<ReceiptState> {
  final ReceiptService _receiptService = ReceiptService();

  ReceiptCubit() : super(const ReceiptInitial());

  /// Charger la facture d'une réservation
  Future<void> loadReservationReceipt(String reference) async {
    try {
      emit(const ReceiptLoading());

      final receipt = await _receiptService.getReservationReceipt(reference);

      if (receipt != null) {
        emit(SingleReceiptLoaded(receipt: receipt));
        deboger(['✅ Facture chargée pour $reference: ${receipt.numeroRecu}']);
      } else {
        emit(const ReceiptError(message: 'Facture non trouvée'));
      }
    } catch (e) {
      deboger(['❌ Erreur chargement facture:', e]);
      emit(ReceiptError(message: 'Impossible de charger la facture'));
    }
  }

  /// Charger le reçu d'acompte
  Future<void> loadAcompteReceipt(String reference) async {
    try {
      emit(const ReceiptLoading());

      final receipt = await _receiptService.getAcompteReceipt(reference);

      if (receipt != null) {
        emit(SingleReceiptLoaded(receipt: receipt));
      } else {
        emit(const ReceiptError(message: 'Reçu d\'acompte non trouvé'));
      }
    } catch (e) {
      deboger(['❌ Erreur chargement reçu acompte:', e]);
      emit(ReceiptError(message: 'Impossible de charger le reçu d\'acompte'));
    }
  }

  /// Charger le reçu définitif
  Future<void> loadDefinitifReceipt(String reference) async {
    try {
      emit(const ReceiptLoading());

      final receipt = await _receiptService.getDefinitifReceipt(reference);

      if (receipt != null) {
        emit(SingleReceiptLoaded(receipt: receipt));
      } else {
        emit(const ReceiptError(message: 'Reçu définitif non trouvé'));
      }
    } catch (e) {
      deboger(['❌ Erreur chargement reçu définitif:', e]);
      emit(ReceiptError(message: 'Impossible de charger le reçu définitif'));
    }
  }

  /// Charger un reçu par son numéro
  Future<void> loadReceiptByNumber(String numeroRecu) async {
    try {
      emit(const ReceiptLoading());

      final receipt = await _receiptService.getReceiptByNumber(numeroRecu);

      if (receipt != null) {
        emit(SingleReceiptLoaded(receipt: receipt));
      } else {
        emit(const ReceiptError(message: 'Reçu non trouvé'));
      }
    } catch (e) {
      deboger(['❌ Erreur chargement reçu:', e]);
      emit(ReceiptError(message: 'Impossible de charger le reçu'));
    }
  }

  /// Charger tous les reçus de l'utilisateur
  Future<void> loadAllUserReceipts() async {
    try {
      emit(const ReceiptLoading());

      final receipts = await _receiptService.getAllUserReceipts();

      emit(ReceiptsLoaded(receipts: receipts));

      deboger(['✅ Tous les reçus chargés: ${receipts.length}']);
    } catch (e) {
      deboger(['❌ Erreur chargement tous les reçus:', e]);
      emit(ReceiptError(message: 'Impossible de charger les reçus'));
    }
  }

  /// Réinitialiser l'état
  void reset() {
    emit(const ReceiptInitial());
  }
}
