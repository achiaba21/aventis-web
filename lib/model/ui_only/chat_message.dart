import 'package:asfar/model/ui_only/accepted_partenariat_card_payload.dart';
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

  /// Card spéciale « Demande de partenariat acceptée » — V9.2 (renommé
  /// depuis `acceptedReferralCard` pour aligner sur le nommage backend
  /// `partenariat`).
  acceptedPartenariatCard,
}

/// Message du `MessagingThreadScreen`.
///
/// V9.2 : les payloads sont désormais minimaux (juste référence/id) et le
/// détail est récupéré lazy au mount des widgets cards.
class ChatMessage {
  final String id;
  final MessageSender sender;
  final String? text;
  final String time;
  final MessageKind kind;
  final ReservationCardPayload? reservation;
  final AcceptedPartenariatCardPayload? acceptedPartenariat;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.time,
    this.text,
    this.kind = MessageKind.text,
    this.reservation,
    this.acceptedPartenariat,
  });

  bool get isMe => sender == MessageSender.me;
}
