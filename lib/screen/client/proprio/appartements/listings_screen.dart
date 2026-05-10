import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/listing_edit_screen.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_full_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listings_filter_chips.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/new_listing_card.dart';
import 'package:asfar/screen/client/proprio/sample/sample_property_perf.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Liste des annonces du propriétaire — onglet Annonces du `ProprioShell`.
///
/// Reproduit `ProprietaireListings` du prototype : header back + plus,
/// 4 chips de filtre, liste des `ListingFullCard` 16:9, card « Nouvelle
/// annonce » dashed en fin de liste.
class ProprioListingsScreen extends StatefulWidget {
  const ProprioListingsScreen({super.key});

  @override
  State<ProprioListingsScreen> createState() => _ProprioListingsScreenState();
}

class _ProprioListingsScreenState extends State<ProprioListingsScreen> {
  static const _filters = [
    'Tout (4)',
    'Actifs (4)',
    'En pause (0)',
    'Brouillon (1)',
  ];

  String _filter = 'Tout (4)';

  void _stub(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfs = SamplePropertyPerf.all;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Mes annonces',
        leading: Navigator.canPop(context)
            ? IconBoutton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => back(context),
              )
            : null,
        trailing: IconBoutton(
          icon: Icons.add,
          onPressed: () =>
              _stub('Création d\'annonce disponible prochainement (F2)'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 6),
            ListingsFilterChips(
              filters: _filters,
              selected: _filter,
              onSelect: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                child: Column(
                  children: [
                    for (var i = 0; i < perfs.length; i++) ...[
                      ListingFullCard(
                        listing: perfs[i].listing,
                        occupancyRate: perfs[i].occupancyRate,
                        monthlyRevenue: perfs[i].monthlyRevenue,
                        onTap: () => pushScreen(
                          context,
                          ProprioListingEditScreen(listing: perfs[i].listing),
                        ),
                        onMoreTap: () => _stub("Plus d'options bientôt"),
                        onCalendarTap: () => pushScreen(
                          context,
                          ProprioListingEditScreen(
                            listing: perfs[i].listing,
                            initialTab: 1,
                          ),
                        ),
                        onEditTap: () => pushScreen(
                          context,
                          ProprioListingEditScreen(
                            listing: perfs[i].listing,
                            initialTab: 0,
                          ),
                        ),
                        onStatsTap: () => _stub(
                            'Statistiques détaillées disponibles prochainement'),
                      ),
                      const SizedBox(height: 14),
                    ],
                    NewListingCard(
                      onTap: () => _stub(
                          'Création d\'annonce disponible prochainement (F2)'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
