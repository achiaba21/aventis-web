/// Origine d'une demande en attente sur le Dashboard propriétaire.
enum PendingRequestKind {
  /// Demande envoyée par un démarcheur pour un client.
  fromDemarcheur,

  /// Question/demande directe d'un locataire potentiel.
  direct,
}

/// Une demande en attente — `ProprioDashboard::PendingRequestRow`.
///
/// Reproduit le mock du proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 152-154). [isNew] déclenche le badge « NOUVEAU » accent or.
class PendingRequest {
  final String who;
  final String typeLabel;
  final String contextLabel;
  final PendingRequestKind kind;
  final bool isNew;

  const PendingRequest({
    required this.who,
    required this.typeLabel,
    required this.contextLabel,
    required this.kind,
    this.isNew = false,
  });
}
