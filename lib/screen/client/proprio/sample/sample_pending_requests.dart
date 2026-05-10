import 'package:asfar/model/ui_only/pending_request.dart';

/// Données mock des demandes en attente du Dashboard propriétaire.
///
/// Source : proto `proprietaire.jsx::ProprietaireDashboard` (lignes 152-154).
class SamplePendingRequests {
  SamplePendingRequests._();

  static const List<PendingRequest> all = [
    PendingRequest(
      who: 'Diallo M. (démarcheur)',
      typeLabel: 'Réservation pour client',
      contextLabel: 'Loft Plateau · 22-25 nov · 3 nuits',
      kind: PendingRequestKind.fromDemarcheur,
      isNew: true,
    ),
    PendingRequest(
      who: 'Direct: Rachid B.',
      typeLabel: "Question sur l'annonce",
      contextLabel: 'Penthouse Almadies',
      kind: PendingRequestKind.direct,
      isNew: true,
    ),
  ];
}
