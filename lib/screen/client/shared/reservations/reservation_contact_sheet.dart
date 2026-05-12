import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asfar/screen/client/shared/inbox/messaging_list_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/reservation_contact_resolver.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';

/// Bottom sheet "Contacter" de la page détail réservation.
///
/// 2 actions selon disponibilité :
/// - Appeler (`tel:` via `url_launcher`) si téléphone renseigné
/// - Discuter dans Asfar → push `MessagingListScreen` si la cible est
///   chattable (userId présent, donc pas un client externe d'une résa manuelle)
class ReservationContactSheet {
  ReservationContactSheet._();

  static Future<void> show(BuildContext context, ContactTarget target) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.lg),
        ),
      ),
      builder: (_) => _ReservationContactSheetBody(target: target),
    );
  }
}

class _ReservationContactSheetBody extends StatelessWidget {
  final ContactTarget target;

  const _ReservationContactSheetBody({required this.target});

  Future<void> _onCall(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final tel = target.telephone?.trim() ?? '';
    if (tel.isEmpty) return;
    try {
      final ok = await launchUrl(Uri(scheme: 'tel', path: tel));
      navigator.pop();
      if (!ok) {
        messenger.showSnackBar(const SnackBar(
          content: Text("Impossible de lancer l'appel"),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      deboger('ReservationContactSheet._onCall: $e');
      navigator.pop();
    }
  }

  void _onChat(BuildContext context) {
    Navigator.of(context).pop();
    pushScreen(context, const MessagingListScreen());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 14),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textDim,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('CONTACTER', style: AppTextStyles.eyebrow),
                const SizedBox(height: 6),
                Text(target.displayName, style: AppTextStyles.h3),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (target.hasPhone)
            _ContactSheetTile(
              icon: Icons.phone_outlined,
              label: 'Appeler ${target.telephone}',
              onTap: () => _onCall(context),
            ),
          if (target.canChat)
            _ContactSheetTile(
              icon: Icons.chat_bubble_outline,
              label: 'Discuter dans Asfar',
              onTap: () => _onChat(context),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ContactSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.line, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
