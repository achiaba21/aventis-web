import 'package:flutter/material.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Vue d'erreur de la page détail réservation.
///
/// Wrapper sur `EmptyState.error` (réutilisation 100% du composant existant).
class ReservationDetailErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ReservationDetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: EmptyState.error(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}
