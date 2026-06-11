import 'package:flutter/material.dart';
import 'package:asfar/model/contact/contact.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/commission_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_client_card.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_status_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_timeline.dart';
import 'package:asfar/screen/client/locataire/booking/widget/host_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/listing_summary_card.dart';
import 'package:asfar/service/contact/contact_availability.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/contact_target_resolver.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/contact/contact_sheet.dart';

/// Détail d'une référence client — `ReferralDetailScreen`.
///
/// Consomme directement le modèle métier [Reservation] (côté démarcheur,
/// création pour client). Timeline + statuts + commission + client + host
/// dérivés depuis la Reservation et son extension `ReferralDisplay`.
///
/// Actions de contact branchées sur la couche unifiée
/// (`ContactSheet` + `CallButton`). Côté démarcheur, les actions sont
/// **toujours actives** quel que soit le statut (cf. business-spec §4.3).
class ReferralDetailScreen extends StatelessWidget {
  final Reservation reservation;

  const ReferralDetailScreen({super.key, required this.reservation});

  List<TimelineEntry> _buildSteps() {
    final created = reservation.createdAt;
    final sentLabel = _relativeLabel(created);
    final acceptedAt = reservation.statut == ReservationStatus.confirmee ||
            reservation.statut == ReservationStatus.payee ||
            reservation.statut == ReservationStatus.finalisee
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
        title: reservation.statut == ReservationStatus.annulee
            ? 'Refusée par $hostName'
            : 'Acceptée par $hostName',
        subtitle: _formatDate(acceptedAt) ?? 'En attente',
      ),
      TimelineEntry(
        title: 'Paiement client',
        subtitle: reservation.statut == ReservationStatus.payee ||
                reservation.statut == ReservationStatus.finalisee
            ? 'Reçu'
            : 'En attente',
      ),
      TimelineEntry(
        title: 'Commission versée',
        subtitle: reservation.statut == ReservationStatus.finalisee
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
    final status = reservation.referralStatus;
    _logReservationDetails();
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
              if (reservation.appart != null) ...[
                const Text('Logement', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                ListingSummaryCard(appartement: reservation.appart!),
              ],
              const SizedBox(height: 22),
              if (!reservation.isClientConfidential) ...[
                const Text('Client', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                ReferralClientCard(
                  name: reservation.referralClientName,
                  phone: reservation.referralClientPhone,
                ),
                const SizedBox(height: 22),
              ],
              const Text('Propriétaire', style: AppTextStyles.h3),
              const SizedBox(height: 10),
              HostCard(
                hostName: _hostName(),
                memberSince: _hostMemberSince(),
                certified: true,
                onContactTap: () => _onContactProprio(context),
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

  void _onContactProprio(BuildContext context) {
    deboger('═════════════════════════════════════════');
    deboger('🟡 [ReferralDetailScreen] TAP "Contacter"');
    deboger('   reservation.id        = ${reservation.id}');
    deboger('   reservation.reference = ${reservation.reference}');
    deboger('   reservation.proprio   = ${reservation.proprio}');
    if (reservation.proprio != null) {
      final p = reservation.proprio!;
      // SEC-04 : pas de PII (nom, téléphone, email) dans les logs
      deboger('     ├─ id        = ${p.id}');
      deboger('     ├─ telephone = ${p.telephone != null ? 'présent' : 'absent'}');
      deboger('     └─ email     = ${p.email != null ? 'présent' : 'absent'}');
    } else {
      deboger('     ⚠️ reservation.proprio == null (backend ne l\'envoie pas)');
    }

    final resolvedContact = ContactTargetResolver.fromReservation(
      reservation,
      ReservationViewerRole.demarcheur,
    );
    deboger('   ContactTargetResolver.fromReservation → '
        '${resolvedContact == null ? "null (fallback déclenché)" : "OK"}');

    // Si `reservation.proprio` n'est pas chargé (dépendance backend
    // actuellement absente — cf. note Reservation §47-49), on ouvre quand
    // même la sheet avec un Contact "shell" : les 3 options seront alors
    // grisées et le démarcheur voit clairement qu'aucun canal n'est dispo,
    // au lieu de recevoir un SnackBar disparaissant.
    final contact = resolvedContact ??
        Contact(
          displayName: _hostName(),
          roleLabel: 'Propriétaire',
        );
    deboger('   contact final :');
    deboger('     ├─ telephone   = ${contact.telephone != null ? 'présent' : 'absent'}');
    deboger('     ├─ userId      = ${contact.userId}');
    deboger('     ├─ hasPhone    = ${contact.hasPhone}');
    deboger('     ├─ hasWhatsApp = ${contact.hasWhatsApp}');
    deboger('     └─ canChat     = ${contact.canChat}');

    // Démarcheur → toujours actif, statut ignoré.
    final availability = ContactAvailability.from(
      contact: contact,
      isTerminalStatus: false,
      isDemarcheurViewer: true,
    );
    deboger('   availability :');
    deboger('     ├─ callEnabled         = ${availability.callEnabled}');
    deboger('     ├─ whatsAppEnabled     = ${availability.whatsAppEnabled}');
    deboger('     ├─ chatEnabled         = ${availability.chatEnabled}');
    deboger('     └─ contactButtonEnabled= ${availability.contactButtonEnabled}');
    deboger('   → Ouverture ContactSheet.show()');
    deboger('═════════════════════════════════════════');

    ContactSheet.show(
      context,
      contact: contact,
      availability: availability,
    );
  }

  /// Log de diagnostic au build du screen — affiche tout ce qu'on a sur le
  /// proprio attaché à cette réservation.
  void _logReservationDetails() {
    deboger('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    deboger('🔍 [ReferralDetailScreen] BUILD');
    deboger('   reservation.id         = ${reservation.id}');
    deboger('   reservation.reference  = ${reservation.reference}');
    deboger('   reservation.statut     = ${reservation.statut}');
    deboger('   reservation.type       = ${reservation.type}');
    deboger('   reservation.proprio    = ${reservation.proprio}');
    if (reservation.proprio != null) {
      final p = reservation.proprio!;
      // SEC-04 : pas de PII (nom, téléphone, email) dans les logs
      deboger('     ├─ id           = ${p.id}');
      deboger('     ├─ telephone    = ${p.telephone != null ? 'présent' : 'absent'}');
      deboger('     ├─ email        = ${p.email != null ? 'présent' : 'absent'}');
      deboger('     └─ createdAt    = ${p.createdAt}');
    } else {
      deboger('     ⚠️ reservation.proprio == null');
    }
    deboger('   reservation.appart     = ${reservation.appart?.id}');
    deboger('   reservation.locataire  = ${reservation.locataire?.id}');
    deboger('   clientExterne          = '
        '${reservation.clientExterneNom != null ? 'présent' : 'absent'}');
    deboger('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
