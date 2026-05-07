import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/request/demarcheur_reservation_req.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/input/number_input_formatter.dart';
import 'package:asfar/widget/input/phone_input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Formulaire de création d'une réservation démarcheur
class DemarcheurReservationFormScreen extends StatefulWidget {
  final Appartement appartement;
  final DateTime? dateDebut;

  const DemarcheurReservationFormScreen({
    super.key,
    required this.appartement,
    this.dateDebut,
  });

  @override
  State<DemarcheurReservationFormScreen> createState() =>
      _DemarcheurReservationFormScreenState();
}

class _DemarcheurReservationFormScreenState
    extends State<DemarcheurReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime? _dateDebut;
  late TextEditingController _dureeController;
  late TextEditingController _montantController;
  late TextEditingController _commissionController;
  late TextEditingController _clientNomController;
  late TextEditingController _clientTelController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateDebut = widget.dateDebut;
    _dureeController = TextEditingController(text: '1');
    _montantController = TextEditingController();
    _commissionController = TextEditingController();
    _clientNomController = TextEditingController();
    _clientTelController = TextEditingController();
  }

  @override
  void dispose() {
    _dureeController.dispose();
    _montantController.dispose();
    _commissionController.dispose();
    _clientNomController.dispose();
    _clientTelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateDebut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner une date de début"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final req = DemarcheurReservationReq(
      appartId: widget.appartement.id!,
      debut: _dateDebut!,
      dure: NumberInputFormatter.parseInt(_dureeController.text) ?? 1,
      montant: NumberInputFormatter.parseDouble(_montantController.text) ?? 0,
      montantCommission: _commissionController.text.trim().isEmpty
          ? null
          : NumberInputFormatter.parseDouble(_commissionController.text),
      clientNom: _clientNomController.text.trim(),
      clientTelephone: _clientTelController.text.trim(),
    );

    context.read<DemarcheurBloc>().add(CreateDemarcheurReservation(req));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DemarcheurBloc, DemarcheurState>(
      listener: (context, state) {
        if (state is DemarcheurReservationCreated) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Réservation soumise avec succès"),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is DemarcheurError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is DemarcheurLoading) {
          setState(() => _isLoading = true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: TextSeed(
            "Nouvelle réservation",
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
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.accent),
                    )
                  : TextSeed(
                      "Envoyer",
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info appartement
                _AppartInfoBox(appartement: widget.appartement),

                const SizedBox(height: 24),

                _SectionTitle(title: "Date de début *"),
                const SizedBox(height: 8),
                _DatePickerField(
                  selectedDate: _dateDebut,
                  onChanged: (d) => setState(() => _dateDebut = d),
                ),

                const SizedBox(height: 16),

                _SectionTitle(title: "Durée (jours) *"),
                const SizedBox(height: 8),
                _FormField(
                  controller: _dureeController,
                  hintText: "Nombre de jours",
                  icon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NumberInputFormatter(allowDecimals: false)],
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Requis";
                    final d = NumberInputFormatter.parseInt(v);
                    if (d == null || d < 1) return "Minimum 1 jour";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _SectionTitle(title: "Montant total (FCFA) *"),
                const SizedBox(height: 8),
                _FormField(
                  controller: _montantController,
                  hintText: "Ex: 75 000",
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NumberInputFormatter(allowDecimals: false)],
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Requis";
                    final m = NumberInputFormatter.parseDouble(v);
                    if (m == null || m <= 0) return "Montant invalide";
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                _SectionTitle(title: "Montant commission (FCFA)"),
                const SizedBox(height: 8),
                _FormField(
                  controller: _commissionController,
                  hintText: "Ex: 5 000",
                  icon: Icons.handshake_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NumberInputFormatter(allowDecimals: false)],
                  validator: (v) {
                    if (v == null || v.isEmpty) return null;
                    final m = NumberInputFormatter.parseDouble(v);
                    if (m == null || m < 0) return "Montant invalide";
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _SectionDivider(title: "Informations client"),

                const SizedBox(height: 16),

                _SectionTitle(title: "Nom du client *"),
                const SizedBox(height: 8),
                _FormField(
                  controller: _clientNomController,
                  hintText: "Ex: Kouamé Jean",
                  icon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "Requis" : null,
                ),

                const SizedBox(height: 16),

                _SectionTitle(title: "Téléphone client *"),
                const SizedBox(height: 8),
                PhoneInputField(
                  controller: _clientTelController,
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.textOnAccent),
                          )
                        : TextSeed(
                            "Soumettre la réservation",
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
          ),
        ),
      ),
    );
  }
}

// ==================== Widgets helpers ====================

class _AppartInfoBox extends StatelessWidget {
  final Appartement appartement;
  const _AppartInfoBox({required this.appartement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.door_front_door_outlined,
              color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  appartement.titre ??
                      appartement.numero ??
                      "Appartement ${appartement.id}",
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
                if (appartement.prix != null)
                  TextSeed(
                    "${appartement.prix!.toStringAsFixed(0)} FCFA / nuit",
                    fontSize: 12,
                    color: AppColors.accent.withValues(alpha:0.7),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return TextSeed(title,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted);
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.textSecondary)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextSeed(title,
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500),
        ),
        Expanded(child: Divider(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textInputAction: (keyboardType?.index == TextInputType.number.index ||
              keyboardType == TextInputType.phone)
          ? TextInputAction.done
          : null,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textMuted),
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
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onChanged;

  const _DatePickerField(
      {required this.selectedDate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _show(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: selectedDate == null
              ? Border.all(color: AppColors.warning.withValues(alpha:0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: TextSeed(
                selectedDate != null
                    ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                    : "Sélectionner la date d'arrivée",
                color: selectedDate != null ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
            if (selectedDate != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child:
                    Icon(Icons.close, color: AppColors.textMuted, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _show(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.accent,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onChanged(picked);
  }
}
