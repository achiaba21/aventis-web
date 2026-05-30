import 'package:asfar/model/document/identity_document.dart';
import 'package:asfar/util/calc/kyc_status_resolver.dart';

/// État de base du KYC. Conserve toujours la dernière liste connue de
/// documents pour éviter les flashs UI pendant les transitions.
abstract class DocumentState {
  final List<IdentityDocument> documents;

  const DocumentState({this.documents = const []});

  /// `true` si au moins un document est vérifié.
  bool get isVerified => KycStatusResolver.isVerified(documents);

  /// Statut global dérivé (aucun / en attente / vérifié).
  KycGlobalStatus get globalStatus => KycStatusResolver.resolve(documents);
}

class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

class DocumentLoading extends DocumentState {
  const DocumentLoading({super.documents});
}

class DocumentLoaded extends DocumentState {
  const DocumentLoaded({super.documents});
}

class DocumentUploading extends DocumentState {
  const DocumentUploading({super.documents});
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message, {super.documents});
}
