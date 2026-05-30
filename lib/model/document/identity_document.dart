import 'package:asfar/model/document/document_status.dart';

/// Pièce d'identité (KYC) envoyée par un propriétaire ou un démarcheur.
///
/// Nommé `IdentityDocument` pour éviter la collision avec le `Document`
/// existant (`lib/model/document/document.dart`, autre domaine). Mappé sur
/// l'enveloppe backend `/api/user/documents` (champ `etats` → [status]).
class IdentityDocument {
  final String uuid;
  final String titre;
  final String type;
  final String path;
  final DocumentStatus status;
  final DateTime? createdAt;

  /// Motif de refus, présent uniquement quand [status] vaut
  /// [DocumentStatus.refuser].
  final String? motifRefus;

  const IdentityDocument({
    required this.uuid,
    required this.titre,
    required this.type,
    required this.path,
    required this.status,
    this.createdAt,
    this.motifRefus,
  });

  factory IdentityDocument.fromJson(Map<String, dynamic> json) {
    return IdentityDocument(
      uuid: json['uuid']?.toString() ?? '',
      titre: json['titre']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      path: json['path']?.toString() ?? '',
      status: DocumentStatusX.fromBackend(json['etats']?.toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      motifRefus: (json['motif'] ?? json['motifRefus'])?.toString(),
    );
  }

  /// URL absolue du fichier servi en statique (`${domain}/${path}`).
  String fileUrl(String domain) => '$domain/$path';

  /// `true` si le fichier est une image (vs PDF).
  bool get isImage => type.toUpperCase() == 'IMAGE';
}
