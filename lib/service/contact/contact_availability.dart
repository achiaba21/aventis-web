import 'package:asfar/model/contact/contact.dart';

/// Disponibilité des 3 actions de contact (Chat / WhatsApp / Appeler) pour
/// un [Contact] donné, vue selon le rôle du viewer et le statut métier.
///
/// Encapsule la règle métier :
/// - Côté **démarcheur** : actions toujours actives (statut ignoré).
/// - Côté **propriétaire / locataire** : si le statut est terminal
///   (annulée, refusée, expirée), tout est désactivé.
///
/// Source : `business-spec.md` §4.3.
class ContactAvailability {
  final bool callEnabled;
  final bool whatsAppEnabled;
  final bool chatEnabled;

  const ContactAvailability({
    required this.callEnabled,
    required this.whatsAppEnabled,
    required this.chatEnabled,
  });

  /// Aucune option dispo (utilisé pour grisé global).
  const ContactAvailability.allDisabled()
      : callEnabled = false,
        whatsAppEnabled = false,
        chatEnabled = false;

  /// `true` si au moins une option est activable — le bouton "Contacter"
  /// n'est globalement grisé que si **les 3** options sont indisponibles.
  bool get contactButtonEnabled =>
      callEnabled || whatsAppEnabled || chatEnabled;

  /// Calcule la disponibilité selon le contact, le statut et le rôle du viewer.
  ///
  /// - [isDemarcheurViewer] `true` → on ignore [isTerminalStatus] (le démarcheur
  ///   peut toujours relancer).
  /// - Sinon, si [isTerminalStatus] `true` → tout est désactivé.
  /// - Sinon → disponibilité dérivée des getters de [Contact] (`hasPhone`,
  ///   `hasWhatsApp`, `canChat`).
  factory ContactAvailability.from({
    required Contact contact,
    required bool isTerminalStatus,
    required bool isDemarcheurViewer,
  }) {
    if (isTerminalStatus && !isDemarcheurViewer) {
      return const ContactAvailability.allDisabled();
    }
    return ContactAvailability(
      callEnabled: contact.hasPhone,
      whatsAppEnabled: contact.hasWhatsApp,
      chatEnabled: contact.canChat,
    );
  }
}
