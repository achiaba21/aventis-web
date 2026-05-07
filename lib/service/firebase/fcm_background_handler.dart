import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handler pour les messages FCM reçus en arrière-plan ou quand l'app est fermée.
///
/// IMPORTANT: Cette fonction doit être top-level (en dehors de toute classe)
/// car elle est appelée dans un isolate séparé.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialiser Firebase si nécessaire (l'isolate n'a pas accès à l'état de l'app)
  await Firebase.initializeApp();

  debugPrint('[FCM Background] Message reçu: ${message.messageId}');
  debugPrint('[FCM Background] Titre: ${message.notification?.title}');
  debugPrint('[FCM Background] Body: ${message.notification?.body}');
  debugPrint('[FCM Background] Data: ${message.data}');

  // Note: Les notifications avec 'notification' payload sont automatiquement
  // affichées par le système. Ce handler est appelé pour le traitement
  // additionnel si nécessaire.

  // Ici on pourrait:
  // - Sauvegarder la notification localement
  // - Mettre à jour un badge
  // - Déclencher une synchronisation

  // ATTENTION: Dans ce contexte background, on a des limitations:
  // - Pas d'accès au contexte Flutter
  // - Pas d'accès aux BLoCs
  // - Temps d'exécution limité
}
