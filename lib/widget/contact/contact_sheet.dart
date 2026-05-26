import 'package:flutter/material.dart';
import 'package:asfar/model/contact/contact.dart';
import 'package:asfar/service/contact/contact_action_service.dart';
import 'package:asfar/service/contact/contact_availability.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/contact/contact_sheet_tile.dart';

/// Bottom sheet "Contacter" générique, réutilisable depuis n'importe quel
/// écran de l'app.
///
/// Affiche 3 options dans l'ordre fixe : Chat in-app / WhatsApp / Appeler.
/// Chaque tile est grisée si l'option n'est pas disponible (voir
/// [ContactAvailability]). La sheet est toujours affichée même si une seule
/// option est active — cohérence UX (cf. business-spec.md §4.2).
class ContactSheet {
  ContactSheet._();

  static Future<void> show(
    BuildContext context, {
    required Contact contact,
    required ContactAvailability availability,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.lg),
        ),
      ),
      builder: (_) => _ContactSheetBody(
        contact: contact,
        availability: availability,
      ),
    );
  }
}

class _ContactSheetBody extends StatelessWidget {
  final Contact contact;
  final ContactAvailability availability;

  const _ContactSheetBody({
    required this.contact,
    required this.availability,
  });

  Future<void> _onChat(BuildContext context) async {
    Navigator.of(context).pop();
    await ContactActionService.instance.openChat(context, contact);
  }

  Future<void> _onWhatsApp(BuildContext context) async {
    final phone = contact.effectiveWhatsAppPhone ?? '';
    Navigator.of(context).pop();
    await ContactActionService.instance.openWhatsApp(context, phone);
  }

  Future<void> _onCall(BuildContext context) async {
    final phone = contact.telephone ?? '';
    Navigator.of(context).pop();
    await ContactActionService.instance.call(context, phone);
  }

  String _whatsAppLabel() {
    final phone = (contact.effectiveWhatsAppPhone ?? '').trim();
    if (phone.isEmpty) return 'WhatsApp';
    return 'WhatsApp $phone';
  }

  String _callLabel() {
    final phone = (contact.telephone ?? '').trim();
    if (phone.isEmpty) return 'Appeler';
    return 'Appeler $phone';
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
                Text(contact.displayName, style: AppTextStyles.h3),
                const SizedBox(height: 16),
              ],
            ),
          ),
          ContactSheetTile(
            icon: Icons.chat_bubble_outline,
            label: 'Discuter dans Asfar',
            enabled: availability.chatEnabled,
            onTap: () => _onChat(context),
          ),
          ContactSheetTile(
            icon: Icons.chat_outlined,
            label: _whatsAppLabel(),
            enabled: availability.whatsAppEnabled,
            onTap: () => _onWhatsApp(context),
          ),
          ContactSheetTile(
            icon: Icons.phone_outlined,
            label: _callLabel(),
            enabled: availability.callEnabled,
            onTap: () => _onCall(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
