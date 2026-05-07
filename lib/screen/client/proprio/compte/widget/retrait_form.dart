import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/comptabilite_calculator.dart';
import 'package:asfar/widget/button/plain_button_expand.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Bottom sheet pour demander un retrait
class RetraitForm extends StatefulWidget {
  final double soldeDisponible;
  final Function(double montant) onConfirm;

  const RetraitForm({
    super.key,
    required this.soldeDisponible,
    required this.onConfirm,
  });

  /// Affiche le bottom sheet de retrait
  static Future<void> show({
    required BuildContext context,
    required double soldeDisponible,
    required Function(double montant) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RetraitForm(
        soldeDisponible: soldeDisponible,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<RetraitForm> createState() => _RetraitFormState();
}

class _RetraitFormState extends State<RetraitForm> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  void _setToutRetirer() {
    _montantController.text = widget.soldeDisponible.toStringAsFixed(0);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final montant = double.tryParse(_montantController.text) ?? 0;
      if (montant > 0 && montant <= widget.soldeDisponible) {
        setState(() => _isLoading = true);
        widget.onConfirm(montant);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              TextSeed(
                "Demander un retrait",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 8),

              // Solde disponible
              TextSeed(
                "Solde disponible : ${ComptabiliteCalculator.formatMontant(widget.soldeDisponible)} FCFA",
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 24),

              // Champ montant
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: "Montant",
                  labelStyle: TextStyle(color: AppColors.textMuted),
                  suffixText: "FCFA",
                  suffixStyle: TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.accent),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final montant = double.tryParse(value);
                  if (montant == null || montant <= 0) {
                    return 'Montant invalide';
                  }
                  if (montant > widget.soldeDisponible) {
                    return 'Solde insuffisant';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Bouton "Tout retirer"
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _setToutRetirer,
                  icon: Icon(Icons.all_inclusive, color: AppColors.accent, size: 18),
                  label: TextSeed(
                    "Tout retirer",
                    color: AppColors.accent,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton confirmer
              PlainButtonExpand(
                value: _isLoading ? "Chargement..." : "Confirmer le retrait",
                onPress: _isLoading ? null : _submit,
                color: AppColors.accent,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
