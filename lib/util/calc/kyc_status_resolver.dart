import 'package:asfar/model/document/document_status.dart';
import 'package:asfar/model/document/identity_document.dart';

/// Statut global KYC de l'utilisateur, dérivé de sa liste de documents.
enum KycGlobalStatus {
  /// Aucun document envoyé.
  none,

  /// Des documents existent mais aucun n'est encore vérifié.
  pending,

  /// Au moins un document est vérifié → utilisateur vérifié.
  verified,
}

/// Calcul pur (testable, sans dépendance Flutter) du statut KYC.
///
/// Il n'existe pas d'endpoint « suis-je vérifié » côté backend : on déduit le
/// statut de la liste retournée par `/api/user/documents`.
class KycStatusResolver {
  KycStatusResolver._();

  /// `true` dès qu'au moins un document est au statut `VERIFIER`.
  static bool isVerified(List<IdentityDocument> documents) =>
      documents.any((d) => d.status == DocumentStatus.verifier);

  /// Statut global : vérifié si un document l'est, sinon en attente s'il y a
  /// au moins un document, sinon aucun.
  static KycGlobalStatus resolve(List<IdentityDocument> documents) {
    if (isVerified(documents)) return KycGlobalStatus.verified;
    if (documents.isNotEmpty) return KycGlobalStatus.pending;
    return KycGlobalStatus.none;
  }
}
