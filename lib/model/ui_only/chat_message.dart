import 'package:asfar/model/ui_only/accepted_referral_card_payload.dart';
import 'package:asfar/model/ui_only/reservation_card_payload.dart';

/// Origine d'un message dans le `MessagingThreadScreen`.
enum MessageSender {
  /// Message envoyé par l'utilisateur courant (bubble accent or à droite).
  me,

  /// Message reçu de l'interlocuteur (bubble bgElev2 à gauche).
  them,
}

/// Type d'un message — détermine le rendu visuel.
enum MessageKind {
  /// Bubble texte standard.
  text,

  /// Card spéciale « Réservation » (proto `extras.jsx:223-232`).
  reservationCard,

  /// Card spéciale « Demande acceptée » (proto `extras.jsx:233-246`).
  acceptedReferralCard,
}

/// Message du `MessagingThreadScreen`.
///
/// Reproduit les entrées `messages` du proto `extras.jsx::MessagingThread`
/// (lignes 162-188). Selon `kind`, soit `text` est rempli, soit le payload
/// correspondant (`reservation` ou `acceptedReferral`).
class ChatMessage {
  final String id;
  final MessageSender sender;
  final String? text;
  final String time;
  final MessageKind kind;
  final ReservationCardPayload? reservation;
  final AcceptedReferralCardPayload? acceptedReferral;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.time,
    this.text,
    this.kind = MessageKind.text,
    this.reservation,
    this.acceptedReferral,
  });

  bool get isMe => sender == MessageSender.me;
}
