// ignore_for_file: dead_code
// Le bloc `if (false)` (export CSV) est une feature désactivée volontairement,
// conservée comme placeholder pour réactivation future.
import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bottom sheet de choix de format pour l'export Finances.
///
/// 2 options : Aperçu PDF (preview natif + share) ou Export CSV (share
/// direct). L'utilisateur tap une carte → callback déclenché → bottom sheet
/// se ferme.
class ExportBottomSheet extends StatelessWidget {
  final VoidCallback onPdfTap;
  final VoidCallback onCsvTap;

  const ExportBottomSheet({
    super.key,
    required this.onPdfTap,
    required this.onCsvTap,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onPdfTap,
    required VoidCallback onCsvTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: false,
      builder: (ctx) => ExportBottomSheet(
        onPdfTap: () {
          Navigator.of(ctx).pop();
          onPdfTap();
        },
        onCsvTap: () {
          Navigator.of(ctx).pop();
          onCsvTap();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Exporter', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Générez un rapport PDF à partager ou imprimer.',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 16),
            _ExportCard(
              icon: Icons.picture_as_pdf_outlined,
              title: 'Aperçu PDF',
              subtitle: 'Partage + impression natif',
              onTap: onPdfTap,
            ),
            if (false) ...[
              const SizedBox(height: 10),
              _ExportCard(
                icon: Icons.table_chart_outlined,
                title: 'Export CSV',
                subtitle: 'Tableur · idéal pour comptable / Excel',
                onTap: onCsvTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.small),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.text3, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
