import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/commission_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_status_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_timeline.dart';
import 'package:asfar/screen/client/locataire/booking/widget/host_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/listing_summary_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Détail d'une référence client — `ReferralDetailScreen`.
///
/// V8.5 P1 : reçoit en plus du `ReferralPreview` la `Reservation` source
/// pour dériver dynamiquement la timeline (createdAt + statut + dates),
/// le client (clientNom + téléphone) et le propriétaire (proprio.fullName).
class ReferralDetailScreen extends StatelessWidget {
  final ReferralPreview referral;
  final Reservation? source;

  const ReferralDetailScreen({
    super.key,
    required this.referral,
    this.source,
  });

  List<TimelineEntry> _buildSteps() {
    final created = source?.createdAt;
    final sentLabel = _relativeLabel(created);
    final acceptedAt = source?.statut == ReservationStatus.confirmee ||
            source?.statut == ReservationStatus.payee ||
            source?.statut == ReservationStatus.finalisee ||
            source?.statut == ReservationStatus.terminee
        ? source?.createdAt
        : null;
    final hostName = source?.proprio?.fullName.trim().isNotEmpty == true
        ? source!.proprio!.fullName
        : 'le propriétaire';

    return [
      TimelineEntry(
        title: 'Demande envoyée',
        subtitle: sentLabel ?? 'À l\'instant',
      ),
      TimelineEntry(
        title: 'Vue par le propriétaire',
        subtitle: source?.statut == ReservationStatus.enAttente
            ? 'En attente'
            : (sentLabel ?? '—'),
      ),
      TimelineEntry(
        title: source?.statut == ReservationStatus.refusee
            ? 'Refusée par $hostName'
            : 'Acceptée par $hostName',
        subtitle: _formatDate(acceptedAt) ?? 'En attente',
      ),
      TimelineEntry(
        title: 'Paiement client',
        subtitle: source?.statut == ReservationStatus.payee ||
                source?.statut == ReservationStatus.finalisee ||
                source?.statut == ReservationStatus.terminee
            ? 'Reçu'
            : 'En attente',
      ),
      TimelineEntry(
        title: 'Commission versée',
        subtitle: source?.statut == ReservationStatus.terminee ||
                source?.statut == ReservationStatus.finalisee
            ? 'Versée'
            : 'À venir',
      ),
    ];
  }

  int _currentStepIndex(ReferralStatus status) {
    switch (status) {
      case ReferralStatus.pending:
        return 0;
      case ReferralStatus.accepted:
        return 2;
      case ReferralStatus.completed:
        return 4;
      case ReferralStatus.refused:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Demande ${referral.id}',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Statut', style: AppTextStyles.h3),
                  const SizedBox(width: 8),
                  BadgeStatus(
                    text: ReferralStatusDisplay.labelOf(referral.status),
                    tone: ReferralStatusDisplay.toneOf(referral.status),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReferralTimeline(
                steps: _buildSteps(),
                currentIndex: _currentStepIndex(referral.status),
              ),
              const SizedBox(height: 22),
              const Text('Logement', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              ListingSummaryCard(listing: referral.listing),
              const SizedBox(height: 22),
              const Text('Client', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              _clientCard(),
              const SizedBox(height: 22),
              const Text('Propriétaire', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              HostCard(
                hostName: _hostName(),
                memberSince: _hostMemberSince(),
                certified: true,
                onContactTap: () {},
              ),
              const SizedBox(height: 22),
              const Text('Commission', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              CommissionCard(
                subtotal: referral.subtotal,
                commission: referral.commission,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hostName() {
    final p = source?.proprio;
    if (p == null) return 'Propriétaire';
    final name = p.fullName.trim();
    return name.isNotEmpty ? name : 'Propriétaire';
  }

  String _hostMemberSince() {
    final created = source?.proprio?.createdAt;
    return created != null ? '${created.year}' : '—';
  }

  Widget _clientCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          UserAvatar(name: referral.clientName, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.clientName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  referral.clientPhone.isEmpty
                      ? 'Téléphone non communiqué'
                      : referral.clientPhone,
                  style: AppTextStyles.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedCustomButton(
            text: 'Appeler',
            onPressed: referral.clientPhone.isEmpty ? null : () {},
            size: ButtonSize.sm,
            leadingIcon: Icons.phone_outlined,
          ),
        ],
      ),
    );
  }

  /// Format "il y a 2 j · 8 nov." / "À l'instant" / "5 min" / etc.
  String? _relativeLabel(DateTime? dt) {
    if (dt == null) return null;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    return _formatDate(dt);
  }

  String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    const months = [
      'janv.', 'févr.', 'mars', 'avril', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
    ];
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} $hh:$mm';
  }
}
