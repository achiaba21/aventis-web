import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/partenariat/statut_partenariat.dart';
import 'package:asfar/screen/client/shared/partenariats/widget/partenariat_status_badge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Listrow d'une demande de partenariat.
///
/// Affiche : avatar + nom + téléphone + badge statut, timestamp à droite.
/// Boutons « Accepter / Refuser » apparaissent en dessous si la demande
/// est en attente ET les callbacks sont fournis (vue proprio).
class PartenariatRow extends StatelessWidget {
  final DemandePartenariat demande;
  final bool isLast;
  final bool isOwnerView;
  final VoidCallback? onAccept;
  final VoidCallback? onRefuse;

  const PartenariatRow({
    super.key,
    required this.demande,
    this.isLast = false,
    this.isOwnerView = false,
    this.onAccept,
    this.onRefuse,
  });

  String _relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inHours < 1) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours} h';
    if (diff.inDays < 7) return '${diff.inDays} j';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final name =
        isOwnerView ? demande.nomDemarcheur : demande.nomProprietaire;
    final phone =
        isOwnerView ? demande.telephoneDemarcheur : demande.telephoneProprietaire;
    final showActions = isOwnerView &&
        demande.statut == StatutPartenariat.enAttente &&
        (onAccept != null || onRefuse != null);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.line, width: 1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone.isEmpty ? '—' : phone,
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    PartenariatStatusBadge(statut: demande.statut),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _relativeTime(demande.createdAt),
                style: AppTextStyles.small.copyWith(fontSize: 11),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRefuse,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.onAccent,
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Accepter'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
