import 'package:flutter/material.dart';
import 'package:asfar/model/document/document_status.dart';
import 'package:asfar/widget/badge/badge_status.dart';

/// Badge de statut d'une pièce KYC — réutilise [BadgeStatus] avec le ton et le
/// libellé dérivés de [DocumentStatus].
class KycDocumentStatusBadge extends StatelessWidget {
  final DocumentStatus status;

  const KycDocumentStatusBadge({super.key, required this.status});

  IconData get _icon {
    switch (status) {
      case DocumentStatus.verifier:
        return Icons.check_circle_outline;
      case DocumentStatus.refuser:
        return Icons.cancel_outlined;
      case DocumentStatus.enAttente:
        return Icons.hourglass_top_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BadgeStatus(
      text: status.label,
      tone: status.tone,
      leadingIcon: _icon,
    );
  }
}
