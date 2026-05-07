import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/request/reservation_manuelle_req.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/input/phone_input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Formulaire pour créer une réservation manuelle (propriétaire)
///
/// Permet d'enregistrer une réservation effectuée en dehors de la plateforme
class ReservationManuelleFormScreen extends StatefulWidget {
  const ReservationManuelleFormScreen({super.key});

  @override
  State<ReservationManuelleFormScreen> createState() =>
      _ReservationManuelleFormScreenState();
}

class _ReservationManuelleFormScreenState
    extends State<ReservationManuelleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Sélections
  int? _selectedAppartementId;
  DateTime? _dateDebut;

  // Controllers
  late TextEditingController _dureeController;
  late TextEditingController _clientNomController;
  late TextEditingController _clientTelephoneController;
  late TextEditingController _clientEmailController;
  late TextEditingController _montantController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dureeController = TextEditingController(text: '1');
    _clientNomController = TextEditingController();
    _clientTelephoneController = TextEditingController();
    _clientEmailController = TextEditingController();
    _montantController = TextEditingController();

    // Initialiser avec le premier appartement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apparts = context.read<AppartementBloc>().state.appartements;
      if (apparts.isNotEmpty) {
        setState(() {
          _selectedAppartementId = apparts.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _dureeController.dispose();
    _clientNomController.dispose();
    _clientTelephoneController.dispose();
    _clientEmailController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state is ReservationManuelleCreated) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Réservation créée avec succès"),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (state is ReservationError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is ReservationLoading) {
          setState(() => _isLoading = true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: TextSeed(
            "Réservation manuelle",
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
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : TextSeed(
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
                    // Info box
                    _InfoBox(
                      message:
                          "Cette réservation sera enregistrée sans frais de plateforme",
                      icon: Icons.info_outline,
                    ),

                    const SizedBox(height: 24),

                    // Sélection de l'appartement
                    _SectionTitle(title: "Appartement *"),
                    const SizedBox(height: 8),
                    _AppartementDropdown(
                      appartements: appartements,
                      selectedAppartementId: _selectedAppartementId,
                      onChanged: (id) =>
                          setState(() => _selectedAppartementId = id),
                    ),

                    const SizedBox(height: 24),

                    // Date de début
                    _SectionTitle(title: "Date de début *"),
                    const SizedBox(height: 8),
                    _DatePickerField(
                      selectedDate: _dateDebut,
                      onChanged: (date) => setState(() => _dateDebut = date),
                      hintText: "Sélectionner la date d'arrivée",
                    ),

                    const SizedBox(height: 16),

                    // Durée
                    _SectionTitle(title: "Durée (jours) *"),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      controller: _dureeController,
                      hintText: "Nombre de jours",
                      prefixIcon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "La durée est requise";
                        }
                        final duree = int.tryParse(value);
                        if (duree == null || duree < 1) {
                          return "Durée minimum: 1 jour";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Séparateur client
                    _SectionDivider(title: "Informations client"),

                    const SizedBox(height: 16),

                    // Nom du client
                    _SectionTitle(title: "Nom du client *"),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      controller: _clientNomController,
                      hintText: "Ex: Kouamé Jean",
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Le nom du client est requis";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Téléphone
                    _SectionTitle(title: "Téléphone *"),
                    const SizedBox(height: 8),
                    PhoneInputField(
                      controller: _clientTelephoneController,
                    ),

                    const SizedBox(height: 16),

                    // Email (optionnel)
                    _SectionTitle(title: "Email (optionnel)"),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      controller: _clientEmailController,
                      hintText: "Ex: client@email.com",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Validation basique de l'email
                          if (!value.contains('@') || !value.contains('.')) {
                            return "Email invalide";
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Montant
                    _SectionTitle(title: "Montant total (FCFA) *"),
                    const SizedBox(height: 8),
                    _CustomTextField(
                      controller: _montantController,
                      hintText: "Ex: 75000",
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

                    const SizedBox(height: 40),

                    // Bouton principal
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor:
                              AppColors.accent.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnAccent,
                                ),
                              )
                            : TextSeed(
                                "Enregistrer la réservation",
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
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validations supplémentaires
    if (_selectedAppartementId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner un appartement"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_dateDebut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez sélectionner une date de début"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final duree = int.parse(_dureeController.text);
    final montant = double.parse(_montantController.text);

    final req = ReservationManuelleReq(
      appartId: _selectedAppartementId!,
      debut: _dateDebut!,
      duree: duree,
      clientNom: _clientNomController.text.trim(),
      clientTelephone: _clientTelephoneController.text.trim(),
      clientEmail: _clientEmailController.text.trim().isEmpty
          ? null
          : _clientEmailController.text.trim(),
      montant: montant,
    );

    context.read<ReservationBloc>().add(CreateManualReservation(req));
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
          child: TextSeed(
            title,
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(child: Divider(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String message;
  final IconData icon;

  const _InfoBox({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextSeed(
              message,
              fontSize: 13,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
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

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
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

class _AppartementDropdown extends StatelessWidget {
  final List<Appartement> appartements;
  final int? selectedAppartementId;
  final Function(int?) onChanged;

  const _AppartementDropdown({
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
                      "${a.prix!.toStringAsFixed(0)} FCFA/nuit",
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
          border: selectedDate == null
              ? Border.all(color: AppColors.warning.withOpacity(0.3))
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
                    : hintText,
                color: selectedDate != null ? AppColors.textPrimary : AppColors.textMuted,
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
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
