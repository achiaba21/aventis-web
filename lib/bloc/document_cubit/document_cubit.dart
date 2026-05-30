import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/document_cubit/document_state.dart';
import 'package:asfar/service/model/document/document_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// Cubit du KYC : charge les documents de l'utilisateur, gère l'upload et
/// expose le statut « vérifié » dérivé.
class DocumentCubit extends Cubit<DocumentState> {
  final DocumentService _service = DocumentService();

  DocumentCubit() : super(const DocumentInitial());

  /// Charge (ou recharge) la liste des documents.
  Future<void> load() async {
    emit(DocumentLoading(documents: state.documents));
    try {
      final docs = await _service.getMyDocuments();
      emit(DocumentLoaded(documents: docs));
    } catch (e) {
      deboger(['[DocumentCubit] Erreur load: $e']);
      emit(DocumentError(
        ErrorHandler.extractGenericErrorMessage(e),
        documents: state.documents,
      ));
    }
  }

  /// Envoie une pièce puis recharge la liste pour refléter le nouveau document.
  /// Retourne `true` si l'upload a réussi (permet à l'UI de fermer la feuille).
  Future<bool> upload(File file, String titre) async {
    emit(DocumentUploading(documents: state.documents));
    try {
      await _service.uploadDocument(file: file, titre: titre);
      await load();
      return true;
    } catch (e) {
      deboger(['[DocumentCubit] Erreur upload: $e']);
      emit(DocumentError(
        ErrorHandler.extractGenericErrorMessage(e),
        documents: state.documents,
      ));
      return false;
    }
  }
}
