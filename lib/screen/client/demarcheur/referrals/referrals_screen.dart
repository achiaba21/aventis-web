import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/referral_preview.dart';
import 'package:asfar/screen/client/demarcheur/referrals/new_referral_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_filter_chips.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_row.dart';
import 'package:asfar/screen/client/demarcheur/sample/sample_referrals.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';

/// Écran « Mes demandes » du Démarcheur — onglet Referrals.
///
/// Reproduit `DemarcheurReferrals` du prototype (`app.jsx::ReferralsScreen`) :
/// 5 chips de filtre (Toutes / En attente / Acceptées / Terminées / Refusées),
/// liste filtrée de `ReferralRow` dans une card, bouton « Nouvelle » dans
/// le top-right de l'app bar.
class DemarcheurReferralsScreen extends StatefulWidget {
  const DemarcheurReferralsScreen({super.key});

  @override
  State<DemarcheurReferralsScreen> createState() =>
      _DemarcheurReferralsScreenState();
}

class _DemarcheurReferralsScreenState extends State<DemarcheurReferralsScreen> {
  static const _filters = [
    'Toutes',
    'En attente',
    'Acceptées',
    'Terminées',
    'Refusées',
  ];

  String _filter = 'Toutes';

  ReferralStatus? _statusForFilter(String f) {
    switch (f) {
      case 'En attente':
        return ReferralStatus.pending;
      case 'Acceptées':
        return ReferralStatus.accepted;
      case 'Terminées':
        return ReferralStatus.completed;
      case 'Refusées':
        return ReferralStatus.refused;
      default:
        return null;
    }
  }

  void _onOpenNew() {
    pushScreen(context, const NewReferralScreen());
  }

  void _onOpenDetail(ReferralPreview referral) {
    pushScreen(context, ReferralDetailScreen(referral: referral));
  }

  @override
  Widget build(BuildContext context) {
    final wanted = _statusForFilter(_filter);
    final visible = wanted == null
        ? SampleReferrals.all
        : SampleReferrals.all.where((r) => r.status == wanted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Mes demandes',
        trailing: SizedBox(
          width: 96,
          child: CustomButton(
            text: 'Nouvelle',
            onPressed: _onOpenNew,
            size: ButtonSize.sm,
            block: true,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            ReferralFilterChips(
              filters: _filters,
              selected: _filter,
              onSelect: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                child: visible.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Aucune demande dans cette catégorie.',
                            style: AppTextStyles.small,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgElev1,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(color: AppColors.line, width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (var i = 0; i < visible.length; i++)
                              ReferralRow(
                                referral: visible[i],
                                isLast: i == visible.length - 1,
                                onTap: () => _onOpenDetail(visible[i]),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
