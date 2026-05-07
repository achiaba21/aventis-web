import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/screen/client/locataire/home/owner_appartements_screen.dart';
import 'package:asfar/service/proprietaire/proprietaire_service.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget affichant les informations du propriétaire
/// Charge les infos à la demande depuis le serveur si pas en cache
/// Masque complètement la zone si l'utilisateur n'a pas accès (pas de réservation payée)
class AppartProprioInfo extends StatefulWidget {
  const AppartProprioInfo(
    this.appart, {
    super.key,
  });

  final Appartement appart;

  @override
  State<AppartProprioInfo> createState() => _AppartProprioInfoState();
}

class _AppartProprioInfoState extends State<AppartProprioInfo> {
  final ProprietaireService _service = ProprietaireService();

  Proprietaire? _proprietaire;
  bool _isLoading = true;
  bool _hasAccess = true;

  @override
  void initState() {
    super.initState();
    _loadProprietaire();
  }

  Future<void> _loadProprietaire() async {
    // Note : depuis la refonte du modèle plat, le proprio n'est plus
    // accessible directement via l'appartement. On charge systématiquement
    // depuis le service (cache ou API).
    if (widget.appart.id == null) {
      setState(() {
        _isLoading = false;
        _hasAccess = false;
      });
      return;
    }

    final proprio = await _service.getProprietaire(widget.appart.id!);

    if (mounted) {
      setState(() {
        _proprietaire = proprio;
        _isLoading = false;
        _hasAccess = proprio != null && proprio.hasSensitiveInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading - afficher skeleton
    if (_isLoading) {
      return _buildSkeleton();
    }

    // Pas d'accès (403 ou erreur) → masquer complètement
    if (!_hasAccess || _proprietaire == null) {
      return const SizedBox.shrink();
    }

    // Afficher les infos du propriétaire
    return _buildOwnerInfo(context, _proprietaire!);
  }

  Widget _buildSkeleton() {
    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.background,
        border: Border.all(
          color: AppColors.background,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar skeleton
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
          ),
          Gap(Espacement.gapSection),
          // Text skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Gap(8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo(BuildContext context, Proprietaire proprio) {
    final img = proprio.imgUrl;
    final nbComment = widget.appart.commentaires?.length ?? 0;
    final nomProprietaire = proprio.fullName.isNotEmpty
        ? proprio.fullName
        : "Propriétaire";
    final telephone = proprio.hasPhoneInfo ? proprio.telephone : null;

    return GestureDetector(
      onTap: () {
        final proprietaireId = proprio.id;
        if (proprietaireId != null) {
          pushScreen(
            context,
            OwnerAppartementsScreen(proprietaireId, nomProprietaire),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.background,
          border: Border.all(
            color: AppColors.background,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar avec style amélioré
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.accent.withOpacity(0.1),
                child: img == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.accent,
                      )
                    : ClipOval(
                        child: Image.asset(
                          img,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 32,
                              color: AppColors.accent,
                            );
                          },
                        ),
                      ),
              ),
            ),

            Gap(Espacement.gapSection),

            // Informations propriétaire
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextSeed(
                          nomProprietaire,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      Gap(6),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.accent.withOpacity(0.6),
                      ),
                    ],
                  ),
                  Gap(Espacement.gapItem / 2),

                  // Nombre de commentaires avec icône
                  Row(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      Gap(4),
                      TextSeed(
                        "$nbComment avis",
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ],
                  ),

                  // Téléphone si disponible
                  if (telephone != null) ...[
                    Gap(Espacement.gapItem / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        Gap(4),
                        TextSeed(
                          telephone,
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Indicateur visuel "voir plus"
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
