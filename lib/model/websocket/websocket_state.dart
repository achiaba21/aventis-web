enum WebSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class WebSocketState {
  final WebSocketConnectionStatus status;
  final String? errorMessage;
  final DateTime? lastConnectedAt;
  final DateTime? lastDisconnectedAt;
  final int reconnectAttempts;
  final bool isAuthenticated;

  const WebSocketState({
    this.status = WebSocketConnectionStatus.disconnected,
    this.errorMessage,
    this.lastConnectedAt,
    this.lastDisconnectedAt,
    this.reconnectAttempts = 0,
    this.isAuthenticated = false,
  });

  WebSocketState copyWith({
    WebSocketConnectionStatus? status,
    String? errorMessage,
    DateTime? lastConnectedAt,
    DateTime? lastDisconnectedAt,
    int? reconnectAttempts,
    bool? isAuthenticated,
  }) {
    return WebSocketState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      lastDisconnectedAt: lastDisconnectedAt ?? this.lastDisconnectedAt,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  // États de commodité
  bool get isConnected => status == WebSocketConnectionStatus.connected && isAuthenticated;
  bool get isConnecting => status == WebSocketConnectionStatus.connecting;
  bool get isDisconnected => status == WebSocketConnectionStatus.disconnected;
  bool get isReconnecting => status == WebSocketConnectionStatus.reconnecting;
  bool get hasError => status == WebSocketConnectionStatus.error;

  String get statusDisplayText {
    switch (status) {
      case WebSocketConnectionStatus.disconnected:
        return 'Déconnecté';
      case WebSocketConnectionStatus.connecting:
        return 'Connexion...';
      case WebSocketConnectionStatus.connected:
        return isAuthenticated ? 'Connecté' : 'Authentification...';
      case WebSocketConnectionStatus.reconnecting:
        return 'Reconnexion... ($reconnectAttempts)';
      case WebSocketConnectionStatus.error:
        return 'Erreur de connexion';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebSocketState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage &&
          lastConnectedAt == other.lastConnectedAt &&
          lastDisconnectedAt == other.lastDisconnectedAt &&
          reconnectAttempts == other.reconnectAttempts &&
          isAuthenticated == other.isAuthenticated;

  @override
  int get hashCode => Object.hash(
        status,
        errorMessage,
        lastConnectedAt,
        lastDisconnectedAt,
        reconnectAttempts,
        isAuthenticated,
      );

  @override
  String toString() {
    return 'WebSocketState{status: $status, isAuthenticated: $isAuthenticated, reconnectAttempts: $reconnectAttempts, errorMessage: $errorMessage}';
  }
}

class RealtimeAction {
  final String type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;

  RealtimeAction({
    required this.type,
    required this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  RealtimeAction.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? '',
        payload = json['payload'] ?? {},
        timestamp = json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Types d'actions prédéfinis
  static const String refreshFavorites = 'REFRESH_FAVORITES';
  static const String refreshAppartements = 'REFRESH_APPARTEMENTS';
  static const String refreshBookings = 'REFRESH_BOOKINGS';
  static const String refreshMapResidences = 'REFRESH_MAP_RESIDENCES';
  static const String updateAppartementPrice = 'UPDATE_APPARTEMENT_PRICE';
  static const String updateAppartementAvailability = 'UPDATE_APPARTEMENT_AVAILABILITY';
  static const String newAppartementInArea = 'NEW_APPARTEMENT_IN_AREA';
  static const String newMessage = 'NEW_MESSAGE';
  static const String conversationUpdated = 'CONVERSATION_UPDATED';
  static const String bookingConfirmed = 'BOOKING_CONFIRMED';

  @override
  String toString() {
    return 'RealtimeAction{type: $type, payload: $payload, timestamp: $timestamp}';
  }
}