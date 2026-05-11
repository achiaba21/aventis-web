import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/commission_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_client_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_status_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_timeline.dart';
import 'package:asfar/screen/client/locataire/booking/widget/host_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/listing_summary_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Détail d'une référence client — `ReferralDetailScreen`.
///
/// Consomme directement le modèle métier [Reservation] (côté démarcheur,
/// création pour client). Timeline + statuts + commission + client + host
/// dérivés depuis la Reservation et son extension `ReferralDisplay`.
class ReferralDetailScreen extends StatelessWidget {
  final Reservation reservation;

  const ReferralDetailScreen({super.key, required this.reservation});

  List<TimelineEntry> _buildSteps() {
    final created = reservation.createdAt;
    final sentLabel = _relativeLabel(created);
    final acceptedAt = reservation.statut == ReservationStatus.confirmee ||
            reservation.statut == ReservationStatus.payee ||
            reservation.statut == ReservationStatus.finalisee ||
            reservation.statut == ReservationStatus.terminee
        ? reservation.createdAt
        : null;
    final hostName = reservation.proprio?.fullName.trim().isNotEmpty == true
        ? reservation.proprio!.fullName
        : 'le propriétaire';

    return [
      TimelineEntry(
        title: 'Demande envoyée',
        subtitle: sentLabel ?? 'À l\'instant',
      ),
      TimelineEntry(
        title: 'Vue par le propriétaire',
        subtitle: reservation.statut == ReservationStatus.enAttente
            ? 'En attente'
            : (sentLabel ?? '—'),
      ),
      TimelineEntry(
        title: reservation.statut == ReservationStatus.refusee
            ? 'Refusée par $hostName'
            : 'Acceptée par $hostName',
        subtitle: _formatDate(acceptedAt) ?? 'En attente',
      ),
      TimelineEntry(
        title: 'Paiement client',
        subtitle: reservation.statut == ReservationStatus.payee ||
                reservation.statut == ReservationStatus.finalisee ||
                reservation.statut == ReservationStatus.terminee
            ? 'Reçu'
            : 'En attente',
      ),
      TimelineEntry(
        title: 'Commission versée',
        subtitle: reservation.statut == ReservationStatus.terminee ||
                reservation.statut == ReservationStatus.finalisee
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

  ListingPreview _listingFromReservation() {
    final appart = reservation.appart;
    if (appart == null) {
      return const ListingPreview(
        id: '0',
        tone: 1,
        title: 'Logement supprimé',
        area: '',
        city: '',
        price: 0,
      );
    }
    return AppartementToListingMapper.mapOne(appart);
  }

  @override
  Widget build(BuildContext context) {
    final status = reservation.referralStatus;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Demande ${reservation.referralIdLabel}',
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
                    text: ReferralStatusDisplay.labelOf(status),
                    tone: ReferralStatusDisplay.toneOf(status),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ReferralTimeline(
                steps: _buildSteps(),
                currentIndex: _currentStepIndex(status),
              ),
              const SizedBox(height: 22),
              const Text('Logement', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              ListingSummaryCard(listing: _listingFromReservation()),
              const SizedBox(height: 22),
              const Text('Client', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              ReferralClientCard(
                name: reservation.referralClientName,
                phone: reservation.referralClientPhone,
                onCall: () {},
              ),
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
                subtotal: reservation.referralSubtotal,
                commission: reservation.referralCommissionAmount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hostName() {
    final p = reservation.proprio;
    if (p == null) return 'Propriétaire';
    final name = p.fullName.trim();
    return name.isNotEmpty ? name : 'Propriétaire';
  }

  String _hostMemberSince() {
    final created = reservation.proprio?.createdAt;
    return created != null ? '${created.year}' : '—';
  }

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
