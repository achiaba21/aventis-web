import 'package:asfar/model/ui_only/referral_preview.dart';

/// Payload d'un message `MessageKind.acceptedReferralCard` — Card
/// « Demande acceptée » dans le `MessagingThreadScreen` (côté démarcheur).
///
/// Reproduit le mock du proto `extras.jsx::MessagingThread` (lignes 233-246) :
/// fond accentSoft + icon check + label « Demande acceptée » + référence +
/// commission accent or.
///
/// V8.3 : ajout du champ optionnel [referral] (`ReferralPreview` complet).
/// Quand renseigné, le tap sur la card pousse `ReferralDetailScreen` côté
/// démarcheur. Sinon, fallback SnackBar informatif. Le mapper actuel
/// (`ChatMessageToUiMapper`) ne renseigne pas encore ce champ — il sera
/// enrichi quand le backend émettra les `[ASFAR_CARD:referral]` avec les
/// données complètes (id, clientName, listing, etc.).
class AcceptedReferralCardPayload {
  final String referralCode;
  final String contextLabel;
  final int commission;
  final ReferralPreview? referral;

  const AcceptedReferralCardPayload({
    required this.referralCode,
    required this.contextLabel,
    required this.commission,
    this.referral,
  });
}
