import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_bloc.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/demarcheur/detail/demarcheur_appart_detail_screen.dart';
import 'package:asfar/screen/client/demarcheur/listings/listing_filter_screen.dart';
import 'package:asfar/screen/client/demarcheur/listings/listing_filters.dart';
import 'package:asfar/screen/client/demarcheur/listings/widget/listing_availability_calendar.dart';
import 'package:asfar/screen/client/demarcheur/listings/widget/listing_map_pane.dart';
import 'package:asfar/screen/client/demarcheur/listings/widget/partner_listing_card.dart';
import 'package:asfar/service/model/calendar/calendar_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Liste des logements partenaires du démarcheur — flow « Nouvelle demande ».
/// Tap sur une card → sélection + calendrier de disponibilités inline.
/// Bouton « Filtrer » → écran filtre (pièces, partenaire, zone).
/// Bouton « Continuer » sticky en bas → `DemarcheurAppartDetailScreen`.
class DemarcheurListingsScreen extends StatefulWidget {
  const DemarcheurListingsScreen({super.key});

  @override
  State<DemarcheurListingsScreen> createState() =>
      _DemarcheurListingsScreenState();
}

class _DemarcheurListingsScreenState extends State<DemarcheurListingsScreen> {
  int? _selectedId;
  late DateTime _calendarMonth;
  final Map<int, CalendarResponse> _calendarCache = {};
  final Set<int> _loadingIds = {};
  ListingFilters _activeFilters = const ListingFilters();
  // R14 levé (backend expose lat/lon racine) — toggle utilisateur dans l'AppBar
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _calendarMonth = DateTime(now.year, now.month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DemarcheurBloc>().add(LoadDemarcheurAppartements());
    });
  }

  List<Appartement> _sorted(List<Appartement> apparts) {
    final list = List.of(apparts)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  Future<void> _openFilters() async {
    final state = context.read<DemarcheurBloc>().state;
    final allApparts = state is DemarcheurDataLoaded
        ? _sorted(state.appartements)
        : const <Appartement>[];
    final result = await pushScreen<ListingFilters>(
      context,
      ListingFilterScreen(
        allApparts: allApparts,
        current: _activeFilters,
      ),
    );
    if (result != null && mounted) {
      setState(() => _activeFilters = result);
    }
  }

  Future<void> _selectListing(Appartement appart) async {
    final id = appart.id;
    if (id == null) return;
    setState(() => _selectedId = id);
    if (_calendarCache.containsKey(id)) return;
    setState(() => _loadingIds.add(id));
    try {
      final response = await CalendarService().getDemarcheurCalendar(id);
      if (!mounted) return;
      setState(() {
        _calendarCache[id] = response;
        _loadingIds.remove(id);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingIds.remove(id));
    }
  }

  void _onPrevMonth() {
    final now = DateTime.now();
    final minMonth = DateTime(now.year, now.month);
    final prev = DateTime(_calendarMonth.year, _calendarMonth.month - 1);
    if (!prev.isBefore(minMonth)) {
      setState(() => _calendarMonth = prev);
    }
  }

  void _onNextMonth() {
    setState(() =>
        _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Choisir un logement',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBoutton(
              icon: _showMap ? Icons.view_list_outlined : Icons.map_outlined,
              onPressed: () => setState(() => _showMap = !_showMap),
            ),
            const SizedBox(width: 4),
            _FilterButton(
              activeCount: _activeFilters.activeCount,
              onPressed: _openFilters,
            ),
          ],
        ),
        trailingWidth: 130,
      ),
      body: BlocProvider<DemarcheurMapBloc>(
        create: (_) => DemarcheurMapBloc(),
        lazy: true,
        child: SafeArea(
        top: false,
        child: BlocBuilder<DemarcheurBloc, DemarcheurState>(
          builder: (context, state) {
            if (state is DemarcheurLoading) {
              return const Padding(
                padding: EdgeInsets.fromLTRB(18, 8, 18, 24),
                child: Column(
                  children: [
                    ShimmerCard(height: 112),
                    SizedBox(height: 12),
                    ShimmerCard(height: 112),
                    SizedBox(height: 12),
                    ShimmerCard(height: 112),
                  ],
                ),
              );
            }
            if (state is DemarcheurError) {
              return EmptyState.error(
                message: state.message,
                onRetry: () => context
                    .read<DemarcheurBloc>()
                    .add(LoadDemarcheurAppartements()),
              );
            }

            final allApparts = state is DemarcheurDataLoaded
                ? _sorted(state.appartements)
                : const <Appartement>[];

            if (allApparts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: EmptyState.hero(
                  icon: Icons.home_work_outlined,
                  title: 'Aucun logement partenaire',
                  body:
                      "Les logements de vos propriétaires partenaires apparaîtront ici dès qu'ils accepteront une demande de partenariat.",
                ),
              );
            }

            final apparts = _activeFilters.isEmpty
                ? allApparts
                : _activeFilters.apply(allApparts);

            final selectedAppart = _selectedId != null
                ? apparts.firstWhere(
                    (a) => a.id == _selectedId,
                    orElse: () => apparts.isEmpty ? allApparts.first : apparts.first,
                  )
                : null;

            final appartementsParId = <int, Appartement>{
              for (final a in allApparts)
                if (a.id != null) a.id!: a,
            };

            return Column(
              children: [
                Expanded(
                  child: _showMap
                      ? ListingMapPane(
                          appartementsParId: appartementsParId,
                          activeFilters: _activeFilters,
                          onTapAppartement: (a) => pushScreen(
                            context,
                            DemarcheurAppartDetailScreen(appartement: a),
                          ),
                        )
                      : apparts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: EmptyState.inline(
                                icon: Icons.filter_list_off,
                                title: 'Aucun logement trouvé',
                                body:
                                    'Aucun logement ne correspond à vos filtres.',
                                ctaLabel: 'Réinitialiser les filtres',
                                onCtaTap: () => setState(
                                    () => _activeFilters = const ListingFilters()),
                              ),
                            )
                          : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                          itemCount: apparts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final a = apparts[i];
                            final selected = a.id == _selectedId;
                            return PartnerListingCard(
                              appartement: a,
                              estimatedCommission:
                                  ReferralCommissionHelper.estimate(
                                      pricePerNight: a.priceAmount),
                              isSelected: selected,
                              calendarWidget: selected
                                  ? ListingAvailabilityCalendar(
                                      currentMonth: _calendarMonth,
                                      data: _calendarCache[a.id],
                                      isLoading: _loadingIds.contains(a.id),
                                      onPrev: _onPrevMonth,
                                      onNext: _onNextMonth,
                                    )
                                  : null,
                              onTap: () => _selectListing(a),
                            );
                          },
                        ),
                ),
                if (!_showMap &&
                    _selectedId != null &&
                    selectedAppart != null &&
                    apparts.any((a) => a.id == _selectedId))
                  _ContinueButton(
                    onPressed: () => pushScreen(
                      context,
                      DemarcheurAppartDetailScreen(
                          appartement: selectedAppart),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback? onPressed;

  const _FilterButton({required this.activeCount, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isActive = activeCount > 0;
    final color = isActive ? AppColors.accent : AppColors.text2;
    return SizedBox(
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      'Filtrer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isActive)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$activeCount',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            onPressed: onPressed,
            child: const Text(
              'Continuer',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
