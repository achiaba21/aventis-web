import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/locataire/booking/widget/booking_code_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/booking_recap_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/listing_summary_card.dart';
import 'package:asfar/screen/client/locataire/booking/widget/price_detail_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/feedback/info_banner.dart';
import 'package:asfar/widget/feedback/success_circle.dart';
import 'package:asfar/widget/item/field_row.dart';
import 'package:asfar/widget/list/payment_method_tile.dart';

/// Tunnel de réservation Locataire — 3 étapes.
///
/// Reproduit `LocataireReserve` du proto :
/// 1. **Confirmer** — résumé séjour, détail prix, info annulation.
/// 2. **Paiement** — choix méthode mobile money + total + CTA.
/// 3. **Confirmation** — succès animé, code de réservation, récap.
class LocataireReserveScreen extends StatefulWidget {
  final Appartement appartement;
  final int nights;

  const LocataireReserveScreen({
    super.key,
    required this.appartement,
    this.nights = 3,
  });

  @override
  State<LocataireReserveScreen> createState() => _LocataireReserveScreenState();
}

class _LocataireReserveScreenState extends State<LocataireReserveScreen> {
  int _step = 1;
  String _payMethod = 'om';

  static const _bookingCode = 'ASF-7K2N9';

  int get _subtotal => widget.appartement.priceAmount * widget.nights;
  int get _fees => (_subtotal * 0.08).round();
  int get _total => _subtotal + _fees;

  String get _stepTitle {
    switch (_step) {
      case 1:
        return 'Confirmer la réservation';
      case 2:
        return 'Paiement';
      case 3:
        return 'Confirmation';
    }
    return '';
  }

  void _goToStep(int next) => setState(() => _step = next);

  void _onConfirm() {
    back(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: _stepTitle,
        eyebrow: 'ÉTAPE $_step / 3',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => _step > 1 ? _goToStep(_step - 1) : back(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step != 3) ...[
                ListingSummaryCard(appartement: widget.appartement),
                const SizedBox(height: 16),
              ],
              if (_step == 1) ..._step1Content(),
              if (_step == 2) ..._step2Content(),
              if (_step == 3) ..._step3Content(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _step1Content() => [
        const Text('Votre séjour', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const FieldRow(
                eyebrow: 'DATES',
                value: '12 - 15 nov. 2025',
                trailingIcon: null,
              ),
              const FieldRow(
                eyebrow: 'VOYAGEURS',
                value: '2 adultes',
                trailingIcon: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('Détail du prix', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        PriceDetailCard(
          lines: [
            PriceLine(
              label:
                  '${FcfaFormatter.compact(widget.appartement.priceAmount)} × ${widget.nights} nuits',
              amount: _subtotal,
            ),
            PriceLine(label: 'Frais de service', amount: _fees),
          ],
          total: _total,
        ),
        const SizedBox(height: 18),
        const InfoBanner(
          icon: Icons.shield_outlined,
          title: 'Annulation flexible',
          body:
              "Annulez gratuitement jusqu'au 10 nov. à 14 h. Après, remboursement partiel.",
        ),
        const SizedBox(height: 22),
        CustomButton(
          text: 'Continuer vers le paiement',
          onPressed: () => _goToStep(2),
          size: ButtonSize.lg,
          block: true,
        ),
      ];

  List<Widget> _step2Content() => [
        const Text('Méthode de paiement', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              PaymentMethodTile(
                name: 'Orange Money',
                subtitle: '•••• 8742',
                brandColor: AppColors.orangeMoney,
                initials: 'OM',
                selected: _payMethod == 'om',
                onTap: () => setState(() => _payMethod = 'om'),
              ),
              PaymentMethodTile(
                name: 'Wave',
                subtitle: '+225 07 ••• 4521',
                brandColor: AppColors.wave,
                initials: 'W',
                selected: _payMethod == 'wave',
                onTap: () => setState(() => _payMethod = 'wave'),
              ),
              PaymentMethodTile(
                name: 'MTN MoMo',
                subtitle: '•••• 2189',
                brandColor: AppColors.mtnMomo,
                initials: 'MM',
                selected: _payMethod == 'mtn',
                onTap: () => setState(() => _payMethod = 'mtn'),
              ),
              PaymentMethodTile(
                name: 'Carte bancaire',
                subtitle: 'Ajouter une carte',
                brandColor: AppColors.cardPay,
                initials: 'CB',
                selected: _payMethod == 'card',
                onTap: () => setState(() => _payMethod = 'card'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total à payer',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                FcfaFormatter.full(_total),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        CustomButton(
          text: 'Payer ${FcfaFormatter.compact(_total)}',
          onPressed: () => _goToStep(3),
          size: ButtonSize.lg,
          block: true,
        ),
      ];

  List<Widget> _step3Content() => [
        const SizedBox(height: 20),
        const Center(child: SuccessCircle(icon: Icons.check)),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Réservation confirmée !',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Votre paiement a été reçu. Aminata a été prévenue.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        const BookingCodeCard(code: _bookingCode),
        const SizedBox(height: 16),
        BookingRecapCard(
          lines: [
            RecapLine(label: 'Logement', value: widget.appartement.titleSafe),
            const RecapLine(label: 'Dates', value: '12 - 15 nov'),
            RecapLine(
              label: 'Total payé',
              value: FcfaFormatter.full(_total),
              mono: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Voir mes réservations',
          onPressed: _onConfirm,
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
