import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/ui_only/accepted_partenariat_card_payload.dart';
import 'package:asfar/screen/client/shared/inbox/widget/system_card_atoms.dart';
import 'package:asfar/service/model/partenariat/partenariat_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/function.dart';

/// Card spéciale « Demande de partenariat acceptée » — V9.2.
///
/// Renommé depuis `AcceptedReferralMessageCard` pour aligner sur le nommage
/// backend (`partenariat` au lieu de `referral`).
///
/// Le payload ne porte que l'id de la demande ; le détail est récupéré lazy
/// via `PartenariatService.getDemandeById(id)`. Affiche le nom de la
/// **partie opposée** (proprio si user démarcheur, démarcheur si user proprio).
class AcceptedPartenariatMessageCard extends StatefulWidget {
  final AcceptedPartenariatCardPayload payload;
  final void Function(DemandePartenariat? loaded)? onTap;

  const AcceptedPartenariatMessageCard({
    super.key,
    required this.payload,
    this.onTap,
  });

  @override
  State<AcceptedPartenariatMessageCard> createState() =>
      _AcceptedPartenariatMessageCardState();
}

class _AcceptedPartenariatMessageCardState
    extends State<AcceptedPartenariatMessageCard> {
  DemandePartenariat? _loaded;
  bool _isLoading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final demande = await PartenariatService().getDemandeById(
        widget.payload.demandeId,
      );
      if (!mounted) return;
      setState(() {
        _loaded = demande;
        _isLoading = false;
      });
    } catch (e) {
      deboger('AcceptedPartenariatMessageCard.load: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _failed = true;
      });
    }
  }

  void _onTap() {
    if (_isLoading) return;
    widget.onTap?.call(_loaded);
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.82;
    final currentUserType =
        context.read<UserBloc>().state.user?.type?.toLowerCase();
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: _onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgElev1,
                borderRadius: BorderRadius.circular(AppRadii.lg),
                border: Border.all(color: AppColors.line, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SystemCardLeadingIcon(
                    icon: Icons.handshake_outlined,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PartenariatCardBody(
                      isLoading: _isLoading,
                      failed: _failed,
                      demande: _loaded,
                      demandeId: widget.payload.demandeId,
                      currentUserType: currentUserType,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PartenariatCardBody extends StatelessWidget {
  final bool isLoading;
  final bool failed;
  final DemandePartenariat? demande;
  final int demandeId;
  final String? currentUserType;

  const _PartenariatCardBody({
    required this.isLoading,
    required this.failed,
    required this.demande,
    required this.demandeId,
    required this.currentUserType,
  });

  /// Calcule le nom à afficher = nom de la partie opposée.
  String _otherPartyName() {
    final d = demande;
    if (d == null) return '';
    // Si l'user courant est démarcheur → afficher nom proprio.
    if (currentUserType == 'demarcheur') {
      final prenom = d.proprietaire['prenom'] as String? ?? '';
      final nom = d.proprietaire['nom'] as String? ?? '';
      final full = '$prenom $nom'.trim();
      return full.isNotEmpty ? full : 'Propriétaire';
    }
    // Si l'user courant est proprio → afficher nom démarcheur.
    return d.nomDemarcheur;
  }

  String _formatRepondueAt() {
    final dt = demande?.repondueAt;
    if (dt == null) return '';
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return 'Accepté le ${dt.day} ${months[dt.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DEMANDE ACCEPTÉE',
          style: AppTextStyles.eyebrow.copyWith(
            fontSize: 9,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 6),
        if (isLoading)
          const SystemCardSkeletonRows(rowWidths: [140, 100])
        else if (failed || demande == null)
          _CardFailedFallback(title: 'Partenariat #$demandeId')
        else
          _CardLoadedPartenariat(
            partyName: _otherPartyName(),
            subtitle: _formatRepondueAt(),
          ),
      ],
    );
  }
}

class _CardLoadedPartenariat extends StatelessWidget {
  final String partyName;
  final String subtitle;

  const _CardLoadedPartenariat({
    required this.partyName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          partyName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.small.copyWith(fontSize: 11),
          ),
        ],
      ],
    );
  }
}

class _CardFailedFallback extends StatelessWidget {
  final String title;

  const _CardFailedFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        const SystemCardUnavailableChip(),
      ],
    );
  }
}
