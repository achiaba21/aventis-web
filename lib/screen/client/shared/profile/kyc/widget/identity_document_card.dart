import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/document/document_status.dart';
import 'package:asfar/model/document/identity_document.dart';
import 'package:asfar/screen/client/shared/profile/kyc/widget/kyc_document_status_badge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Carte d'un document KYC : miniature + titre + date + badge de statut, plus
/// le motif de refus le cas échéant.
class IdentityDocumentCard extends StatelessWidget {
  final IdentityDocument document;

  const IdentityDocumentCard({super.key, required this.document});

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isRefused = document.status == DocumentStatus.refuser;
    final motif = document.motifRefus;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DocumentThumbnail(document: document),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      document.titre.isEmpty ? 'Document' : document.titre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (document.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(document.createdAt),
                        style: AppTextStyles.small
                            .copyWith(fontSize: 12, color: AppColors.text3),
                      ),
                    ],
                    const SizedBox(height: 8),
                    KycDocumentStatusBadge(status: document.status),
                  ],
                ),
              ),
            ],
          ),
          if (isRefused && motif != null && motif.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                'Motif : $motif',
                style: AppTextStyles.small
                    .copyWith(fontSize: 12, color: AppColors.danger),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Miniature du fichier (image distante) avec placeholders de chargement et
/// d'erreur. Privée à la carte.
class _DocumentThumbnail extends StatelessWidget {
  final IdentityDocument document;

  const _DocumentThumbnail({required this.document});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgElev3,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      alignment: Alignment.center,
      child: Icon(
        document.isImage ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
        size: 22,
        color: AppColors.text3,
      ),
    );

    if (!document.isImage) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Image.network(
        document.fileUrl(domain),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (context, error, stackTrace) => placeholder,
      ),
    );
  }
}
