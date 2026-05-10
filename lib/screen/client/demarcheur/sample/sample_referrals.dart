import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/locataire/home/sample_listings.dart';

/// Données mock alignées sur `mockReferrals` du proto
/// (`demarcheur.jsx::DemarcheurDashboard`).
///
/// Couvre les 4 statuts (en attente, acceptée, terminée, refusée) + un
/// référencement vedette « Mariam D. » en `accepted` qui sert d'entrée pour
/// le ReferralDetail.
class SampleReferrals {
  SampleReferrals._();

  static final List<ReferralPreview> all = [
    ReferralPreview(
      id: 'REF-D8H3K',
      clientName: 'Mariam D.',
      clientPhone: '+225 07 88 12 34',
      listing: SampleListings.all[0], // Loft Plateau
      nights: 3,
      sentAt: DateTime(2025, 11, 8),
      status: ReferralStatus.accepted,
      commission: 13500,
    ),
    ReferralPreview(
      id: 'REF-9K2M7',
      clientName: 'Yacouba D.',
      clientPhone: '+225 05 44 21 88',
      listing: SampleListings.all[2], // Vue lagune
      nights: 5,
      sentAt: DateTime(2025, 11, 5),
      status: ReferralStatus.completed,
      commission: 34000,
    ),
    ReferralPreview(
      id: 'REF-3P6V1',
      clientName: 'Akua N.',
      clientPhone: '+225 07 11 99 22',
      listing: SampleListings.all[1], // Studio Cocody
      nights: 4,
      sentAt: DateTime(2025, 11, 2),
      status: ReferralStatus.completed,
      commission: 12800,
    ),
    ReferralPreview(
      id: 'REF-W4T8X',
      clientName: 'Diallo M.',
      clientPhone: '+225 01 23 45 67',
      listing: SampleListings.all[3], // Penthouse Almadies
      nights: 7,
      sentAt: DateTime(2025, 11, 9),
      status: ReferralStatus.pending,
      commission: 84000,
    ),
    ReferralPreview(
      id: 'REF-Q5R2N',
      clientName: 'Awa K.',
      clientPhone: '+225 07 32 54 76',
      listing: SampleListings.all[0], // Loft Plateau
      nights: 2,
      sentAt: DateTime(2025, 11, 7),
      status: ReferralStatus.pending,
      commission: 9000,
    ),
    ReferralPreview(
      id: 'REF-Z1H9F',
      clientName: 'Mamadou T.',
      clientPhone: '+225 05 78 90 12',
      listing: SampleListings.all[1], // Studio Cocody
      nights: 3,
      sentAt: DateTime(2025, 10, 28),
      status: ReferralStatus.refused,
      commission: 9600,
    ),
  ];

  /// Retourne la première référence d'un statut donné (utile pour démos).
  static ReferralPreview? firstWith(ReferralStatus status) {
    for (final r in all) {
      if (r.status == status) return r;
    }
    return null;
  }
}
