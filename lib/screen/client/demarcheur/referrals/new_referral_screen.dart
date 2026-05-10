import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/model/request/demarcheur_reservation_req.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/new_referral_listing_radio_item.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/recap_line.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/feedback/info_banner.dart';
import 'package:asfar/widget/feedback/success_circle.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Tunnel « Nouvelle demande » du Démarcheur — 3 étapes.
///
/// V8.5 Lot 6 : étape 1 lit la liste des appartements depuis
/// `AppartementBloc` (au lieu de `SampleListingsToReferral`). Le bouton
/// « Envoyer la demande » dispatche `CreateDemarcheurReservation` via
/// `DemarcheurBloc` et écoute `DemarcheurReservationCreated` pour passer
/// à l'étape 3 avec la référence serveur.
class NewReferralScreen extends StatefulWidget {
  /// Si fourni, l'étape 1 est pré-sélectionnée sur ce logement et le tunnel
  /// démarre directement à l'étape 2.
  final Appartement? initialAppartement;

  const NewReferralScreen({super.key, this.initialAppartement});

  @override
  State<NewReferralScreen> createState() => _NewReferralScreenState();
}

class _NewReferralScreenState extends State<NewReferralScreen> {
  int _step = 1;
  ListingPreview? _selectedListing;
  Appartement? _selectedAppartement;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late final TextEditingController _arrivalCtrl;
  late final TextEditingController _departureCtrl;
  final _noteCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  late DateTime _arrival;
  late DateTime _departure;

  String? _generatedRef;
  bool _submitting = false;

  static const _monthsShort = [
    'janv.', 'févr.', 'mars', 'avril', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String _formatDate(DateTime d) =>
      '${d.day} ${_monthsShort[d.month - 1]}';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _arrival = DateTime(now.year, now.month, now.day);
    _departure = _arrival.add(
      const Duration(days: ReferralCommissionHelper.defaultNights),
    );
    _arrivalCtrl = TextEditingController(text: _formatDate(_arrival));
    _departureCtrl = TextEditingController(text: _formatDate(_departure));
    final initial = widget.initialAppartement;
    if (initial != null) {
      _selectedAppartement = initial;
      _selectedListing = AppartementToListingMapper.mapOne(initial);
      _step = 2;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppartementBloc>().add(LoadAppartements());
    });
  }

  Future<void> _pickArrival() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _arrival,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _arrival = picked;
      _arrivalCtrl.text = _formatDate(_arrival);
      if (!_departure.isAfter(_arrival)) {
        _departure = _arrival.add(const Duration(days: 1));
        _departureCtrl.text = _formatDate(_departure);
      }
    });
  }

  Future<void> _pickDeparture() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departure,
      firstDate: _arrival.add(const Duration(days: 1)),
      lastDate: _arrival.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _departure = picked;
      _departureCtrl.text = _formatDate(_departure);
    });
  }

  int get _stayNights {
    final days = _departure.difference(_arrival).inDays;
    return days > 0 ? days : 1;
  }

  String get _stepTitle {
    switch (_step) {
      case 1:
        return 'Choisir un logement';
      case 2:
        return 'Infos du client';
      case 3:
        return 'Demande envoyée';
    }
    return '';
  }

  int get _commissionEstimate {
    final l = _selectedListing;
    if (l == null) return 0;
    return ReferralCommissionHelper.estimate(
      pricePerNight: l.price,
      nights: _stayNights,
    );
  }

  bool get _step1Valid => _selectedListing != null;
  bool get _step2Valid =>
      _nameCtrl.text.trim().isNotEmpty && _phoneCtrl.text.trim().isNotEmpty;

  void _goToStep(int next) => setState(() => _step = next);

  void _onLeading() {
    final preselected = widget.initialAppartement != null;
    if (_step == 2 && !preselected) {
      _goToStep(1);
    } else if (_step == 3) {
      back(context);
    } else {
      back(context);
    }
  }

  void _onSubmit() {
    final appart = _selectedAppartement;
    if (appart == null || appart.id == null) return;
    final req = DemarcheurReservationReq(
      appartId: appart.id!,
      debut: _arrival,
      dure: _stayNights,
      montant: (appart.prix ?? 0) * _stayNights,
      montantCommission: _commissionEstimate.toDouble(),
      clientNom: _nameCtrl.text.trim(),
      clientTelephone: _phoneCtrl.text.trim(),
    );
    setState(() => _submitting = true);
    context.read<DemarcheurBloc>().add(CreateDemarcheurReservation(req));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _arrivalCtrl.dispose();
    _departureCtrl.dispose();
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: _stepTitle,
        eyebrow: _step <= 3 ? 'ÉTAPE $_step / 3' : null,
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: _onLeading,
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocListener<DemarcheurBloc, DemarcheurState>(
          listener: (context, state) {
            if (state is DemarcheurReservationCreated) {
              setState(() {
                _submitting = false;
                _generatedRef = state.reservation.codeReservation?.secretKey ??
                    state.reservation.reference ??
                    'REF-${state.reservation.id ?? '?'}';
                _step = 3;
              });
            } else if (state is DemarcheurError) {
              setState(() => _submitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _stepContent(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _stepContent() {
    switch (_step) {
      case 1:
        return _step1();
      case 2:
        return _step2();
      case 3:
        return _step3();
    }
    return const [];
  }

  List<Widget> _step1() {
    return [
      InputField(
        controller: _searchCtrl,
        leadingIcon: Icons.search,
        hintText: 'Rechercher un logement…',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 16),
      BlocBuilder<AppartementBloc, AppartementState>(
        builder: (context, state) {
          if (state is AppartementLoading && state.appartements.isEmpty) {
            return const Column(
              children: [
                ShimmerCard(height: 96),
                SizedBox(height: 12),
                ShimmerCard(height: 96),
              ],
            );
          }
          final apparts = state.appartements;
          final filtered = _filterApparts(apparts, _searchCtrl.text.trim());
          if (filtered.isEmpty) {
            return EmptyState.inline(
              icon: Icons.search_off_outlined,
              title: 'Aucun logement trouvé',
              body: 'Essayez un autre nom de quartier ou de logement.',
            );
          }
          return Column(
            children: [
              for (final a in filtered) ...[
                NewReferralListingRadioItem(
                  appart: a,
                  selectedListingId: _selectedListing?.id,
                  onSelect: (appart, preview) => setState(() {
                    _selectedAppartement = appart;
                    _selectedListing = preview;
                  }),
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
      const SizedBox(height: 12),
      CustomButton(
        text: 'Suivant',
        onPressed: _step1Valid ? () => _goToStep(2) : null,
        size: ButtonSize.lg,
        block: true,
      ),
    ];
  }

  List<Appartement> _filterApparts(List<Appartement> apparts, String query) {
    if (query.isEmpty) return apparts;
    final q = query.toLowerCase();
    return apparts.where((a) {
      final t = (a.titre ?? '').toLowerCase();
      final c = (a.address?.commune?.nom ?? '').toLowerCase();
      final v = (a.address?.commune?.ville?.nom ?? '').toLowerCase();
      return t.contains(q) || c.contains(q) || v.contains(q);
    }).toList();
  }

  List<Widget> _step2() {
    return [
      InputField(
        controller: _nameCtrl,
        eyebrow: 'NOM DU CLIENT',
        hintText: 'Mariam D.',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      InputField(
        controller: _phoneCtrl,
        eyebrow: 'TÉLÉPHONE WHATSAPP',
        hintText: '+225 07 88 12 34',
        keyboardType: TextInputType.phone,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: InputField(
              controller: _arrivalCtrl,
              eyebrow: 'ARRIVÉE',
              readOnly: true,
              onTap: _pickArrival,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InputField(
              controller: _departureCtrl,
              eyebrow: 'DÉPART',
              readOnly: true,
              onTap: _pickDeparture,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      InputField(
        controller: _noteCtrl,
        eyebrow: 'NOTE (FACULTATIF)',
        hintText: 'Préférences, contexte…',
        maxLines: 3,
      ),
      const SizedBox(height: 18),
      InfoBanner(
        icon: Icons.payments_outlined,
        title:
            'Commission estimée ${FcfaFormatter.full(_commissionEstimate)}',
        body: '10 % du séjour · versée après paiement client.',
      ),
      const SizedBox(height: 22),
      CustomButton(
        text: _submitting ? 'Envoi…' : 'Envoyer la demande',
        onPressed: (_step2Valid && !_submitting) ? _onSubmit : null,
        size: ButtonSize.lg,
        block: true,
      ),
    ];
  }

  List<Widget> _step3() {
    final l = _selectedListing!;
    final ref = _generatedRef ?? 'REF-?';
    return [
      const SizedBox(height: 24),
      const Center(child: SuccessCircle(icon: Icons.send)),
      const SizedBox(height: 24),
      const Center(
        child: Text(
          'Demande envoyée !',
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          'Le propriétaire va vérifier la demande et vous tenir informé.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgElev1,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        child: Column(
          children: [
            RecapLine(label: 'Référence', value: ref, mono: true),
            const SizedBox(height: 10),
            RecapLine(label: 'Logement', value: l.title),
            const SizedBox(height: 10),
            RecapLine(label: 'Client', value: _nameCtrl.text.trim()),
            const SizedBox(height: 14),
            const Divider(color: AppColors.line, height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Commission estimée',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    )),
                Text(
                  FcfaFormatter.full(_commissionEstimate),
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      CustomButton(
        text: 'Voir mes demandes',
        onPressed: () => back(context),
        size: ButtonSize.lg,
        block: true,
      ),
      const SizedBox(height: 8),
      PlainButton(
        text: "Retour à l'accueil",
        onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        size: ButtonSize.md,
        block: true,
        textColor: AppColors.text2,
      ),
    ];
  }

}
