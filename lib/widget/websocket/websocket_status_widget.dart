import 'package:flutter/material.dart';
import 'package:web_flutter/service/websocket/websocket_manager.dart';

class WebSocketStatusWidget extends StatefulWidget {
  const WebSocketStatusWidget({super.key});

  @override
  State<WebSocketStatusWidget> createState() => _WebSocketStatusWidgetState();
}

class _WebSocketStatusWidgetState extends State<WebSocketStatusWidget> {
  final WebSocketManager _webSocketManager = WebSocketManager.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      stream: _webSocketManager.stateStream,
      builder: (context, snapshot) {
        final isConnected = _webSocketManager.isConnected;

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                isConnected ? 'WebSocket connecté' : 'WebSocket déconnecté',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WebSocketNotificationListener extends StatefulWidget {
  final Widget child;

  const WebSocketNotificationListener({
    super.key,
    required this.child,
  });

  @override
  State<WebSocketNotificationListener> createState() => _WebSocketNotificationListenerState();
}

class _WebSocketNotificationListenerState extends State<WebSocketNotificationListener> {
  final WebSocketManager _webSocketManager = WebSocketManager.instance;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    // Écouter les notifications
    _webSocketManager.notificationStream.listen(
      (notification) {
        _showNotificationSnackBar(notification.toString());
      },
      onError: (error) {
        debugPrint('Erreur notification: $error');
      },
    );

    // Écouter les actions temps réel
    _webSocketManager.actionStream.listen(
      (action) {
        _showActionSnackBar(action.toString());
      },
      onError: (error) {
        debugPrint('Erreur action: $error');
      },
    );
  }

  void _showNotificationSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Notification: $message')),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showActionSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Action: $message')),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}