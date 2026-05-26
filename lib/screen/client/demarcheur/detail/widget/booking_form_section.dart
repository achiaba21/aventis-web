import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/feedback/info_banner.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/number_input_field.dart';
import 'package:asfar/widget/input/phone_input_field.dart';

/// Section formulaire « Réserver pour mon client » du
/// [DemarcheurAppartDetailScreen] — bloc inline placé sous le calendrier.
///
/// Reçoit l'état déjà calculé (dates sélectionnées, prix suggéré, commission).
/// Délègue toutes les saisies au parent via les controllers + callbacks.
class BookingFormSection extends StatelessWidget {
  final TextEditingController nomCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController prixCtrl;
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final int nights;
  final int suggestedPrice;
  final int commission;
  final VoidCallback onAnyChange;
  final void Function(String) onPriceChanged;
  final void Function(String fullPhone) onPhoneChanged;
  final bool canSubmit;
  final bool submitting;
  final VoidCallback onSubmit;

  const BookingFormSection({
    super.key,
    required this.nomCtrl,
    required this.phoneCtrl,
    required this.prixCtrl,
    required this.selectedStart,
    required this.selectedEnd,
    required this.nights,
    required this.suggestedPrice,
    required this.commission,
    required this.onAnyChange,
    required this.onPriceChanged,
    required this.onPhoneChanged,
    required this.canSubmit,
    required this.submitting,
    required this.onSubmit,
  });

  static const _monthsShort = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day} ${_monthsShort[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateRangeRecap(
          start: selectedStart,
          end: selectedEnd,
          nights: nights,
          formatter: _formatDate,
        ),
        const SizedBox(height: 18),
        const Text('Infos client', style: AppTextStyles.h3),
        const SizedBox(height: 10),
        InputField(
          controller: nomCtrl,
          eyebrow: 'NOM DU CLIENT',
          hintText: 'ex. Mariam D.',
          onChanged: (_) => onAnyChange(),
        ),
        const SizedBox(height: 14),
        PhoneInputField(
          controller: phoneCtrl,
          eyebrow: 'TÉLÉPHONE WHATSAPP',
          onChanged: (full) {
            onPhoneChanged(full);
            onAnyChange();
          },
        ),
        const SizedBox(height: 18),
        const Text('Prix négocié', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text(
          nights > 0
              ? 'Suggestion : ${FcfaFormatter.full(suggestedPrice)} pour $nights nuit${nights > 1 ? 's' : ''}'
              : 'Sélectionnez les dates pour voir une suggestion',
          style: AppTextStyles.small.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 10),
        NumberInputField(
          controller: prixCtrl,
          eyebrow: 'PRIX TOTAL DU SÉJOUR',
          hintText: nights > 0
              ? FcfaFormatter.groupThousands(suggestedPrice)
              : '75 000',
          formatThousands: true,
          suffix: 'FCFA',
          useMonoStyle: true,
          onChanged: (value) {
            onPriceChanged((value ?? 0).toString());
            onAnyChange();
          },
        ),
        const SizedBox(height: 18),
        InfoBanner(
          icon: Icons.payments_outlined,
          title:
              'Commission estimée ${FcfaFormatter.full(commission)}',
          body: '10 % du prix négocié · versée après paiement client.',
        ),
        const SizedBox(height: 22),
        CustomButton(
          text: submitting ? 'Envoi…' : 'Envoyer la demande',
          onPressed: canSubmit ? onSubmit : null,
          size: ButtonSize.lg,
          block: true,
        ),
      ],
    );
  }
}

/// Récap des dates sélectionnées — affiché au-dessus du formulaire.
class _DateRangeRecap extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final int nights;
  final String Function(DateTime?) formatter;

  const _DateRangeRecap({
    required this.start,
    required this.end,
    required this.nights,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final hasRange = start != null && end != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARRIVÉE',
                  style:
                      AppTextStyles.eyebrow.copyWith(color: AppColors.text3),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter(start),
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, size: 16, color: AppColors.text3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'DÉPART',
                  style:
                      AppTextStyles.eyebrow.copyWith(color: AppColors.text3),
                ),
                const SizedBox(height: 4),
                Text(
                  formatter(end),
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (hasRange) ...[
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$nights nuit${nights > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
