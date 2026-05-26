import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/payment_method_chips.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/reservation_recap_card.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/source_picker.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/number_input_field.dart';
import 'package:asfar/widget/input/phone_input_field.dart';

/// Step 2 du wizard — coordonnées client, source, (si apporteur) nom + tel +
/// commission, paiement, récap.
class StepClientInfo extends StatefulWidget {
  final String? initialNom;
  final String? initialTel;
  final String? initialApporteurNom;
  final String? initialApporteurTel;
  final double? initialMontantCommission;
  final ReservationManuelleSource? source;
  final MoyenPaiement? moyenPaiement;
  final int nbNuits;
  final int prixNuit;
  final int totalClient;
  final int totalRecuProprio;
  final void Function(String) onNomChange;
  final void Function(String) onTelChange;
  final void Function(String) onApporteurNomChange;
  final void Function(String) onApporteurTelChange;
  final void Function(double?) onCommissionChange;
  final ValueChanged<ReservationManuelleSource?> onSourceChange;
  final ValueChanged<MoyenPaiement> onPaiementChange;
  final Map<String, String> errors;

  const StepClientInfo({
    super.key,
    required this.initialNom,
    required this.initialTel,
    required this.initialApporteurNom,
    required this.initialApporteurTel,
    required this.initialMontantCommission,
    required this.source,
    required this.moyenPaiement,
    required this.nbNuits,
    required this.prixNuit,
    required this.totalClient,
    required this.totalRecuProprio,
    required this.onNomChange,
    required this.onTelChange,
    required this.onApporteurNomChange,
    required this.onApporteurTelChange,
    required this.onCommissionChange,
    required this.onSourceChange,
    required this.onPaiementChange,
    required this.errors,
  });

  @override
  State<StepClientInfo> createState() => _StepClientInfoState();
}

class _StepClientInfoState extends State<StepClientInfo> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _telCtrl;
  late final TextEditingController _apporteurNomCtrl;
  late final TextEditingController _apporteurTelCtrl;
  late final TextEditingController _commissionCtrl;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.initialNom ?? '');
    _telCtrl = TextEditingController(text: widget.initialTel ?? '');
    _apporteurNomCtrl =
        TextEditingController(text: widget.initialApporteurNom ?? '');
    _apporteurTelCtrl =
        TextEditingController(text: widget.initialApporteurTel ?? '');
    _commissionCtrl = TextEditingController(
      text: widget.initialMontantCommission == null
          ? ''
          : widget.initialMontantCommission!.round().toString(),
    );
  }

  @override
  void didUpdateWidget(covariant StepClientInfo old) {
    super.didUpdateWidget(old);
    // Suggestion auto = 10% du montant total client quand l'utilisateur
    // bascule sur « apporteur externe » sans avoir saisi de commission.
    if (widget.source == ReservationManuelleSource.apporteurExterne &&
        old.source != ReservationManuelleSource.apporteurExterne &&
        _commissionCtrl.text.isEmpty &&
        widget.totalClient > 0) {
      final suggestion = (widget.totalClient * 0.10).round();
      _commissionCtrl.text = FcfaFormatter.groupThousands(suggestion);
      widget.onCommissionChange(suggestion.toDouble());
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _apporteurNomCtrl.dispose();
    _apporteurTelCtrl.dispose();
    _commissionCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isApporteur =
        widget.source == ReservationManuelleSource.apporteurExterne;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations du client', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Pour le contacter et émettre la facture.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        InputField(
          controller: _nomCtrl,
          eyebrow: 'NOM COMPLET',
          hintText: 'ex. Madame Touré',
          onChanged: widget.onNomChange,
          errorText: widget.errors['nom'],
        ),
        const SizedBox(height: 14),
        PhoneInputField(
          controller: _telCtrl,
          eyebrow: 'TÉLÉPHONE',
          initialValue: widget.initialTel,
          errorText: widget.errors['telephone'],
          onChanged: widget.onTelChange,
        ),
        const SizedBox(height: 18),
        Text(
          'SOURCE DE LA RÉSERVATION',
          style: AppTextStyles.eyebrow,
        ),
        const SizedBox(height: 8),
        SourcePicker(
          value: widget.source,
          onChanged: widget.onSourceChange,
        ),
        if (widget.errors['source'] != null) ...[
          const SizedBox(height: 6),
          Text(widget.errors['source']!,
              style: AppTextStyles.small
                  .copyWith(fontSize: 12, color: AppColors.danger)),
        ],
        if (isApporteur) ...[
          const SizedBox(height: 14),
          InputField(
            controller: _apporteurNomCtrl,
            eyebrow: "NOM DE L'APPORTEUR",
            hintText: 'ex. Mamadou Cissé',
            onChanged: widget.onApporteurNomChange,
            errorText: widget.errors['apporteurNom'],
          ),
          const SizedBox(height: 14),
          PhoneInputField(
            controller: _apporteurTelCtrl,
            eyebrow: 'TÉLÉPHONE (OPTIONNEL)',
            initialValue: widget.initialApporteurTel,
            onChanged: widget.onApporteurTelChange,
          ),
          const SizedBox(height: 14),
          NumberInputField(
            controller: _commissionCtrl,
            eyebrow: 'COMMISSION DUE',
            hintText: FcfaFormatter.groupThousands(
                (widget.totalClient * 0.10).round()),
            formatThousands: true,
            suffix: 'FCFA',
            useMonoStyle: true,
            onChanged: (v) => widget.onCommissionChange(v?.toDouble()),
          ),
        ],
        const SizedBox(height: 18),
        Text('MODE DE PAIEMENT', style: AppTextStyles.eyebrow),
        const SizedBox(height: 8),
        PaymentMethodChips(
          value: widget.moyenPaiement,
          onSelect: widget.onPaiementChange,
        ),
        if (widget.errors['moyenPaiement'] != null) ...[
          const SizedBox(height: 6),
          Text(widget.errors['moyenPaiement']!,
              style: AppTextStyles.small
                  .copyWith(fontSize: 12, color: AppColors.danger)),
        ],
        const SizedBox(height: 18),
        ReservationRecapCard(
          nbNuits: widget.nbNuits,
          prixNuit: widget.prixNuit,
          totalClient: widget.totalClient,
          totalRecuProprio: widget.totalRecuProprio,
        ),
      ],
    );
  }
}
