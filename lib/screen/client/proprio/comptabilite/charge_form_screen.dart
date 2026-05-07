import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/comptabilite_filter/comptabilite_filter_cubit.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ChargeFormScreen extends StatefulWidget {
  final Charge? chargeToEdit;

  const ChargeFormScreen({super.key, this.chargeToEdit});

  @override
  State<ChargeFormScreen> createState() => _ChargeFormScreenState();
}

class _ChargeFormScreenState extends State<ChargeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late int? _selectedAppartementId;
  late TypeCharge _selectedType;
  late FrequenceCharge _selectedFrequence;
  late TextEditingController _libelleController;
  late TextEditingController _montantController;
  late TextEditingController _notesController;
  late DateTime? _dateDebut;
  late DateTime? _dateEcheance;
  late bool _estRecurrent;

  bool get isEditing => widget.chargeToEdit != null;

  @override
  void initState() {
    super.initState();

    final charge = widget.chargeToEdit;

    _selectedAppartementId = charge?.appartementId;
    _selectedType = charge?.typeCharge ?? TypeCharge.loyer;
    _selectedFrequence = charge?.frequence ?? FrequenceCharge.mensuel;
    _libelleController = TextEditingController(text: charge?.libelle ?? '');
    _montantController = TextEditingController(
      text: charge?.montant?.toStringAsFixed(0) ?? '',
    );
    _notesController = TextEditingController(text: charge?.notes ?? '');
    _dateDebut = charge?.dateDebut;
    _dateEcheance = charge?.dateEcheance;
    _estRecurrent = charge?.estRecurrent ?? true;

    // Pré-sélection : appartement du filtre courant si rien
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedAppartementId == null) {
        final filterState = context.read<ComptabiliteFilterCubit>().state;
        final apparts = context.read<AppartementBloc>().state.appartements;
        setState(() {
          _selectedAppartementId =
              filterState.selectedAppartementId ?? apparts.firstOrNull?.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _libelleController.dispose();
    _montantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextSeed(
          isEditing ? "Modifier la charge" : "Nouvelle charge",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          color: AppColors.textPrimary,
        ),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: TextSeed(
              "Enregistrer",
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: BlocBuilder<AppartementBloc, AppartementState>(
          builder: (context, appartementState) {
            final appartements = appartementState.appartements;

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: "Appartement *"),
                    const SizedBox(height: 8),
                    _AppartementDropdownRequired(
                      appartements: appartements,
                      selectedAppartementId: _selectedAppartementId,
                      onChanged: (id) =>
                          setState(() => _selectedAppartementId = id),
                    ),
                    if (_selectedAppartementId == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: TextSeed(
                          "Veuillez sélectionner un appartement",
                          fontSize: 11,
                          color: AppColors.warning,
                        ),
                      ),

                    const SizedBox(height: 24),
                    _SectionTitle(title: "Type de charge"),
                    const SizedBox(height: 8),
                    _TypeChargeSelector(
                      selectedType: _selectedType,
                      onChanged: (type) => setState(() => _selectedType = type),
                    ),

                    const SizedBox(height: 24),
                    _SectionTitle(title: "Libellé (optionnel)"),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      controller: _libelleController,
                      hintText: "Ex: Loyer local Cocody",
                      prefixIcon: Icons.label_outline,
                    ),

                    const SizedBox(height: 24),
                    _SectionTitle(title: "Montant (FCFA)"),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      controller: _montantController,
                      hintText: "Ex: 150000",
                      prefixIcon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Le montant est requis";
                        }
                        final montant = double.tryParse(value);
                        if (montant == null || montant <= 0) {
                          return "Montant invalide";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),
                    _SectionTitle(title: "Fréquence"),
                    const SizedBox(height: 8),
                    _FrequenceSelector(
                      selectedFrequence: _selectedFrequence,
                      onChanged: (freq) =>
                          setState(() => _selectedFrequence = freq),
                    ),

                    const SizedBox(height: 24),
                    if (_selectedFrequence == FrequenceCharge.ponctuel) ...[
                      _SectionTitle(title: "Date d'échéance"),
                      const SizedBox(height: 8),
                      _DatePickerField(
                        selectedDate: _dateEcheance,
                        onChanged: (date) =>
                            setState(() => _dateEcheance = date),
                        hintText: "Date limite de paiement",
                      ),
                    ] else ...[
                      _SectionTitle(title: "Date de début"),
                      const SizedBox(height: 8),
                      _DatePickerField(
                        selectedDate: _dateDebut,
                        onChanged: (date) => setState(() => _dateDebut = date),
                        hintText: "Début de la récurrence",
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: AppColors.accent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextSeed(
                                "La prochaine échéance sera calculée automatiquement selon la fréquence",
                                fontSize: 12,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    if (_selectedFrequence != FrequenceCharge.ponctuel)
                      _RecurrentSwitch(
                        value: _estRecurrent,
                        onChanged: (val) =>
                            setState(() => _estRecurrent = val),
                      ),

                    const SizedBox(height: 24),
                    _SectionTitle(title: "Notes (optionnel)"),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      controller: _notesController,
                      hintText: "Notes supplémentaires...",
                      prefixIcon: Icons.notes,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: TextSeed(
                          isEditing ? "Mettre à jour" : "Ajouter la charge",
                          color: AppColors.textOnAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAppartementId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner un appartement"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final montant = double.parse(_montantController.text);
    final isPonctuel = _selectedFrequence == FrequenceCharge.ponctuel;
    final estRecurrent = isPonctuel ? false : _estRecurrent;

    if (isEditing) {
      final updatedCharge = widget.chargeToEdit!.copyWith(
        appartementId: _selectedAppartementId,
        typeCharge: _selectedType,
        libelle:
            _libelleController.text.isEmpty ? null : _libelleController.text,
        montant: montant,
        frequence: _selectedFrequence,
        dateDebut: isPonctuel ? null : _dateDebut,
        dateEcheance: isPonctuel ? _dateEcheance : null,
        estRecurrent: estRecurrent,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      context.read<ChargeBloc>().add(UpdateCharge(charge: updatedCharge));
    } else {
      context.read<ChargeBloc>().add(AddCharge(
            appartementId: _selectedAppartementId!,
            typeCharge: _selectedType,
            libelle:
                _libelleController.text.isEmpty ? null : _libelleController.text,
            montant: montant,
            frequence: _selectedFrequence,
            dateDebut: isPonctuel ? null : _dateDebut,
            dateEcheance: isPonctuel ? _dateEcheance : null,
            estRecurrent: estRecurrent,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          ));
    }

    Navigator.pop(context);
  }
}

// ==================== Widgets helpers ====================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return TextSeed(
      title,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textMuted,
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      textInputAction: (keyboardType?.index == TextInputType.number.index ||
              keyboardType == TextInputType.phone)
          ? TextInputAction.done
          : null,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(prefixIcon, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _AppartementDropdownRequired extends StatelessWidget {
  final List<Appartement> appartements;
  final int? selectedAppartementId;
  final Function(int?) onChanged;

  const _AppartementDropdownRequired({
    required this.appartements,
    required this.selectedAppartementId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validSelectedId =
        appartements.any((a) => a.id == selectedAppartementId)
            ? selectedAppartementId
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: validSelectedId == null
            ? Border.all(color: AppColors.warning.withValues(alpha: 0.5))
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: validSelectedId,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          hint: TextSeed(
            appartements.isEmpty
                ? "Aucun appartement disponible"
                : "Sélectionner un appartement",
            color: AppColors.textMuted,
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
          items: appartements.map((a) {
            return DropdownMenuItem<int?>(
              value: a.id,
              child: Row(
                children: [
                  Icon(Icons.door_front_door_outlined,
                      size: 18, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextSeed(
                      a.titre ?? a.numero ?? "Appart. ${a.id}",
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (a.prix != null)
                    TextSeed(
                      "${a.prix!.toStringAsFixed(0)} FCFA",
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                ],
              ),
            );
          }).toList(),
          onChanged: appartements.isNotEmpty ? onChanged : null,
        ),
      ),
    );
  }
}

class _TypeChargeSelector extends StatelessWidget {
  final TypeCharge selectedType;
  final Function(TypeCharge) onChanged;

  const _TypeChargeSelector({
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TypeCharge.values.map((type) {
        final isSelected = type == selectedType;
        return InkWell(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextSeed(type.icon, fontSize: 16),
                const SizedBox(width: 6),
                TextSeed(
                  type.label,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FrequenceSelector extends StatelessWidget {
  final FrequenceCharge selectedFrequence;
  final Function(FrequenceCharge) onChanged;

  const _FrequenceSelector({
    required this.selectedFrequence,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: FrequenceCharge.values.map((freq) {
        final isSelected = freq == selectedFrequence;
        return InkWell(
          onTap: () => onChanged(freq),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
              ),
            ),
            child: TextSeed(
              freq.label,
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onChanged;
  final String hintText;

  const _DatePickerField({
    required this.selectedDate,
    required this.onChanged,
    this.hintText = "Sélectionner une date",
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: TextSeed(
                selectedDate != null
                    ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                    : hintText,
                color: selectedDate != null
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
            if (selectedDate != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close, color: AppColors.textMuted, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged(picked);
    }
  }
}

class _RecurrentSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const _RecurrentSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat,
              color: value ? AppColors.accent : AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  "Charge récurrente",
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                TextSeed(
                  "Se répète automatiquement chaque période",
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
