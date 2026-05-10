import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_listing_radio.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Adaptateur `ReferralListingRadio` pour le tunnel `NewReferralScreen` —
/// reçoit l'`Appartement` source + la `selectedListingId` actuelle et
/// délègue le tap à un callback `onSelect(Appartement)`.
class NewReferralListingRadioItem extends StatelessWidget {
  final Appartement appart;
  final String? selectedListingId;
  final void Function(Appartement appart, ListingPreview preview) onSelect;

  const NewReferralListingRadioItem({
    super.key,
    required this.appart,
    required this.selectedListingId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final preview = AppartementToListingMapper.mapOne(appart);
    final selected = selectedListingId == preview.id;
    return ReferralListingRadio(
      listing: preview,
      estimatedCommission:
          ReferralCommissionHelper.estimate(pricePerNight: preview.price),
      selected: selected,
      onTap: () => onSelect(appart, preview),
    );
  }
}
