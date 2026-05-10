import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Mapping `ConversationRole` → libellé texte + ton de [BadgeStatus].
///
/// Source : proto `extras.jsx::MessagingList` (lignes 126-127) :
///   `c.role === "Démarcheur" ? "info" : c.role === "Asfar" ? "neutral" : "accent"`
///
/// Helper dédié pour respecter la règle 3 du projet (helpers dédiés) — évite
/// la dispersion de la logique dans `ConversationRow`, `MessagingThreadScreen`,
/// etc.
class ConversationRoleDisplay {
  ConversationRoleDisplay._();

  static String labelOf(ConversationRole role) {
    switch (role) {
      case ConversationRole.host:
        return 'Hôte';
      case ConversationRole.tenant:
        return 'Locataire';
      case ConversationRole.demarcheur:
        return 'Démarcheur';
      case ConversationRole.asfar:
        return 'Asfar';
      case ConversationRole.client:
        return 'Client';
    }
  }

  static BadgeTone toneOf(ConversationRole role) {
    switch (role) {
      case ConversationRole.demarcheur:
        return BadgeTone.info;
      case ConversationRole.asfar:
        return BadgeTone.neutral;
      case ConversationRole.host:
      case ConversationRole.tenant:
      case ConversationRole.client:
        return BadgeTone.accent;
    }
  }
}
