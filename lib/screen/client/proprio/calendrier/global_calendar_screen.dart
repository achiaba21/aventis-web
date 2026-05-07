import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/calendar/calendar_view_mode.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/calendar_header.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/calendar_legend.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/calendar_zoomable_view.dart';
import 'package:asfar/screen/client/proprio/reservations/proprio_reservation_detail_screen.dart';
import 'package:asfar/screen/client/proprio/reservations/reservation_manuelle_form_screen.dart';
import 'package:asfar/util/helper/calendar_color_helper.dart';
import 'package:asfar/util/helper/calendar_stats_helper.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/widget/loader/circular_progress.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran principal du calendrier global des réservations
///
/// Affiche toutes les réservations du propriétaire avec :
/// - 3 niveaux de zoom (Année/Mois/Jours) via pinch-to-zoom
/// - Code couleur par appartement
/// - Stats (taux d'occupation, réservations en attente)
/// - Navigation vers détails réservation
class GlobalCalendarScreen extends StatefulWidget {
  const GlobalCalendarScreen({super.key});

  @override
  State<GlobalCalendarScreen> createState() => _GlobalCalendarScreenState();
}

class _GlobalCalendarScreenState extends State<GlobalCalendarScreen> {
  CalendarViewMode _viewMode = CalendarViewMode.month; // Mode par défaut
  DateTime _currentDate = DateTime.now();
  double _lastScale = 1.0;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppartementBloc>().state;
    deboger('[GlobalCalendar] initState — appartementState: ${state.runtimeType}');
    if (state is! ProprietaireAppartementsLoaded && state is! AppartementOperationSuccess) {
      deboger('[GlobalCalendar] initState — déclenchement LoadProprietaireAppartements');
      context.read<AppartementBloc>().add(LoadProprietaireAppartements());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextSeed(
          "Calendrier",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreateReservation(context),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.textOnAccent),
      ),
      body: BlocBuilder<ReservationBloc, ReservationState>(
        builder: (context, reservationState) {
          return BlocBuilder<AppartementBloc, AppartementState>(
            builder: (context, appartementState) {
              deboger('[GlobalCalendar] reservationState: ${reservationState.runtimeType}');
              deboger('[GlobalCalendar] appartementState: ${appartementState.runtimeType}');

              // États de chargement et erreur
              final bool reservationsReady = reservationState is ReservationLoaded;
              final bool appartementsReady = appartementState is ProprietaireAppartementsLoaded ||
                  appartementState is AppartementOperationSuccess ||
                  (appartementState is AppartementError && appartementState.appartements.isNotEmpty);

              if (!reservationsReady || !appartementsReady) {
                deboger('[GlobalCalendar] loader affiché — reservationsReady=$reservationsReady, appartementsReady=$appartementsReady');
                return const Center(child: CircularProgress());
              }

              // Récupérer les données
              final reservations = _getReservations(reservationState);
              final appartements = _getAppartements(appartementState);
              deboger('[GlobalCalendar] données prêtes — ${reservations.length} réservations, ${appartements.length} appartements');

              if (appartements.isEmpty) {
                return _buildEmptyState();
              }

              // Générer la palette de couleurs (une seule fois)
              final colorPalette =
                  CalendarColorHelper.generateColorPalette(appartements);

              // Calculer les stats pour le mois affiché
              final stats = CalendarStatsHelper.calculateMonthStats(
                _currentDate,
                reservations,
              );

              return GestureDetector(
                onScaleUpdate: (details) => _onScaleUpdate(details),
                onScaleEnd: (_) => _lastScale = 1.0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(Espacement.paddingBloc),
                    child: Column(
                      children: [
                        // En-tête avec stats et bouton Today
                        CalendarHeader(
                          mode: _viewMode,
                          currentDate: _currentDate,
                          pendingCount: stats.pendingCount,
                          occupancyRate: stats.occupancyRate,
                          onTodayPressed: _goToToday,
                          onPreviousPressed: _goToPrevious,
                          onNextPressed: _goToNext,
                        ),

                        SizedBox(height: Espacement.gapSection * 2),

                        // Vue du calendrier (selon le mode)
                        Expanded(
                          child: _buildCalendarView(
                            reservations,
                            appartements,
                            colorPalette,
                          ),
                        ),

                        SizedBox(height: Espacement.gapSection * 2),

                        // Légende des couleurs
                        CalendarLegend(
                          appartements: appartements,
                          colorPalette: colorPalette,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Gère le geste de pinch-to-zoom
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale < 0.9 && _lastScale >= 0.9) {
      // Dézoom (resserrer 2 doigts)
      _zoomOut();
    } else if (details.scale > 1.1 && _lastScale <= 1.1) {
      // Zoom (écarter 2 doigts)
      _zoomIn();
    }
    _lastScale = details.scale;
  }

  /// Zoom avant (Year → Month → Days)
  void _zoomIn() {
    if (_viewMode.canZoomIn) {
      setState(() {
        _viewMode = _viewMode.nextZoomLevel!;
      });
    }
  }

  /// Zoom arrière (Days → Month → Year)
  void _zoomOut() {
    if (_viewMode.canZoomOut) {
      setState(() {
        _viewMode = _viewMode.previousZoomLevel!;
      });
    }
  }

  /// Retourne à aujourd'hui
  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  /// Navigation vers période précédente
  void _goToPrevious() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.year:
          _currentDate = DateTime(_currentDate.year - 1, _currentDate.month);
          break;
        case CalendarViewMode.month:
        case CalendarViewMode.days:
          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
          break;
      }
    });
  }

  /// Navigation vers période suivante
  void _goToNext() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.year:
          _currentDate = DateTime(_currentDate.year + 1, _currentDate.month);
          break;
        case CalendarViewMode.month:
        case CalendarViewMode.days:
          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
          break;
      }
    });
  }

  /// Construit la vue du calendrier selon le mode actif
  Widget _buildCalendarView(
    List<Reservation> reservations,
    List<Appartement> appartements,
    Map<int, Color> colorPalette,
  ) {
    return CalendarZoomableView(
      mode: _viewMode,
      currentDate: _currentDate,
      reservations: reservations,
      appartements: appartements,
      colorPalette: colorPalette,
      onDateTapped: _onDateTapped,
      onMonthTapped: _onMonthTapped,
      onReservationTapped: _onReservationTapped,
    );
  }

  /// Récupère les réservations depuis le BLoC
  List<Reservation> _getReservations(ReservationState state) {
    if (state is ReservationLoaded) {
      // Filtrer les réservations annulées
      return state.reservations
          .where((r) => r.statut != ReservationStatus.annulee)
          .toList();
    }
    return [];
  }

  /// Récupère les appartements depuis le BLoC
  /// Utilise state.appartements (base class) qui persiste le dernier état connu
  List<Appartement> _getAppartements(AppartementState state) {
    return state.appartements;
  }

  /// Affiche un état vide si aucun appartement
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Espacement.paddingBloc * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 80,
              color: AppColors.textMuted,
            ),
            SizedBox(height: Espacement.gapSection * 2),
            TextSeed(
              'Aucun appartement',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: Espacement.gapSection),
            TextSeed(
              'Ajoutez un appartement pour voir le calendrier',
              fontSize: 14,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Callback quand l'utilisateur tape sur une réservation
  void _onReservationTapped(Reservation reservation) {
    pushScreen(context, ProprioReservationDetailScreen(reservation));
  }

  /// Callback quand l'utilisateur tape sur un jour (en vue mois)
  void _onDateTapped(DateTime date) {
    setState(() {
      _currentDate = date;
      _viewMode = CalendarViewMode.days; // Zoom vers la vue détaillée
    });
  }

  /// Callback quand l'utilisateur tape sur un mois (en vue année)
  void _onMonthTapped(int month) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, month);
      _viewMode = CalendarViewMode.month; // Zoom vers la vue mensuelle
    });
  }

  /// Navigation vers création de réservation
  void _onCreateReservation(BuildContext context) {
    pushScreen(context, const ReservationManuelleFormScreen());
  }
}
