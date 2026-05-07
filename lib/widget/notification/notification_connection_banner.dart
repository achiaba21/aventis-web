import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart' as events;
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Banner affichant l'état de connexion WebSocket pour les notifications
class NotificationConnectionBanner extends StatelessWidget {
  const NotificationConnectionBanner({
    super.key,
    required this.webSocketState,
  });

  final WebSocketState webSocketState;

  @override
  Widget build(BuildContext context) {
    // Ne rien afficher si connecté
    if (webSocketState.isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border(
          bottom: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: AppColors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  _getTitle(),
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                if (_getMessage() != null) ...[
                  const SizedBox(height: 4),
                  TextSeed(
                    _getMessage()!,
                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ],
              ],
            ),
          ),
          if (_showReconnectButton()) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                context.read<NotificationBloc>().add(
                      const events.ReconnectWebSocket(),
                    );
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.textPrimary.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextSeed(
                "Reconnecter",
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (webSocketState.isReconnecting) {
      return AppColors.accent; // Orange
    } else if (webSocketState.hasError || webSocketState.isDisconnected) {
      return AppColors.error; // Red
    } else if (webSocketState.isConnecting) {
      return AppColors.info; // Blue
    }
    return AppColors.textPrimary.withValues(alpha: 0.3);
  }

  IconData _getIcon() {
    if (webSocketState.isReconnecting || webSocketState.isConnecting) {
      return Icons.sync;
    } else if (webSocketState.hasError) {
      return Icons.error_outline;
    } else if (webSocketState.isDisconnected) {
      return Icons.cloud_off;
    }
    return Icons.info_outline;
  }

  String _getTitle() {
    if (webSocketState.isReconnecting) {
      return "Reconnexion en cours...";
    } else if (webSocketState.isConnecting) {
      return "Connexion en cours...";
    } else if (webSocketState.hasError) {
      return "Erreur de connexion";
    } else if (webSocketState.isDisconnected) {
      return "Déconnecté";
    }
    return "État inconnu";
  }

  String? _getMessage() {
    if (webSocketState.hasError && webSocketState.errorMessage != null) {
      return webSocketState.errorMessage;
    } else if (webSocketState.isDisconnected) {
      return "Les notifications ne seront pas reçues en temps réel";
    } else if (webSocketState.isReconnecting) {
      return "Tentative ${webSocketState.reconnectAttempts}";
    }
    return null;
  }

  bool _showReconnectButton() {
    return webSocketState.isDisconnected || webSocketState.hasError;
  }
}
