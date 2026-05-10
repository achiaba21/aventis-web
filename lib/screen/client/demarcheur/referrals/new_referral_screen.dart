import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/referrals/widget/referral_listing_radio.dart';
import 'package:asfar/screen/client/demarcheur/sample/sample_listings_to_referral.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/feedback/info_banner.dart';
import 'package:asfar/widget/feedback/success_circle.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Tunnel « Nouvelle demande » du Démarcheur — 3 étapes.
///
/// Reproduit `DemarcheurNew` du prototype (single screen avec `_step`,
/// pattern Vague 5 `LocataireReserveScreen`).
///
/// Étape 1 : choix du logement (search + cards radio).
/// Étape 2 : infos client (Nom, Tel WhatsApp, Dates, Note libre + banner
/// commission estimée).
/// Étape 3 : confirmation (Cercle accent + REF + récap).
class NewReferralScreen extends StatefulWidget {
  const NewReferralScreen({super.key});

  @override
  State<NewReferralScreen> createState() => _NewReferralScreenState();
}

class _NewReferralScreenState extends State<NewReferralScreen> {
  int _step = 1;
  ListingPreview? _selectedListing;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _arrivalCtrl = TextEditingController(text: '12 nov.');
  final _departureCtrl = TextEditingController(text: '15 nov.');
  final _noteCtrl = TextEditingController();

  static const _generatedRef = 'REF-D8H3K';

  String get _stepTitle {
    switch (_step) {
      case 1:
        return 'Choisir un logement';
      case 2:
        return 'Infos du client';
      case 3:
        return 'Demande envoyée';
    }
    return '';
  }

  int get _commissionEstimate {
    final l = _selectedListing;
    if (l == null) return 0;
    return SampleListingsToReferral.commissionFor(l);
  }

  bool get _step1Valid => _selectedListing != null;
  bool get _step2Valid =>
      _nameCtrl.text.trim().isNotEmpty && _phoneCtrl.text.trim().isNotEmpty;

  void _goToStep(int next) => setState(() => _step = next);

  void _onLeading() {
    if (_step > 1 && _step < 3) {
      _goToStep(_step - 1);
    } else {
      back(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _arrivalCtrl.dispose();
    _departureCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: _stepTitle,
        eyebrow: _step <= 3 ? 'ÉTAPE $_step / 3' : null,
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: _onLeading,
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _stepContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> _stepContent() {
    switch (_step) {
      case 1:
        return _step1();
      case 2:
        return _step2();
      case 3:
        return _step3();
    }
    return const [];
  }

  List<Widget> _step1() {
    final listings = SampleListingsToReferral.listings;
    return [
      const InputField(
        leadingIcon: Icons.search,
        hintText: 'Rechercher un logement…',
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < listings.length; i++) ...[
        ReferralListingRadio(
          listing: listings[i],
          estimatedCommission:
              SampleListingsToReferral.commissionFor(listings[i]),
          selected: _selectedListing?.id == listings[i].id,
          onTap: () => setState(() => _selectedListing = listings[i]),
        ),
        const SizedBox(height: 12),
      ],
      const SizedBox(height: 12),
      CustomButton(
        text: 'Suivant',
        onPressed: _step1Valid ? () => _goToStep(2) : null,
        size: ButtonSize.lg,
        block: true,
      ),
    ];
  }

  List<Widget> _step2() {
    return [
      InputField(
        controller: _nameCtrl,
        eyebrow: 'NOM DU CLIENT',
        hintText: 'Mariam D.',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      InputField(
        controller: _phoneCtrl,
        eyebrow: 'TÉLÉPHONE WHATSAPP',
        hintText: '+225 07 88 12 34',
        keyboardType: TextInputType.phone,
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: InputField(
              controller: _arrivalCtrl,
              eyebrow: 'ARRIVÉE',
              readOnly: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InputField(
              controller: _departureCtrl,
              eyebrow: 'DÉPART',
              readOnly: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      InputField(
        controller: _noteCtrl,
        eyebrow: 'NOTE (FACULTATIF)',
        hintText: 'Préférences, contexte…',
        maxLines: 3,
      ),
      const SizedBox(height: 18),
      InfoBanner(
        icon: Icons.payments_outlined,
        title:
            'Commission estimée ${FcfaFormatter.full(_commissionEstimate)}',
        body: '10 % du séjour · versée après paiement client.',
      ),
      const SizedBox(height: 22),
      CustomButton(
        text: 'Envoyer la demande',
        onPressed: _step2Valid ? () => _goToStep(3) : null,
        size: ButtonSize.lg,
        block: true,
      ),
    ];
  }

  List<Widget> _step3() {
    final l = _selectedListing!;
    return [
      const SizedBox(height: 24),
      const Center(child: SuccessCircle(icon: Icons.send)),
      const SizedBox(height: 24),
      const Center(
        child: Text(
          'Demande envoyée !',
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          'Le propriétaire va vérifier la demande et vous tenir informé.',
          style: AppTextStyles.body,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgElev1,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        child: Column(
          children: [
            _recapLine('Référence', _generatedRef, mono: true),
            const SizedBox(height: 10),
            _recapLine('Logement', l.title),
            const SizedBox(height: 10),
            _recapLine('Client', _nameCtrl.text.trim()),
            const SizedBox(height: 14),
            const Divider(color: AppColors.line, height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Commission estimée',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    )),
                Text(
                  FcfaFormatter.full(_commissionEstimate),
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      CustomButton(
        text: 'Voir mes demandes',
        onPressed: () => back(context),
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

  Widget _recapLine(String label, String value, {bool mono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.small),
        Text(
          value,
          style: mono
              ? AppTextStyles.mono(const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ))
              : const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
        ),
      ],
    );
  }
}
