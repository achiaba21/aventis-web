import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/forms/charge_form_data.dart';
import 'package:asfar/model/forms/charge_form_errors.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_appartement_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_frequence_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_type_picker.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_type_quick_chips.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/charge_form_validator.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/number_input_field.dart';
import 'package:asfar/widget/input/select_field.dart';
import 'package:asfar/widget/section/section_with_eyebrow.dart';

/// Corps du formulaire de création/édition d'une charge.
///
/// Gère son propre état (champs + validation inline) et délègue la soumission
/// via [onSubmit] une fois la validation passée. L'écran parent reste
/// responsable du BLoC (dispatch + feedback succès/erreur).
class ChargeFormBody extends StatefulWidget {
  final Charge? initial;
  final bool isLoading;
  final ValueChanged<ChargeFormData> onSubmit;

  const ChargeFormBody({
    super.key,
    required this.initial,
    required this.isLoading,
    required this.onSubmit,
  });

  bool get isEdit => initial != null;

  @override
  State<ChargeFormBody> createState() => _ChargeFormBodyState();
}

class _ChargeFormBodyState extends State<ChargeFormBody> {
  late int? _appartId;
  late String? _appartLabel;
  late TypeCharge _type;
  late TextEditingController _libelleCtrl;
  late TextEditingController _montantCtrl;
  late FrequenceCharge _frequence;
  late DateTime? _dateDebut;
  late DateTime? _dateEcheance;
  late TextEditingController _notesCtrl;
  ChargeFormErrors _errors = const ChargeFormErrors();

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _appartId = init?.appartementId;
    _appartLabel = init?.appartementNom;
    // Défaut « Électricité » à la création (cas le plus fréquent) ; valeur
    // existante en édition.
    _type = init?.typeCharge ?? TypeCharge.electricite;
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

  void _submit() {
    final errors = ChargeFormValidator.validate(
      appartementId: _appartId,
      montantText: _montantCtrl.text,
      dateDebut: _dateDebut,
      dateEcheance: _dateEcheance,
      frequence: _frequence,
    );
    if (!errors.isValid) {
      setState(() => _errors = errors);
      return;
    }
    setState(() => _errors = const ChargeFormErrors());

    final libelle = _libelleCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final echeance = _frequence.isPonctuel ? null : _dateEcheance;

    widget.onSubmit(ChargeFormData(
      appartementId: _appartId!,
      typeCharge: _type,
      libelle: libelle.isEmpty ? null : libelle,
      montant: errors.montantValue!,
      frequence: _frequence,
      dateDebut: _dateDebut!,
      dateEcheance: echeance,
      notes: notes.isEmpty ? null : notes,
    ));
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Sélectionner';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionWithEyebrow(
              label: 'LOGEMENT',
              child: SelectField(
                placeholder: 'Sélectionner un appartement',
                value: _appartLabel,
                leadingIcon: Icons.home_outlined,
                errorText: _errors.appartement,
                onTap: _pickAppartement,
              ),
            ),
            const SizedBox(height: 20),
            SectionWithEyebrow(
              label: 'TYPE & MONTANT',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChargeTypeQuickChips(
                    selected: _type,
                    onSelect: (t) => setState(() => _type = t),
                  ),
                  const SizedBox(height: 12),
                  SelectField(
                    placeholder: 'Type de charge',
                    value: _type.label,
                    leadingEmoji: _type.icon,
                    onTap: _pickType,
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
                    errorText: _errors.montant,
                  ),
                  const SizedBox(height: 12),
                  SelectField(
                    placeholder: 'Fréquence',
                    value: _frequence.label,
                    leadingIcon: Icons.repeat,
                    onTap: _pickFrequence,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionWithEyebrow(
              label: _frequence.isPonctuel ? 'DATE' : 'DATES',
              child: _frequence.isPonctuel
                  ? SelectField(
                      placeholder: 'Date du paiement',
                      value:
                          _dateDebut == null ? null : _formatDate(_dateDebut),
                      leadingIcon: Icons.event,
                      errorText: _errors.date,
                      onTap: () => _pickDate(isDebut: true),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SelectField(
                                placeholder: 'Début',
                                value: _dateDebut == null
                                    ? null
                                    : _formatDate(_dateDebut),
                                leadingIcon: Icons.event,
                                onTap: () => _pickDate(isDebut: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SelectField(
                                placeholder: 'Échéance',
                                value: _dateEcheance == null
                                    ? null
                                    : _formatDate(_dateEcheance),
                                leadingIcon: Icons.event_available,
                                onTap: () => _pickDate(isDebut: false),
                              ),
                            ),
                          ],
                        ),
                        if (_errors.date != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _errors.date!,
                            style: AppTextStyles.small
                                .copyWith(color: AppColors.danger),
                          ),
                        ],
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
            const SizedBox(height: 28),
            CustomButton(
              text: widget.isEdit ? 'Enregistrer' : 'Créer la charge',
              size: ButtonSize.lg,
              block: true,
              loading: widget.isLoading,
              onPressed: widget.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
