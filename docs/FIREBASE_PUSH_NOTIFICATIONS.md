# Notifications Push Firebase (FCM)

Documentation pour l'intégration des notifications push Firebase Cloud Messaging dans l'application Asfar.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     NotificationBloc                     │
│  (Gestionnaire unifié des notifications)                │
├─────────────────────────────────────────────────────────┤
│                          ↑                              │
│            ┌─────────────┼─────────────┐                │
│            │             │             │                │
│     WebSocketService  FCMService  NotificationService   │
│     (temps réel)     (background)     (API REST)        │
│                          │                              │
│                          ↓                              │
│              Firebase Cloud Messaging                   │
└─────────────────────────────────────────────────────────┘
```

- **WebSocket** : Notifications temps réel quand l'app est ouverte
- **FCM** : Notifications push quand l'app est en arrière-plan ou fermée
- **API REST** : Synchronisation et gestion des notifications

---

## Étapes restantes à effectuer

### 1. Créer le projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Cliquer **"Ajouter un projet"**
3. Nommer le projet (ex: `asfar-app`)
4. Désactiver Google Analytics (optionnel)
5. Cliquer **"Créer le projet"**

### 2. Enregistrer l'application Android

1. Firebase Console → **Paramètres projet** → **Ajouter une application** → **Android**
2. Package name : `com.seven.asfar` (ou votre vrai package)
3. Surnom : `Asfar Android`
4. Télécharger `google-services.json`
5. **Placer le fichier dans** : `android/app/google-services.json`

### 3. Enregistrer l'application iOS

1. Firebase Console → **Paramètres projet** → **Ajouter une application** → **iOS**
2. Bundle ID : celui dans Xcode (ex: `com.seven.asfar`)
3. Télécharger `GoogleService-Info.plist`
4. **Placer le fichier dans** : `ios/Runner/GoogleService-Info.plist`
5. **Dans Xcode** :
   - Ouvrir `ios/Runner.xcworkspace`
   - Clic droit sur Runner → **Add Files to "Runner"**
   - Sélectionner `GoogleService-Info.plist`
   - Cocher "Copy items if needed"

### 4. Configurer APNs pour iOS

1. [Apple Developer](https://developer.apple.com) → **Certificates, Identifiers & Profiles**
2. **Keys** → Créer une nouvelle clé APNs
3. Télécharger le fichier `.p8`
4. Firebase Console → **Paramètres projet** → **Cloud Messaging** → **Certificats iOS**
5. Uploader la clé APNs (.p8) avec le Key ID et Team ID

### 5. Activer les capabilities iOS dans Xcode

1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Sélectionner **Runner** → **Signing & Capabilities**
3. Cliquer **+ Capability** et ajouter :
   - **Push Notifications**
   - **Background Modes** → cocher "Remote notifications"

### 6. Développer les endpoints backend

Le backend doit implémenter ces endpoints pour stocker les tokens FCM :

```
POST /api/v1/user/fcm-token
Body: { "token": "fcm_token_here" }
Response: 200 OK

DELETE /api/v1/user/fcm-token
Response: 200 OK
```

Le backend doit :
- Stocker le token FCM associé à l'utilisateur
- Utiliser ce token pour envoyer des notifications ciblées via Firebase Admin SDK

---

## Fichiers créés

| Fichier | Description |
|---------|-------------|
| `lib/service/firebase/fcm_service.dart` | Service principal FCM (gestion token, streams, handlers) |
| `lib/service/firebase/fcm_background_handler.dart` | Handler pour messages reçus en background |
| `lib/service/firebase/local_notification_service.dart` | Affichage notifications locales (foreground Android) |

## Fichiers modifiés

| Fichier | Modifications |
|---------|---------------|
| `pubspec.yaml` | Ajout firebase_core, firebase_messaging, flutter_local_notifications |
| `android/build.gradle.kts` | Ajout plugin Google Services |
| `android/app/build.gradle.kts` | Ajout plugin Google Services + multiDexEnabled |
| `android/app/src/main/AndroidManifest.xml` | Permissions POST_NOTIFICATIONS, VIBRATE + config FCM |
| `ios/Podfile` | Platform iOS 13.0 |
| `ios/Runner/Info.plist` | UIBackgroundModes (remote-notification, fetch) |
| `lib/main.dart` | Initialisation Firebase + background handler |
| `lib/bloc/notification_bloc/notification_event.dart` | Events FCM (InitializeFCM, FCMTokenReceived, DeleteFCMToken) |
| `lib/bloc/notification_bloc/notification_bloc.dart` | Handlers FCM + subscriptions aux streams |
| `lib/service/notification/notification_service.dart` | Endpoints registerFCMToken / unregisterFCMToken |
| `lib/widget/websocket/websocket_initializer.dart` | Initialisation FCM au login |

---

## Flux de données

### Connexion utilisateur
```
1. User login
2. WebSocketInitializer détecte UserLoaded
3. InitializeNotifications (WebSocket)
4. InitializeFCM
   → Demande permissions
   → Obtient token FCM
   → FCMTokenReceived
   → registerFCMToken() → Backend
```

### Notification reçue (app ouverte)
```
1. FCM message → FirebaseMessaging.onMessage
2. FCMService parse le message
3. Émet sur notificationStream
4. NotificationBloc reçoit NotificationReceived
5. Affichage notification locale (Android)
6. Mise à jour UI
```

### Notification reçue (app fermée)
```
1. FCM message → firebaseMessagingBackgroundHandler
2. Notification système affichée automatiquement
3. User tap → App s'ouvre
4. FirebaseMessaging.onMessageOpenedApp
5. Sync avec API
```

### Déconnexion utilisateur
```
1. User logout
2. DeleteFCMToken
   → unregisterFCMToken() → Backend
   → FCMService.deleteToken()
3. DisconnectWebSocket
```

---

## Tester les notifications

### Via Firebase Console

1. Firebase Console → **Cloud Messaging**
2. Cliquer **"Envoyer votre premier message"**
3. Remplir :
   - Titre : `Test notification`
   - Texte : `Ceci est un test`
4. Cliquer **"Envoyer un message test"**
5. Entrer le token FCM (visible dans les logs de l'app)
6. Envoyer

### Via cURL (avec Firebase Admin)

```bash
curl -X POST \
  https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "FCM_TOKEN_HERE",
      "notification": {
        "title": "Test",
        "body": "Message de test"
      },
      "data": {
        "event": "NOTIFICATION",
        "id": "123"
      }
    }
  }'
```

### Logs utiles

Filtrer les logs avec :
```
[FCMService]
[LocalNotificationService]
[FCM Background]
```

---

## Format des messages FCM

### Notification simple (affichage automatique)
```json
{
  "notification": {
    "title": "Nouvelle réservation",
    "body": "Vous avez une nouvelle demande de réservation"
  }
}
```

### Data message (traitement custom)
```json
{
  "data": {
    "notification": "{\"id\":123,\"titre\":\"...\",\"contenu\":\"...\",\"event\":\"RESERVATION\"}",
    "event": "RESERVATION",
    "actionData": "{\"reservationId\":456}"
  }
}
```

### Message combiné (recommandé)
```json
{
  "notification": {
    "title": "Nouvelle réservation",
    "body": "Appartement Cocody - 3 nuits"
  },
  "data": {
    "event": "RESERVATION",
    "id": "123",
    "actionData": "{\"reservationId\":456}"
  }
}
```

---

## Dépannage

### Le token FCM n'est pas généré
- Vérifier que `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS) est présent
- Vérifier que Firebase est bien initialisé dans `main.dart`
- Sur iOS, vérifier les capabilities Push Notifications

### Notifications non reçues en background (iOS)
- Vérifier que UIBackgroundModes contient `remote-notification`
- Vérifier la configuration APNs dans Firebase Console
- Tester sur un vrai appareil (pas simulateur)

### Notifications non affichées en foreground (Android)
- Vérifier que le canal `high_importance_channel` est créé
- Vérifier les permissions POST_NOTIFICATIONS (Android 13+)

### Erreur "No Firebase App"
- S'assurer que `Firebase.initializeApp()` est appelé AVANT tout autre code Firebase
- Vérifier que les fichiers de config sont au bon endroit

---

## Ressources

- [Firebase Cloud Messaging - Flutter](https://firebase.flutter.dev/docs/messaging/overview)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Console](https://console.firebase.google.com)
- [Apple Developer - APNs](https://developer.apple.com/documentation/usernotifications)
