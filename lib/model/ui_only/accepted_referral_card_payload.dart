/// Payload d'un message `MessageKind.acceptedReferralCard` — Card
/// « Demande acceptée » dans le `MessagingThreadScreen` (côté démarcheur).
///
/// Reproduit le mock du proto `extras.jsx::MessagingThread` (lignes 233-246) :
/// fond accentSoft + icon check + label « Demande acceptée » + référence +
/// commission accent or.
class AcceptedReferralCardPayload {
  final String referralCode;
  final String contextLabel;
  final int commission;

  const AcceptedReferralCardPayload({
    required this.referralCode,
    required this.contextLabel,
    required this.commission,
  });
}
