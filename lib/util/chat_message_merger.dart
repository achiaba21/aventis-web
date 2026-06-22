import 'package:asfar/model/conversation/chat_message.dart';

/// Point de convergence idempotent pour insérer un message dans le fil d'une
/// conversation.
///
/// Plusieurs canaux temps réel (topic `/topic/seance/{id}`, file perso
/// `/user/queue/*`, handler global) peuvent livrer le MÊME message, et l'UI
/// affiche déjà une bulle optimiste avant la réponse HTTP. Sans réconciliation,
/// l'écho du serveur s'ajoute en double. [upsert] garantit qu'un message
/// n'apparaît qu'une seule fois, quel que soit l'ordre ou le nombre de
/// livraisons.
///
/// Toutes les méthodes sont statiques et pures : elles retournent une nouvelle
/// liste sans altérer l'entrée.
class ChatMessageMerger {
  ChatMessageMerger._(); // Empêche l'instanciation

  /// Insère ou met à jour [incoming] dans [current] sans jamais créer de
  /// doublon. Retourne une nouvelle liste (l'originale n'est pas modifiée).
  ///
  /// Ordre de résolution :
  /// 1. [tempId] fourni et trouvé → confirmation d'envoi : on remplace le
  ///    message optimiste, puis on supprime tout doublon de même `id` qu'un
  ///    écho aurait déjà inséré (course écho-avant-HTTP) ;
  /// 2. `incoming.id` déjà présent → mise à jour en place (idempotence : un
  ///    même écho livré N fois n'ajoute rien) ;
  /// 3. écho de notre propre message encore « en envoi » (même expéditeur +
  ///    même contenu, pas encore d'`id`) → on réconcilie l'optimiste au lieu
  ///    d'ajouter une 2ᵉ bulle (course écho-avant-HTTP, sans tempId connu) ;
  /// 4. sinon → message réellement nouveau : on l'ajoute.
  static List<ChatMessage> upsert(
    List<ChatMessage> current,
    ChatMessage incoming, {
    String? tempId,
  }) {
    final messages = List<ChatMessage>.of(current);

    // 1. Confirmation d'envoi par tempId.
    if (tempId != null) {
      final index = messages.indexWhere((m) => m.tempId == tempId);
      if (index != -1) {
        messages[index] = incoming;
        return _withoutDuplicateId(messages, keep: index);
      }
      // tempId introuvable : l'écho a déjà réconcilié l'optimiste → on retombe
      // sur la fusion par id ci-dessous.
    }

    // 2. Déjà présent par id serveur → mise à jour en place.
    if (incoming.id != null) {
      final index = messages.indexWhere((m) => m.id == incoming.id);
      if (index != -1) {
        messages[index] = incoming;
        return messages;
      }
    }

    // 3. Écho de notre propre message optimiste encore en envoi.
    final pendingIndex = messages.indexWhere(
      (m) =>
          m.isSending == true &&
          m.id == null &&
          m.contenu == incoming.contenu &&
          m.expediteur?.id != null &&
          m.expediteur?.id == incoming.expediteur?.id,
    );
    if (pendingIndex != -1) {
      messages[pendingIndex] = incoming;
      return messages;
    }

    // 4. Nouveau message.
    messages.add(incoming);
    return messages;
  }

  /// Supprime tout message partageant l'`id` de `messages[keep]`, sauf
  /// l'élément `keep` lui-même. No-op si ce message n'a pas encore d'`id`.
  static List<ChatMessage> _withoutDuplicateId(
    List<ChatMessage> messages, {
    required int keep,
  }) {
    final id = messages[keep].id;
    if (id == null) return messages;
    return [
      for (var i = 0; i < messages.length; i++)
        if (i == keep || messages[i].id != id) messages[i],
    ];
  }
}
