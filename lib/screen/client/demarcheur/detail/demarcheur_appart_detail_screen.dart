import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/request/demarcheur_reservation_req.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/demarcheur/detail/widget/appart_calendar_range_picker.dart';
import 'package:asfar/screen/client/demarcheur/detail/widget/booking_form_section.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenities_grid.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenity_item.dart';
import 'package:asfar/screen/client/locataire/booking/widget/detail_title_block.dart';
import 'package:asfar/screen/client/locataire/booking/widget/host_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/quick_specs_card.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/calendar_legend.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/widget/button/share_appartement_button.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/img/img_placeholder.dart';
import 'package:asfar/widget/img/photo_carousel.dart';

/// Écran détail d'un logement partenaire vu par le démarcheur.
///
/// Flow : depuis le dashboard ou la liste complète, le démarcheur tape sur
/// un logement → cet écran. Il consulte les infos (photos, description,
/// équipements, localisation) puis remplit dans la section « Réserver pour
/// mon client » au bas de la page :
/// - Plage de dates (calendrier inline range picker)
/// - Nom + téléphone WhatsApp du client
/// - Prix total négocié (modifiable, suggéré = prix/nuit × nuits)
/// - Validation → POST /api/demarcheur/reservations
class DemarcheurAppartDetailScreen extends StatefulWidget {
  final Appartement appartement;

  const DemarcheurAppartDetailScreen({super.key, required this.appartement});

  @override
  State<DemarcheurAppartDetailScreen> createState() =>
      _DemarcheurAppartDetailScreenState();
}

class _DemarcheurAppartDetailScreenState
    extends State<DemarcheurAppartDetailScreen> {
  static const _amenities = [
    AmenityItem(icon: Icons.wifi, label: 'WiFi fibre'),
    AmenityItem(icon: Icons.local_parking, label: 'Parking'),
    AmenityItem(icon: Icons.shield_outlined, label: 'Sécurité 24/7'),
    AmenityItem(icon: Icons.kitchen_outlined, label: 'Cuisine équipée'),
    AmenityItem(icon: Icons.ac_unit, label: 'Climatisation'),
    AmenityItem(icon: Icons.tv_outlined, label: 'TV'),
  ];

  late DateTime _currentMonth;
  DateTime? _selectedStart;
  DateTime? _selectedEnd;

  final _nomCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _commissionCtrl = TextEditingController();
  String _fullPhone = '';

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final id = widget.appartement.id;
      if (id == null) return;
      context.read<CalendarPlageBloc>().add(LoadCalendarPlages(
            appartId: id,
            debut: DateTime(now.year, now.month, 1),
            fin: DateTime(now.year + 1, now.month, 0),
            isDemarcheur: true,
          ));
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _phoneCtrl.dispose();
    _prixCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }

  int get _nights {
    final s = _selectedStart;
    final e = _selectedEnd;
    if (s == null || e == null) return 0;
    final d = e.difference(s).inDays;
    return d > 0 ? d : 0;
  }

  int get _suggestedPrice {
    final n = _nights;
    if (n == 0) return 0;
    return widget.appartement.priceAmount * n;
  }

  int get _enteredPrice {
    final raw = _prixCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  /// Prix effectivement envoyé au backend. Règle métier :
  /// - prix saisi vide / 0 → fallback prix normal (prix/nuit × nuits)
  /// - prix saisi `< suggestedPrice / 10` (plus de 10× inférieur au prix
  ///   normal) → fallback prix normal (anti-erreur de saisie ou abus)
  /// - sinon → prix saisi tel quel
  int get _effectivePrice {
    final entered = _enteredPrice;
    final suggested = _suggestedPrice;
    if (entered <= 0) return suggested;
    if (suggested > 0 && entered * 10 < suggested) return suggested;
    return entered;
  }

  /// Commission suggérée par défaut : 10 % du prix négocié. Sert uniquement de
  /// pré-remplissage / repère — le démarcheur reste libre de la modifier.
  int get _suggestedCommission =>
      (_effectivePrice * ReferralCommissionHelper.rate).round();

  /// Commission réellement saisie par le démarcheur (FCFA). 0 autorisé
  /// (renonce à sa commission) ; le backend accepte un montant libre >= 0.
  int get _commission {
    final raw = _commissionCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(raw) ?? 0;
  }

  bool get _isFormValid =>
      _selectedStart != null &&
      _selectedEnd != null &&
      _nights > 0 &&
      _nomCtrl.text.trim().isNotEmpty &&
      _fullPhone.replaceAll(RegExp(r'[^\d]'), '').length >= 11 &&
      !_submitting;

  void _onRangeChanged(DateTime start, DateTime? end) {
    setState(() {
      _selectedStart = start;
      _selectedEnd = end;
      // À chaque nouvelle plage complète, on réinitialise le prix négocié au
      // prix total normal (prix/nuit × nuits). Écrase une saisie précédente
      // — comportement voulu : la sélection de dates est l'événement qui
      // recalcule la base de négociation.
      if (end != null) {
        _prixCtrl.text = _suggestedPrice == 0
            ? ''
            : FcfaFormatter.groupThousands(_suggestedPrice);
        // Pré-remplit la commission avec la suggestion 10 % du prix négocié —
        // le démarcheur reste libre de l'ajuster (ou de la mettre à 0).
        final defaultCommission =
            (_suggestedPrice * ReferralCommissionHelper.rate).round();
        _commissionCtrl.text = defaultCommission == 0
            ? ''
            : FcfaFormatter.groupThousands(defaultCommission);
      }
    });
  }

  void _onPriceChanged(String _) {
    // Le NumberInputField met déjà à jour le controller. setState ici sert
    // juste à recalculer la suggestion + l'activation du CTA.
    setState(() {});
  }

  void _onCommissionChanged(String _) {
    // Recalcule l'affichage (bandeau récap commission) à chaque saisie.
    setState(() {});
  }

  void _onPrevMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _onSubmit() {
    deboger(
        '🐛[DEMANDE] _onSubmit() appelé — _submitting=$_submitting, appartId=${widget.appartement.id}, nights=$_nights, nom=${_nomCtrl.text.trim()}');
    if (_submitting) return; // garde anti double-clic (évite un 2ᵉ POST → doublon)
    final appartId = widget.appartement.id;
    final start = _selectedStart;
    if (appartId == null || start == null || _nights == 0) return;
    setState(() => _submitting = true);
    final req = DemarcheurReservationReq(
      appartId: appartId,
      debut: start,
      dure: _nights,
      montant: _effectivePrice.toDouble(),
      montantCommission: _commission.toDouble(),
      clientNom: _nomCtrl.text.trim(),
      clientTelephone: _fullPhone,
    );
    context.read<DemarcheurBloc>().add(CreateDemarcheurReservation(req));
  }

  Future<void> _callProprio() async {
    final tel = widget.appartement.proprietaire?.telephone.trim() ?? '';
    final messenger = ScaffoldMessenger.of(context);
    if (tel.isEmpty) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Aucun numéro propriétaire disponible'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final ok = await launchUrl(Uri(scheme: 'tel', path: tel));
    if (!ok) {
      messenger.showSnackBar(const SnackBar(
        content: Text("Impossible de lancer l'appel"),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _onCreated() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgElev1,
        title: const Text('Demande envoyée'),
        content: Text(
          'Le propriétaire de « ${widget.appartement.titleSafe} » va '
          "valider la demande et vous tenir informé.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              back(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<CalendarPlage> _plagesFromState(CalendarPlageState state) {
    if (state is CalendarPlagesLoaded &&
        state.appartId == widget.appartement.id) {
      return state.plages;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.appartement;
    return BlocListener<DemarcheurBloc, DemarcheurState>(
      listenWhen: (prev, curr) =>
          curr is DemarcheurReservationCreated || curr is DemarcheurError,
      listener: (context, state) {
        if (state is DemarcheurReservationCreated) {
          setState(() => _submitting = false);
          _onCreated();
        } else if (state is DemarcheurError) {
          setState(() => _submitting = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: PhotoCarousel(
                    paths: (a.photos ?? const [])
                        .map((p) => p.path)
                        .toList(),
                    placeholder: ImgPh(tone: a.tone, radius: 0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailTitleBlock(
                        type: a.typeLocation?.label ?? 'Logement',
                        title: a.titleSafe,
                        rating: a.rating,
                        reviews: a.reviewsCount,
                        area: a.areaName,
                        city: a.cityName,
                      ),
                      const SizedBox(height: 18),
                      QuickSpecsCard(
                        beds: a.bedsCount,
                        rooms: a.nbChambres ?? 0,
                        baths: a.bathsCount,
                      ),
                      const SizedBox(height: 22),
                      if ((a.description ?? '').trim().isNotEmpty) ...[
                        const Text('À propos du logement',
                            style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        Text(a.description!, style: AppTextStyles.body),
                        const SizedBox(height: 22),
                      ],
                      const Text('Équipements', style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      const AmenitiesGrid(items: _amenities),
                      if (a.proprietaire != null) ...[
                        const SizedBox(height: 22),
                        const Text('Propriétaire', style: AppTextStyles.h3),
                        const SizedBox(height: 10),
                        HostCard(
                          hostName: a.proprietaire!.fullName,
                          memberSince: '—',
                          certified: false,
                          onContactTap: _callProprio,
                        ),
                      ],
                      const SizedBox(height: 28),
                      const Divider(color: AppColors.line, height: 1),
                      const SizedBox(height: 22),
                      Text(
                        'RÉSERVER POUR MON CLIENT',
                        style: AppTextStyles.eyebrow.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Choisir les dates', style: AppTextStyles.h3),
                      const SizedBox(height: 10),
                      BlocBuilder<CalendarPlageBloc, CalendarPlageState>(
                        builder: (context, state) {
                          final plages = _plagesFromState(state);
                          return Column(
                            children: [
                              AppartCalendarRangePicker(
                                currentMonth: _currentMonth,
                                plages: plages,
                                selectedStart: _selectedStart,
                                selectedEnd: _selectedEnd,
                                onPrevMonth: _onPrevMonth,
                                onNextMonth: _onNextMonth,
                                onRangeChanged: _onRangeChanged,
                              ),
                              const SizedBox(height: 10),
                              const CalendarLegend(),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      BookingFormSection(
                        nomCtrl: _nomCtrl,
                        phoneCtrl: _phoneCtrl,
                        prixCtrl: _prixCtrl,
                        commissionCtrl: _commissionCtrl,
                        selectedStart: _selectedStart,
                        selectedEnd: _selectedEnd,
                        nights: _nights,
                        suggestedPrice: _suggestedPrice,
                        suggestedCommission: _suggestedCommission,
                        commission: _commission,
                        onAnyChange: () => setState(() {}),
                        onPriceChanged: _onPriceChanged,
                        onCommissionChanged: _onCommissionChanged,
                        onPhoneChanged: (full) => _fullPhone = full,
                        canSubmit: _isFormValid,
                        submitting: _submitting,
                        onSubmit: _onSubmit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: IconBoutton(
                icon: Icons.arrow_back_ios_new,
                onPressed: () => back(context),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: ShareAppartementButton(appartement: a),
            ),
          ],
        ),
      ),
    );
  }
}
