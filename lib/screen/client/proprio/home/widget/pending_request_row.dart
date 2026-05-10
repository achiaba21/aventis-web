import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pending_request.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Ligne d'une demande en attente — Dashboard propriétaire.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 152-170) : avatar 36×36 (initiales) + nom + badge « NOUVEAU »
/// (accent or) si applicable + type + contexte + chevron.
class PendingRequestRow extends StatelessWidget {
  final PendingRequest request;
  final VoidCallback? onTap;
  final bool isLast;

  const PendingRequestRow({
    super.key,
    required this.request,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.line, width: 1),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: request.who, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            request.who,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (request.isNew) ...[
                          const SizedBox(width: 6),
                          const BadgeStatus(
                            text: 'NOUVEAU',
                            tone: BadgeTone.accent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.typeLabel,
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.contextLabel,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.text3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
