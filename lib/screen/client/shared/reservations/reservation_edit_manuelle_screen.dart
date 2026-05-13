import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_bloc.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_event.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_state.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/request/reservation_manuelle_req.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/calendar_availability.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Écran d'édition d'une réservation manuelle — proprio uniquement.
///
/// Permet de modifier les dates et les coordonnées du client externe. Le BLoC
/// dispatche `PerformAction(edit, editReq)` qui appelle
/// `ReservationService.updateManualReservation()`. À utiliser uniquement si
/// `statut < payée` (la matrice côté `ReservationActionsResolver` garantit
/// que l'action n'est pas exposée au-delà).
class ReservationEditManuelleScreen extends StatefulWidget {
  final Reservation reservation;

  const ReservationEditManuelleScreen({
    super.key,
    required this.reservation,
  });

  @override
  State<ReservationEditManuelleScreen> createState() =>
      _ReservationEditManuelleScreenState();
}

class _ReservationEditManuelleScreenState
    extends State<ReservationEditManuelleScreen> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _telCtrl;
  late final TextEditingController _emailCtrl;
  late DateTime? _debut;
  late DateTime? _fin;
  String? _error;

  @override
  void initState() {
    super.initState();
    final r = widget.reservation;
    _nomCtrl = TextEditingController(text: r.clientExterneNom ?? '');
    _telCtrl = TextEditingController(text: r.clientExterneTelephone ?? '');
    _emailCtrl = TextEditingController(text: r.clientExterneEmail ?? '');
    _debut = r.debut;
    _fin = r.fin;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appartId = r.appart?.id;
      if (appartId == null) return;
      final now = DateTime.now();
      context.read<CalendarPlageBloc>().add(
            LoadCalendarPlages(
              appartId: appartId,
              debut: DateTime(now.year, now.month - 1, 1),
              fin: DateTime(now.year + 1, now.month, 0),
              isDemarcheur: false,
            ),
          );
    });
  }

  List<CalendarPlage> _plagesForAppart() {
    final state = context.read<CalendarPlageBloc>().state;
    final id = widget.reservation.appart?.id;
    if (state is CalendarPlagesLoaded && state.appartId == id) {
      return state.plages;
    }
    return const [];
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDebut}) async {
    final initial = isDebut
        ? (_debut ?? DateTime.now())
        : (_fin ?? _debut ?? DateTime.now());
    final plages = _plagesForAppart();
    final r = widget.reservation;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      selectableDayPredicate: (day) => CalendarAvailability.isDayAvailable(
        day,
        plages,
        selfStart: r.debut,
        selfEnd: r.fin,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _debut = picked;
        } else {
          _fin = picked;
        }
      });
    }
  }

  void _onSubmit() {
    final r = widget.reservation;
    final apartId = r.appart?.id;
    final nom = _nomCtrl.text.trim();
    final tel = _telCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final debut = _debut;
    final fin = _fin;
    final prix = r.prix;

    if (apartId == null || debut == null || fin == null || prix == null) {
      setState(() => _error = 'Informations incomplètes');
      return;
    }
    if (nom.isEmpty) {
      setState(() => _error = 'Nom du client obligatoire');
      return;
    }
    if (tel.isEmpty) {
      setState(() => _error = 'Téléphone du client obligatoire');
      return;
    }
    final duree = fin.difference(debut).inDays;
    if (duree <= 0) {
      setState(() => _error = 'La fin doit être après le début');
      return;
    }

    final plages = _plagesForAppart();
    final available = CalendarAvailability.isRangeAvailable(
      debut,
      fin,
      plages,
      selfStart: r.debut,
      selfEnd: r.fin,
    );
    if (!available) {
      setState(() => _error =
          'Cette plage chevauche une autre réservation. Choisissez une autre période.');
      return;
    }

    setState(() => _error = null);
    final req = ReservationManuelleReq(
      appartId: apartId,
      debut: debut,
      duree: duree,
      clientNom: nom,
      clientTelephone: tel,
      clientEmail: email.isEmpty ? null : email,
      montant: prix,
    );

    context.read<ReservationDetailBloc>().add(
          PerformAction(ReservationDetailAction.edit, editReq: req),
        );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Sélectionner';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Modifier la réservation',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: BlocConsumer<ReservationDetailBloc, ReservationDetailState>(
        listener: (context, state) {
          if (state is ReservationDetailActionSuccess &&
              state.action == ReservationDetailAction.edit) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Réservation mise à jour'),
              behavior: SnackBarBehavior.floating,
            ));
            back(context);
          }
          if (state is ReservationDetailActionError &&
              state.action == ReservationDetailAction.edit) {
            setState(() => _error = state.message);
          }
        },
        builder: (context, state) {
          final loading = state is ReservationDetailActionInProgress &&
              state.action == ReservationDetailAction.edit;
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DATES', style: AppTextStyles.eyebrow),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: InputField(
                          eyebrow: 'Début',
                          hintText: _formatDate(_debut),
                          readOnly: true,
                          onTap: () => _pickDate(isDebut: true),
                          leadingIcon: Icons.event,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InputField(
                          eyebrow: 'Fin',
                          hintText: _formatDate(_fin),
                          readOnly: true,
                          onTap: () => _pickDate(isDebut: false),
                          leadingIcon: Icons.event,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('CLIENT', style: AppTextStyles.eyebrow),
                  const SizedBox(height: 10),
                  InputField(
                    controller: _nomCtrl,
                    eyebrow: 'Nom complet',
                    hintText: 'Ex. Aya Konan',
                    leadingIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    controller: _telCtrl,
                    eyebrow: 'Téléphone',
                    hintText: '+225 07 12 34 56',
                    keyboardType: TextInputType.phone,
                    leadingIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    controller: _emailCtrl,
                    eyebrow: 'Email (optionnel)',
                    hintText: 'email@exemple.com',
                    keyboardType: TextInputType.emailAddress,
                    leadingIcon: Icons.mail_outline,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  CustomButton(
                    text: 'Enregistrer',
                    size: ButtonSize.lg,
                    block: true,
                    loading: loading,
                    onPressed: loading ? null : _onSubmit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
