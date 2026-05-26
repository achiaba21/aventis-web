import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/contact/contact.dart';
import 'package:asfar/model/message/seance.dart';
import 'package:asfar/screen/client/shared/inbox/messaging_thread_screen.dart';
import 'package:asfar/service/model/message/message_service.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/message_adapter.dart';
import 'package:asfar/util/navigation.dart';

/// Orchestrateur des 3 actions de contact (appel, WhatsApp, chat in-app).
///
/// Singleton léger — accédé via `ContactActionService.instance`. Toute la
/// duplication `tel:` / `wa.me/...` / navigation vers thread converge ici.
class ContactActionService {
  ContactActionService._();
  static final ContactActionService instance = ContactActionService._();

  /// Lance le dialer natif via `tel:`. Affiche un SnackBar en cas d'échec.
  ///
  /// Utilise `Uri.parse` (et non `Uri(scheme:, path:)`) car la forme
  /// constructeur encode le `+` en `%2B` que le dialer iOS ne reconnaît pas.
  Future<void> call(BuildContext context, String phone) async {
    final cleaned = _sanitizeForTel(phone);
    if (cleaned.isEmpty) {
      _snack(context, 'Aucun numéro de téléphone');
      return;
    }
    try {
      final ok = await launchUrl(Uri.parse('tel:$cleaned'));
      if (!ok && context.mounted) {
        _snack(context, "Impossible de lancer l'appel");
      }
    } catch (e) {
      deboger('ContactActionService.call: $e');
      if (context.mounted) _snack(context, "Impossible de lancer l'appel");
    }
  }

  /// Ouvre WhatsApp via `https://wa.me/<phone>`. SnackBar si non installé.
  Future<void> openWhatsApp(BuildContext context, String phone) async {
    final cleaned = _sanitizeForWhatsApp(phone);
    if (cleaned.isEmpty) {
      _snack(context, 'Numéro WhatsApp indisponible');
      return;
    }
    final uri = Uri.parse('https://wa.me/$cleaned');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _snack(context, "WhatsApp n'est pas installé");
      }
    } catch (e) {
      deboger('ContactActionService.openWhatsApp: $e');
      if (context.mounted) _snack(context, "Impossible d'ouvrir WhatsApp");
    }
  }

  /// Ouvre ou crée une séance de discussion in-app avec [contact].
  ///
  /// Cherche d'abord une séance existante via [MessageService.findSeanceByParticipants].
  /// Si aucune n'existe, en crée une via [MessageService.createSeance], puis navigue
  /// directement vers [MessagingThreadScreen].
  Future<void> openChat(BuildContext context, Contact contact) async {
    if (!contact.canChat) {
      _snack(context, 'Discussion in-app indisponible pour ce contact');
      return;
    }
    final currentUserId = context.read<UserBloc>().state.user?.id;
    if (currentUserId == null) {
      _snack(context, 'Utilisateur non connecté');
      return;
    }
    try {
      final messageService = MessageService();
      final Seance? existing =
          await messageService.findSeanceByParticipants(contact.userId!);
      final seance = existing ??
          await messageService.createSeance(
            proprietaireId: contact.userId!,
            locataireId: currentUserId,
          );
      if (!context.mounted) return;
      final conversation =
          MessageAdapter.seanceToConversation(seance, currentUserId);
      await pushScreen(context, MessagingThreadScreen(conversation: conversation));
    } catch (e) {
      deboger('ContactActionService.openChat: $e');
      if (context.mounted) _snack(context, "Impossible d'ouvrir la discussion");
    }
  }

  void _snack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
    ));
  }

  /// Nettoie un numéro pour `wa.me` : conserve uniquement les chiffres
  /// (WhatsApp accepte les numéros internationaux sans `+` ni espaces).
  String _sanitizeForWhatsApp(String phone) {
    return phone.replaceAll(RegExp(r'\D'), '');
  }

  /// Nettoie un numéro pour `tel:` : conserve les chiffres et le `+` initial,
  /// supprime espaces, tirets, parenthèses et points (sources fréquentes
  /// d'échec côté dialer iOS).
  String _sanitizeForTel(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
