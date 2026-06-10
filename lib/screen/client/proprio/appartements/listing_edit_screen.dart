import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_calendar_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_edit_hero.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_edit_stats_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_infos_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_moderation_actions.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_reductions_tab.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/listing_rules_tab.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/appartement_status_display.dart';
import 'package:asfar/util/calc/calendar_availability.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Édition d'une annonce — `ProprioListingEditScreen`.
///
/// Consomme directement le modèle métier [Appartement]. 4 onglets via
/// `DefaultTabController` (Infos / Calendrier / Tarifs / Règles). L'eyebrow
/// de l'AppBar reflète `appartement.status`. La StatsCard calcule un taux
/// d'occupation **réel** depuis le `CalendarPlageBloc` du mois courant.
class ProprioListingEditScreen extends StatefulWidget {
  final Appartement appartement;
  final int initialTab;

  const ProprioListingEditScreen({
    super.key,
    required this.appartement,
    this.initialTab = 0,
  });

  @override
  State<ProprioListingEditScreen> createState() =>
      _ProprioListingEditScreenState();
}

class _ProprioListingEditScreenState extends State<ProprioListingEditScreen> {
  late final DateTime _statsMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _statsMonth = DateTime(now.year, now.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = widget.appartement.id;
      if (id == null) return;
      context.read<CalendarPlageBloc>().add(
            LoadCalendarPlages(
              appartId: id,
              debut: _statsMonth,
              fin: DateTime(_statsMonth.year, _statsMonth.month + 1, 0),
              isDemarcheur: false,
            ),
          );
    });
  }

  void _stub(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Cherche la version fraîche de l'Appartement dans le cache du BLoC.
  Appartement? _findFresh(List<Appartement> apparts) {
    final id = widget.appartement.id;
    if (id == null) return null;
    for (final a in apparts) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Affiche un dialog de confirmation puis exécute [onConfirm] si l'utilisateur
  /// valide. Utilisé par les actions de modération (hors ligne / en ligne /
  /// resoumettre).
  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.bgElev1,
        title: Text(title, style: const TextStyle(color: AppColors.text)),
        content:
            Text(message, style: const TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTab,
      child: BlocConsumer<AppartementBloc, AppartementState>(
        listener: (context, state) {
          if (state is AppartementLoaded && state.transientMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.transientMessage!),
              behavior: SnackBarBehavior.floating,
            ));
          } else if (state is AppartementError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.danger,
            ));
          }
        },
        builder: (context, appartState) {
          final fresh = _findFresh(appartState.appartements);
          final appart = fresh ?? widget.appartement;
          final busy = appartState is AppartementLoading;
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: DynamicAppBar(
              title: appart.titleSafe,
              eyebrow: AppartementStatusDisplay.eyebrowLabel(appart.status),
              leading: IconBoutton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => back(context),
              ),
              trailing: IconBoutton(
                icon: Icons.more_vert,
                onPressed: () => _stub(context, "Plus d'options bientôt"),
              ),
            ),
            body: SafeArea(
              top: false,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                      child: ListingEditHero(appartement: appart)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    sliver: SliverToBoxAdapter(
                      child: BlocBuilder<CalendarPlageBloc,
                          CalendarPlageState>(
                        builder: (context, calState) {
                          final occupancy = (calState is CalendarPlagesLoaded &&
                                  calState.appartId == appart.id)
                              ? CalendarAvailability.occupancyRateForMonth(
                                  calState.plages, _statsMonth)
                              : 0.0;
                          return ListingEditStatsCard(
                            appartement: appart,
                            occupancyRate: occupancy,
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    sliver: SliverToBoxAdapter(
                      child: ListingModerationActions(
                        status: appart.status,
                        busy: busy,
                        onMettreHorsLigne: () => _confirm(
                          context,
                          title: 'Mettre hors ligne',
                          message:
                              'Votre annonce ne sera plus visible du public. Vous pourrez la remettre en ligne à tout moment.',
                          confirmLabel: 'Mettre hors ligne',
                          confirmColor: AppColors.text,
                          onConfirm: () {
                            final id = appart.id;
                            if (id != null) {
                              context
                                  .read<AppartementBloc>()
                                  .add(MettreHorsLigneAppartement(id));
                            }
                          },
                        ),
                        onRemettreEnLigne: () => _confirm(
                          context,
                          title: 'Remettre en ligne',
                          message:
                              'Votre annonce redeviendra visible du public immédiatement.',
                          confirmLabel: 'Remettre en ligne',
                          confirmColor: AppColors.accent,
                          onConfirm: () {
                            final id = appart.id;
                            if (id != null) {
                              context
                                  .read<AppartementBloc>()
                                  .add(RemettreEnLigneAppartement(id));
                            }
                          },
                        ),
                        onResoumettre: () => _confirm(
                          context,
                          title: 'Resoumettre l\'annonce',
                          message:
                              'Votre annonce sera renvoyée à la modération pour une nouvelle validation.',
                          confirmLabel: 'Resoumettre',
                          confirmColor: AppColors.accent,
                          onConfirm: () {
                            final id = appart.id;
                            if (id != null) {
                              context
                                  .read<AppartementBloc>()
                                  .add(ResoumetreAppartement(id));
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(),
                  ),
                ],
                body: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingInfosTab(
                        appartement: appart,
                        source: fresh,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingCalendarTab(
                        appartementId: appart.id,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingReductionsTab(
                        appartement: appart,
                        source: fresh,
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
                      child: ListingRulesTab(source: fresh),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: TabBar(
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.text3,
        labelStyle: AppTextStyles.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.body.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.accent, width: 2),
        ),
        dividerColor: AppColors.line,
        tabAlignment: TabAlignment.fill,
        tabs: const [
          Tab(text: 'Infos'),
          Tab(text: 'Calendrier'),
          Tab(text: 'Réductions'),
          Tab(text: 'Règles'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
