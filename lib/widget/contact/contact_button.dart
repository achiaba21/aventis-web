import 'package:flutter/material.dart';
import 'package:asfar/model/contact/contact.dart';
import 'package:asfar/service/contact/contact_availability.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/contact/contact_sheet.dart';

/// Bouton "Contacter" réutilisable.
///
/// Au tap, ouvre la `ContactSheet` à 3 options. Désactivé (grisé) si les 3
/// options de contact sont indisponibles
/// ([ContactAvailability.contactButtonEnabled] = false).
class ContactButton extends StatelessWidget {
  final Contact contact;
  final ContactAvailability availability;
  final String label;
  final ButtonSize size;
  final bool block;

  const ContactButton({
    super.key,
    required this.contact,
    required this.availability,
    this.label = 'Contacter',
    this.size = ButtonSize.md,
    this.block = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedCustomButton(
      text: label,
      onPressed: availability.contactButtonEnabled
          ? () => _open(context)
          : null,
      size: size,
      block: block,
      leadingIcon: Icons.chat_bubble_outline,
    );
  }

  void _open(BuildContext context) {
    ContactSheet.show(
      context,
      contact: contact,
      availability: availability,
    );
  }
}
