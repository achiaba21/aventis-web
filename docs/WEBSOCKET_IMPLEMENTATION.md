# WebSocket - Guide d'Implémentation

## Table des Matières

1. [Vue d'Ensemble](#1-vue-densemble)
2. [Architecture](#2-architecture)
3. [Flux de Connexion](#3-flux-de-connexion)
4. [Abonnements et Destinations](#4-abonnements-et-destinations)
5. [Types de Messages](#5-types-de-messages)
6. [Intégration BLoC](#6-intégration-bloc)
7. [Gestion de la Reconnexion](#7-gestion-de-la-reconnexion)
8. [Cycle de Vie](#8-cycle-de-vie)
9. [Flux de Données Complet](#9-flux-de-données-complet)
10. [Fichiers Clés](#10-fichiers-clés)

---

## 1. Vue d'Ensemble

L'application utilise **STOMP** (Simple Text Oriented Messaging Protocol) sur WebSocket pour la communication temps réel avec le serveur Spring Boot.

### Stack Technique

| Composant | Technologie |
|-----------|-------------|
| Protocole | STOMP over WebSocket |
| Librairie Flutter | `stomp_dart_client` |
| Transport | WebSocket natif (ws:// ou wss://) |
| Endpoint Serveur | `/ws/websocket` |

### Fonctionnalités

- Notifications personnelles en temps réel
- Actions broadcast à tous les clients
- Reconnexion automatique avec backoff exponentiel
- Gestion du cycle de vie de l'application

---

## 2. Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                              UI Layer                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │
│  │ NotificationList │  │  SnackBar Toast │  │  Badge Counter      │  │
│  └────────┬────────┘  └────────┬────────┘  └──────────┬──────────┘  │
└───────────┼─────────────────────┼─────────────────────┼─────────────┘
            │                     │                     │
            └─────────────────────┼─────────────────────┘
                                  │
┌─────────────────────────────────▼───────────────────────────────────┐
│                           BLoC Layer                                 │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    NotificationBloc                          │    │
│  │  - Gère l'état des notifications                            │    │
│  │  - Cache local (SharedPreferences)                          │    │
│  │  - Écoute les streams WebSocket                             │    │
│  └─────────────────────────┬───────────────────────────────────┘    │
│                            │                                         │
│  ┌─────────────────────────▼───────────────────────────────────┐    │
│  │                 RealtimeActionHandler                        │    │
│  │  - Dispatch les actions vers les BLoCs appropriés           │    │
│  │  - Affiche les feedbacks utilisateur                        │    │
│  └─────────────────────────┬───────────────────────────────────┘    │
└────────────────────────────┼────────────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────────────┐
│                        Service Layer                                 │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                   WebSocketService                           │    │
│  │                                                              │    │
│  │  Streams:                                                    │    │
│  │  ├── stateStream        → État de connexion                 │    │
│  │  ├── notificationStream → Notifications personnelles        │    │
│  │  └── actionStream       → Actions broadcast                 │    │
│  │                                                              │    │
│  │  Responsabilités:                                            │    │
│  │  ├── Connexion STOMP                                        │    │
│  │  ├── Abonnements aux topics                                 │    │
│  │  ├── Parsing des messages                                   │    │
│  │  └── Reconnexion automatique                                │    │
│  └─────────────────────────┬───────────────────────────────────┘    │
└────────────────────────────┼────────────────────────────────────────┘
                             │
                             │ STOMP/WebSocket
                             ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Serveur Spring Boot                              │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  /user/queue/notifications  ← Messages personnels            │    │
│  │  /topic/actions             ← Broadcast à tous               │    │
│  └─────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Flux de Connexion

### 3.1 Déclenchement

La connexion WebSocket est initialisée après le login utilisateur :

```
UserBloc émet UserLoaded
        │
        ▼
WebSocketInitializer détecte le changement
        │
        ▼
Récupère userPhone + authToken
        │
        ▼
WebSocketService.connect()
```

### 3.2 Étapes de Connexion

```dart
// 1. Vérification de l'état actuel
if (_currentState.isConnected || _currentState.isConnecting) {
  return; // Déjà connecté ou en cours
}

// 2. Construction de l'URL
// http://domain → ws://domain/ws/websocket
// https://domain → wss://domain/ws/websocket

// 3. Configuration STOMP
StompClient(
  config: StompConfig(
    url: wsUrl,
    stompConnectHeaders: {
      'telephone': userPhone,
      'authorization': 'Bearer $authToken',
    },
    connectionTimeout: Duration(seconds: 10),
  ),
);

// 4. Activation
_stompClient.activate();

// 5. Callback de connexion réussie
_onStompConnected() {
  _subscribeToPersonalNotifications();
  _subscribeToGlobalActions();
}
```

### 3.3 Diagramme de Séquence

```
Client                    WebSocket                   Serveur
   │                          │                          │
   ├── activate() ───────────>│                          │
   │                          ├── CONNECT ──────────────>│
   │                          │   (telephone, token)     │
   │                          │                          │
   │                          │<──── CONNECTED ──────────│
   │                          │   (user-name: +225...)   │
   │<─ onConnect callback ────│                          │
   │                          │                          │
   ├── subscribe() ──────────>│                          │
   │                          ├── SUBSCRIBE ────────────>│
   │                          │   /user/queue/notifs     │
   │                          │                          │
   ├── subscribe() ──────────>│                          │
   │                          ├── SUBSCRIBE ────────────>│
   │                          │   /topic/actions         │
   │                          │                          │
```

---

## 4. Abonnements et Destinations

### 4.1 Destinations STOMP

| Destination | Type | Direction | Usage |
|-------------|------|-----------|-------|
| `/user/queue/notifications` | Queue | Serveur → Client | Notifications personnelles |
| `/topic/actions` | Topic | Serveur → Client | Broadcast à tous les clients |
| `/app/actions` | App | Client → Serveur | Envoi d'actions au serveur |

### 4.2 Fonctionnement Spring STOMP

#### Notifications Personnelles

```
                    SERVEUR                              CLIENT
                       │                                    │
convertAndSendToUser("+225...", "/queue/notifications")     │
                       │                                    │
                       │    Spring ajoute automatiquement   │
                       │    le préfixe /user/{userId}       │
                       │                                    │
                       ├──── MESSAGE ──────────────────────>│
                       │     destination: /user/queue/...   │
                       │                                    │
                       │           Le client s'abonne à:    │
                       │           /user/queue/notifications│
                       │           (sans le userId!)        │
```

**Important** : Avec `convertAndSendToUser()`, le client s'abonne à `/user/queue/notifications` (pas `/user/{phone}/queue/notifications`). Spring route automatiquement via le Principal de la session.

#### Actions Broadcast

```
                    SERVEUR                              CLIENT
                       │                                    │
convertAndSend("/topic/actions", payload)                   │
                       │                                    │
                       ├──── MESSAGE ──────────────────────>│ Client 1
                       ├──── MESSAGE ──────────────────────>│ Client 2
                       ├──── MESSAGE ──────────────────────>│ Client 3
                       │                                    │
```

---

## 5. Types de Messages

### 5.1 Notifications

**Modèle** : `NotificationModel`

```dart
class NotificationModel {
  int? id;
  String? titre;
  String? contenu;
  User? user;
  NotificationEvent event;    // RESERVATION, MESSAGE, NOTIFICATION
  bool lu;                    // true = lue, false = non lue
  DateTime? createdAt;
  Map<String, dynamic>? actionData;
}
```

**Exemple JSON reçu** :
```json
{
  "id": 123,
  "titre": "Nouvelle réservation",
  "contenu": "Jean a réservé votre appartement",
  "event": "RESERVATION",
  "status": "EN_ATTENTE",
  "createdAt": "2025-12-11T08:30:00Z",
  "actionData": {
    "reservationId": 456,
    "appartementId": 789
  }
}
```

### 5.2 Actions Temps Réel

**Modèle** : `RealtimeAction`

```dart
class RealtimeAction {
  String type;
  Map<String, dynamic> payload;
  DateTime timestamp;
}
```

**Types d'actions prédéfinis** :

| Type | Description | Payload |
|------|-------------|---------|
| `REFRESH_FAVORITES` | Rafraîchir les favoris | - |
| `REFRESH_APPARTEMENTS` | Rafraîchir la liste des appartements | - |
| `REFRESH_BOOKINGS` | Rafraîchir les réservations | - |
| `REFRESH_MAP_RESIDENCES` | Rafraîchir les données de la carte | - |
| `UPDATE_APPARTEMENT_PRICE` | Prix d'un appartement modifié | `{appartementId, newPrice}` |
| `UPDATE_APPARTEMENT_AVAILABILITY` | Disponibilité modifiée | `{appartementId, isAvailable}` |
| `NEW_APPARTEMENT_IN_AREA` | Nouvel appartement dans la zone | `{appartementId, lat, lng}` |
| `NEW_MESSAGE` | Nouveau message reçu | `{conversationId, messageId}` |
| `CONVERSATION_UPDATED` | Conversation mise à jour | `{conversationId}` |
| `BOOKING_CONFIRMED` | Réservation confirmée | `{bookingId}` |
| `ADMIN_BROADCAST` | Message admin broadcast | `{titre, contenu}` |
| `ADMIN_MESSAGE` | Message admin personnel | `{titre, contenu}` |

**Exemple JSON reçu** :
```json
{
  "type": "UPDATE_APPARTEMENT_PRICE",
  "payload": {
    "appartementId": 123,
    "newPrice": 45000
  },
  "timestamp": 1765414203591
}
```

---

## 6. Intégration BLoC

### 6.1 NotificationBloc

Le `NotificationBloc` s'abonne aux streams du WebSocketService :

```dart
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {

  void _initializeWebSocketStreams() {
    // Écoute des changements d'état de connexion
    _webSocketStateSubscription = _webSocketService.stateStream.listen(
      (webSocketState) {
        add(WebSocketStateChanged(webSocketState));
      }
    );

    // Écoute des notifications entrantes
    _notificationSubscription = _webSocketService.notificationStream.listen(
      (notification) {
        add(NotificationReceived(notification));
      }
    );
  }
}
```

### 6.2 RealtimeActionHandler

Dispatch les actions vers les BLoCs appropriés :

```dart
void _handleRealtimeAction(RealtimeAction action) {
  switch (action.type) {
    case RealtimeAction.refreshFavorites:
      _context.read<FavoriteBloc>().add(LoadFavorites());
      break;

    case RealtimeAction.refreshAppartements:
      _context.read<AppartementBloc>().add(LoadAppartements());
      break;

    case RealtimeAction.newMessage:
      _context.read<ConversationBloc>().add(
        MessageReceived(action.payload['conversationId'])
      );
      break;

    // ... autres cas
  }
}
```

### 6.3 Flux de Données

```
WebSocket Message
       │
       ▼
WebSocketService (parse JSON)
       │
       ├── Notification ──> notificationStream
       │                           │
       │                           ▼
       │                    NotificationBloc
       │                           │
       │                           ▼
       │                    NotificationReceivedState
       │                           │
       │                           ▼
       │                    UI (SnackBar + Badge)
       │
       └── Action ──────> actionStream
                               │
                               ▼
                        RealtimeActionHandler
                               │
                               ▼
                        Target BLoC (LoadXxx)
                               │
                               ▼
                        UI Rebuild
```

---

## 7. Gestion de la Reconnexion

### 7.1 Configuration

```dart
static const int _maxReconnectAttempts = 5;
static const Duration _initialReconnectDelay = Duration(seconds: 2);
static const Duration _maxReconnectDelay = Duration(seconds: 30);
```

### 7.2 Backoff Exponentiel

```dart
Duration _calculateReconnectDelay(int attempts) {
  final delay = _initialReconnectDelay * (1 << attempts); // 2^n
  return delay < _maxReconnectDelay ? delay : _maxReconnectDelay;
}
```

**Timeline des tentatives** :

| Tentative | Délai | Temps cumulé |
|-----------|-------|--------------|
| 1 | 2s | 2s |
| 2 | 4s | 6s |
| 3 | 8s | 14s |
| 4 | 16s | 30s |
| 5 | 30s (max) | 60s |

### 7.3 Déclencheurs de Reconnexion

```
Erreur WebSocket ────────┐
                         │
Erreur STOMP ───────────>├──> _handleConnectionError()
                         │            │
WebSocket fermé ────────┘            ▼
                              _scheduleReconnect()
                                     │
                                     ▼
                              Timer(delay) → _connect()
```

### 7.4 États de Connexion

```dart
enum WebSocketConnectionStatus {
  disconnected,   // Non connecté
  connecting,     // Connexion en cours
  connected,      // Connecté et authentifié
  reconnecting,   // Tentative de reconnexion
  error,          // Erreur de connexion
}
```

---

## 8. Cycle de Vie

### 8.1 Gestion du Cycle de Vie App

Le `WebSocketInitializer` gère les transitions d'état de l'application :

```dart
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      // App revient au premier plan
      RealtimeActionHandler.instance.resume();
      _checkWebSocketConnection();
      break;

    case AppLifecycleState.paused:
    case AppLifecycleState.inactive:
      // App en arrière-plan
      RealtimeActionHandler.instance.pause();
      break;

    case AppLifecycleState.detached:
      // App terminée
      RealtimeActionHandler.instance.dispose();
      break;
  }
}
```

### 8.2 Diagramme du Cycle de Vie

```
┌─────────────────────────────────────────────────────────┐
│                    App Lifecycle                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  LAUNCHED ──> UserLoaded ──> WebSocket.connect()        │
│                                     │                   │
│                                     ▼                   │
│                              ┌─────────────┐            │
│                              │  CONNECTED  │            │
│                              └──────┬──────┘            │
│                                     │                   │
│         ┌───────────────────────────┼───────────────┐   │
│         │                           │               │   │
│         ▼                           ▼               ▼   │
│    App Paused              Network Error       App Resumed
│         │                           │               │   │
│         ▼                           ▼               ▼   │
│  Streams paused            Reconnect Timer    Check connection
│                                     │               │   │
│                                     ▼               │   │
│                              Auto reconnect ◄───────┘   │
│                                                         │
│                                                         │
│  LOGOUT ──> WebSocket.disconnect() ──> Streams closed   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 9. Flux de Données Complet

### 9.1 Réception d'une Notification

```
┌──────────────────────────────────────────────────────────────────────┐
│ 1. SERVEUR envoie notification                                        │
│    convertAndSendToUser("+225...", "/queue/notifications", payload)  │
└───────────────────────────────────┬──────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 2. WebSocketService reçoit StompFrame                                 │
│    _handleNotificationMessage(frame)                                  │
│    - Parse JSON                                                       │
│    - Crée NotificationModel                                           │
│    - _notificationController.add(notification)                        │
└───────────────────────────────────┬──────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 3. NotificationBloc reçoit via stream                                 │
│    add(NotificationReceived(notification))                            │
│    - Insère en tête de liste                                          │
│    - Sauvegarde dans SharedPreferences                                │
│    - emit(NotificationReceivedState(...))                             │
└───────────────────────────────────┬──────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 4. UI réagit                                                          │
│    - BlocListener affiche SnackBar/Toast                              │
│    - Badge compteur se met à jour                                     │
│    - Liste des notifications se rafraîchit                            │
└──────────────────────────────────────────────────────────────────────┘
```

### 9.2 Réception d'une Action Temps Réel

```
┌──────────────────────────────────────────────────────────────────────┐
│ 1. SERVEUR broadcast action                                           │
│    convertAndSend("/topic/actions", payload)                          │
└───────────────────────────────────┬──────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 2. WebSocketService reçoit StompFrame                                 │
│    _handleActionMessage(frame)                                        │
│    - Parse JSON                                                       │
│    - Crée RealtimeAction                                              │
│    - _actionController.add(action)                                    │
└───────────────────────────────────┬──────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 3. RealtimeActionHandler reçoit via stream                            │
│    _handleRealtimeAction(action)                                      │
│    - Switch sur action.type                                           │
│    - Appelle le handler approprié                                     │
└───────────────────────────────────┬──────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 4. BLoC cible reçoit l'event                                          │
│    Ex: AppartementBloc.add(LoadAppartements())                        │
│    - Charge les données fraîches depuis l'API                         │
│    - emit(AppartementsLoaded(...))                                    │
└───────────────────────────────────┬──────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│ 5. UI se reconstruit                                                  │
│    - BlocBuilder détecte le nouvel état                               │
│    - Widgets affichent les données mises à jour                       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 10. Fichiers Clés

| Fichier | Responsabilité |
|---------|----------------|
| `lib/service/websocket/websocket_service.dart` | Service principal : connexion STOMP, abonnements, parsing |
| `lib/model/websocket/websocket_state.dart` | Modèles : `WebSocketState`, `RealtimeAction` |
| `lib/model/notification/notification.dart` | Modèle : `NotificationModel` |
| `lib/model/notification/notification_event.dart` | Enum : types d'événements notification |
| `lib/model/notification/notification_status.dart` | Enum : statuts de notification |
| `lib/bloc/notification_bloc/notification_bloc.dart` | BLoC : gestion état notifications |
| `lib/widget/websocket/websocket_initializer.dart` | Widget : initialisation et lifecycle |
| `lib/service/realtime/realtime_action_handler.dart` | Handler : dispatch des actions temps réel |
| `lib/service/notification/notification_service.dart` | Service API : endpoints REST notifications |

---

## Résumé

L'implémentation WebSocket de l'application suit une architecture **événementielle et réactive** :

1. **WebSocketService** gère la connexion bas-niveau et expose des **streams**
2. **NotificationBloc** et **RealtimeActionHandler** consomment ces streams
3. La **reconnexion automatique** avec backoff exponentiel assure la résilience
4. Le **cycle de vie** de l'app est géré pour économiser les ressources
5. Le pattern **cache-first** permet une expérience offline gracieuse

Cette architecture permet une **séparation des responsabilités** claire et une **testabilité** optimale.
