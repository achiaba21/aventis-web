import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_state.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_bloc.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_event.dart';
import 'package:asfar/bloc/charge_detail_bloc/charge_detail_state.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_appartement_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_frequence_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_type_picker.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/number_input_field.dart';
import 'package:asfar/widget/section/section_with_eyebrow.dart';

/// Formulaire de création OU édition d'une charge.
///
/// `.create()` : tous les champs vides, dispatch `AddCharge` via `ChargeBloc`.
/// `.edit(initial)` : pré-rempli, dispatch `UpdateChargeAction` via
/// `ChargeDetailBloc` (qui doit être fourni en amont via BlocProvider.value).
class ChargeFormScreen extends StatefulWidget {
  final Charge? initial;

  const ChargeFormScreen.create({super.key}) : initial = null;
  const ChargeFormScreen.edit({super.key, required Charge this.initial});

  bool get isEdit => initial != null;

  @override
  State<ChargeFormScreen> createState() => _ChargeFormScreenState();
}

class _ChargeFormScreenState extends State<ChargeFormScreen> {
  late int? _appartId;
  late String? _appartLabel;
  late TypeCharge _type;
  late TextEditingController _libelleCtrl;
  late TextEditingController _montantCtrl;
  late FrequenceCharge _frequence;
  late DateTime? _dateDebut;
  late DateTime? _dateEcheance;
  late TextEditingController _notesCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _appartId = init?.appartementId;
    _appartLabel = init?.appartementNom;
    _type = init?.typeCharge ?? TypeCharge.autre;
    _libelleCtrl = TextEditingController(text: init?.libelle ?? '');
    _montantCtrl =
        TextEditingController(text: init?.montant?.round().toString() ?? '');
    _frequence = init?.frequence ?? FrequenceCharge.mensuel;
    _dateDebut = init?.dateDebut;
    _dateEcheance = _frequence.isPonctuel ? null : init?.dateEcheance;
    _notesCtrl = TextEditingController(text: init?.notes ?? '');
  }

  @override
  void dispose() {
    _libelleCtrl.dispose();
    _montantCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAppartement() async {
    final apparts = context.read<AppartementBloc>().state.appartements;
    final result = await ChargeAppartementPicker.show(
      context,
      appartements: apparts,
      selectedId: _appartId,
    );
    if (result == null || result == -1) return;
    setState(() {
      _appartId = result;
      _appartLabel = _resolveAppartLabel(apparts, result);
    });
  }

  String? _resolveAppartLabel(List<Appartement> apparts, int id) {
    try {
      return apparts.firstWhere((a) => a.id == id).titre;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickType() async {
    final t = await ChargeTypePicker.show(
      context,
      selected: _type,
      includeAll: false,
    );
    if (t == null) return;
    setState(() => _type = t);
  }

  Future<void> _pickFrequence() async {
    final f = await ChargeFrequencePicker.show(context, selected: _frequence);
    if (f == null) return;
    setState(() {
      _frequence = f;
      if (f.isPonctuel) _dateEcheance = null;
    });
  }

  Future<void> _pickDate({required bool isDebut}) async {
    final initial = isDebut
        ? (_dateDebut ?? DateTime.now())
        : (_dateEcheance ?? _dateDebut ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    setState(() {
      if (isDebut) {
        _dateDebut = picked;
      } else {
        _dateEcheance = picked;
      }
    });
  }

  void _onSubmit() {
    if (_appartId == null) {
      setState(() => _error = 'Sélectionnez un appartement');
      return;
    }
    final montantDigits =
        _montantCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    final montant = double.tryParse(montantDigits);
    if (montant == null || montant <= 0) {
      setState(() => _error = 'Montant invalide');
      return;
    }
    if (_dateDebut != null &&
        _dateEcheance != null &&
        _dateEcheance!.isBefore(_dateDebut!)) {
      setState(() => _error = "L'échéance doit être après le début");
      return;
    }

    setState(() => _error = null);
    final libelle = _libelleCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    // Invariant : dateEcheance nulle si ponctuel — la dateDebut fait office
    // de date prévue de paiement. estRecurrent est dérivé de frequence par
    // Charge.create / copyWith côté modèle.
    final echeance = _frequence.isPonctuel ? null : _dateEcheance;

    if (widget.isEdit) {
      final init = widget.initial!;
      final updated = init.copyWith(
        appartementId: _appartId,
        typeCharge: _type,
        libelle: libelle.isEmpty ? null : libelle,
        montant: montant,
        frequence: _frequence,
        dateDebut: _dateDebut,
        dateEcheance: echeance,
        estRecurrent: _frequence.isRecurrente,
        notes: notes.isEmpty ? null : notes,
      );
      context.read<ChargeDetailBloc>().add(UpdateChargeAction(updated));
    } else {
      context.read<ChargeBloc>().add(AddCharge(
            appartementId: _appartId!,
            typeCharge: _type,
            libelle: libelle.isEmpty ? null : libelle,
            montant: montant,
            frequence: _frequence,
            dateDebut: _dateDebut,
            dateEcheance: echeance,
            notes: notes.isEmpty ? null : notes,
          ));
    }
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
        title: widget.isEdit ? 'Modifier la charge' : 'Nouvelle charge',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: widget.isEdit
          ? BlocConsumer<ChargeDetailBloc, ChargeDetailState>(
              listener: _editListener,
              builder: (context, state) => _buildForm(
                isLoading: state is ChargeDetailActionInProgress &&
                    state.action == ChargeDetailAction.edit,
              ),
            )
          : BlocConsumer<ChargeBloc, ChargeState>(
              listener: _createListener,
              builder: (context, state) => _buildForm(
                isLoading: state is ChargeLoading,
              ),
            ),
    );
  }

  void _createListener(BuildContext context, ChargeState state) {
    if (state is ChargeOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.message),
        behavior: SnackBarBehavior.floating,
      ));
      back(context);
    }
    if (state is ChargeError) {
      setState(() => _error = state.message);
    }
  }

  void _editListener(BuildContext context, ChargeDetailState state) {
    if (state is ChargeDetailActionSuccess &&
        state.action == ChargeDetailAction.edit) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Charge modifiée'),
        behavior: SnackBarBehavior.floating,
      ));
      back(context);
    }
    if (state is ChargeDetailActionError &&
        state.action == ChargeDetailAction.edit) {
      setState(() => _error = state.message);
    }
  }

  Widget _buildForm({required bool isLoading}) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionWithEyebrow(
              label: 'LOGEMENT',
              child: InputField(
                hintText: _appartLabel ?? 'Sélectionner un appartement',
                readOnly: true,
                onTap: _pickAppartement,
                leadingIcon: Icons.home_outlined,
              ),
            ),
            const SizedBox(height: 20),
            SectionWithEyebrow(
              label: 'TYPE & MONTANT',
              child: Column(
                children: [
                  InputField(
                    hintText: _type.label,
                    readOnly: true,
                    onTap: _pickType,
                    leadingIcon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    controller: _libelleCtrl,
                    hintText: 'Libellé (optionnel)',
                    maxLength: 80,
                    leadingIcon: Icons.label_outline,
                  ),
                  const SizedBox(height: 12),
                  NumberInputField(
                    controller: _montantCtrl,
                    hintText: 'Montant',
                    formatThousands: true,
                    suffix: 'FCFA',
                    leadingIcon: Icons.attach_money,
                    useMonoStyle: true,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    hintText: _frequence.label,
                    readOnly: true,
                    onTap: _pickFrequence,
                    leadingIcon: Icons.repeat,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionWithEyebrow(
              label: _frequence.isPonctuel ? 'DATE' : 'DATES',
              child: _frequence.isPonctuel
                  ? InputField(
                      hintText:
                          'Date du paiement · ${_formatDate(_dateDebut)}',
                      readOnly: true,
                      onTap: () => _pickDate(isDebut: true),
                      leadingIcon: Icons.event,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: InputField(
                            hintText: 'Début · ${_formatDate(_dateDebut)}',
                            readOnly: true,
                            onTap: () => _pickDate(isDebut: true),
                            leadingIcon: Icons.event,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InputField(
                            hintText:
                                'Échéance · ${_formatDate(_dateEcheance)}',
                            readOnly: true,
                            onTap: () => _pickDate(isDebut: false),
                            leadingIcon: Icons.event_available,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            SectionWithEyebrow(
              label: 'NOTES',
              child: InputField(
                controller: _notesCtrl,
                hintText: 'Notes (optionnel)',
                maxLines: 4,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: AppTextStyles.small.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: 28),
            CustomButton(
              text: widget.isEdit ? 'Enregistrer' : 'Créer la charge',
              size: ButtonSize.lg,
              block: true,
              loading: isLoading,
              onPressed: isLoading ? null : _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
