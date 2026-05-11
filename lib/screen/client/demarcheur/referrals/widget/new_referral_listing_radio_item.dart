import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_listing_radio.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';

/// Adaptateur `ReferralListingRadio` pour le tunnel `NewReferralScreen` —
/// reçoit l'`Appartement` source + l'id sélectionné actuel et délègue le
/// tap à un callback `onSelect(Appartement)`.
class NewReferralListingRadioItem extends StatelessWidget {
  final Appartement appart;
  final String? selectedListingId;
  final void Function(Appartement appart) onSelect;

  const NewReferralListingRadioItem({
    super.key,
    required this.appart,
    required this.selectedListingId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedListingId == appart.displayId;
    return ReferralListingRadio(
      appartement: appart,
      estimatedCommission: ReferralCommissionHelper.estimate(
          pricePerNight: appart.priceAmount),
      selected: selected,
      onTap: () => onSelect(appart),
    );
  }
}
