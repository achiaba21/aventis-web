import 'package:asfar/model/ui_only/accepted_referral_card_payload.dart';
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/model/ui_only/reservation_card_payload.dart';
import 'package:asfar/screen/client/locataire/home/sample_listings.dart';

/// Données mock des threads de conversation — 3 threads riches alignés sur
/// le proto `extras.jsx::MessagingThread` (lignes 159-188) + threads vides
/// pour les autres conversations.
///
/// Le `MessagingThreadScreen` appelle [forConversation] avec l'`id` de la
/// conversation cliquée. Si l'id n'a pas de thread mock, retourne une liste
/// vide → l'écran affichera un placeholder « Démarrez la conversation… ».
class SampleThreads {
  SampleThreads._();

  /// Thread riche locataire — conversation L1 avec Aminata K. (Hôte certifié).
  static final List<ChatMessage> _l1 = [
    const ChatMessage(
      id: 'l1-1',
      sender: MessageSender.them,
      text: 'Bonjour Aïcha 👋 ! Bienvenue à Abidjan !',
      time: '14:00',
    ),
    const ChatMessage(
      id: 'l1-2',
      sender: MessageSender.them,
      text: 'Voici les infos pour votre arrivée demain :',
      time: '14:00',
    ),
    ChatMessage(
      id: 'l1-3',
      sender: MessageSender.them,
      time: '14:01',
      kind: MessageKind.reservationCard,
      reservation: ReservationCardPayload(
        listing: SampleListings.all[0], // Loft Plateau
        dates: '12-15 nov · 3 nuits',
        bookingCode: 'ASF-7K2N9',
      ),
    ),
    const ChatMessage(
      id: 'l1-4',
      sender: MessageSender.me,
      text: 'Super merci ! On arrivera vers 18h',
      time: '14:25',
    ),
    const ChatMessage(
      id: 'l1-5',
      sender: MessageSender.them,
      text:
          'Parfait, je serai là pour vous accueillir. Le code wifi est ASFAR2025 et le digicode du portail est 4892.',
      time: '14:32',
    ),
  ];

  /// Thread propriétaire — conversation P1 avec Rachid B. (Locataire).
  static const List<ChatMessage> _p1 = [
    ChatMessage(
      id: 'p1-1',
      sender: MessageSender.them,
      text: "Bonjour, j'arrive demain",
      time: '13:30',
    ),
    ChatMessage(
      id: 'p1-2',
      sender: MessageSender.me,
      text: 'Bienvenue Rachid !',
      time: '14:00',
    ),
    ChatMessage(
      id: 'p1-3',
      sender: MessageSender.them,
      text: 'À quelle heure puis-je arriver ?',
      time: '14:32',
    ),
    ChatMessage(
      id: 'p1-4',
      sender: MessageSender.them,
      text: "Je suis à l'aéroport vers 17h",
      time: '14:32',
    ),
  ];

  /// Thread démarcheur — conversation D1 avec Aminata K. (Hôte certifié).
  static const List<ChatMessage> _d1 = [
    ChatMessage(
      id: 'd1-1',
      sender: MessageSender.me,
      text: "Bonsoir Aminata ! J'ai un client pour le Loft, 3 nuits du 22 au 25 nov",
      time: '13:15',
    ),
    ChatMessage(
      id: 'd1-2',
      sender: MessageSender.them,
      text: 'Salut Diallo. Le client a déjà fait un séjour avec toi ?',
      time: '13:40',
    ),
    ChatMessage(
      id: 'd1-3',
      sender: MessageSender.me,
      text: "Oui, c'est Rachid, il est très sérieux",
      time: '13:45',
    ),
    ChatMessage(
      id: 'd1-4',
      sender: MessageSender.them,
      text: "OK parfait, j'accepte la demande",
      time: '14:00',
    ),
    ChatMessage(
      id: 'd1-5',
      sender: MessageSender.them,
      time: '14:00',
      kind: MessageKind.acceptedReferralCard,
      acceptedReferral: AcceptedReferralCardPayload(
        referralCode: 'REF-D8H3K',
        contextLabel: 'Loft Plateau · 22-25 nov',
        commission: 13500,
      ),
    ),
  ];

  /// Retourne le thread mock pour une conversation donnée.
  /// Liste vide si la conversation n'a pas de thread défini.
  static List<ChatMessage> forConversation(String conversationId) {
    switch (conversationId) {
      case 'L1':
        return _l1;
      case 'P1':
        return _p1;
      case 'D1':
        return _d1;
      default:
        return const [];
    }
  }
}
