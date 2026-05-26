import 'package:flutter/material.dart';
import 'package:asfar/service/contact/contact_action_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Variante visuelle du `CallButton`.
enum CallButtonVariant {
  /// Bouton outlined avec label "Appeler" + icône — pour cards larges.
  outlined,

  /// Icône seule circulaire — pour cards compactes (party cards, etc.).
  iconOnly,
}

/// Bouton "Appeler" réutilisable.
///
/// Lance directement le dialer natif via `ContactActionService.call`. Aucune
/// sheet intermédiaire — c'est l'action unitaire la plus rapide.
///
/// Désactivé si [phone] est null/vide ou si [enabled] est `false`.
class CallButton extends StatelessWidget {
  final String? phone;
  final bool enabled;
  final String label;
  final CallButtonVariant variant;
  final ButtonSize size;

  const CallButton({
    super.key,
    required this.phone,
    this.enabled = true,
    this.label = 'Appeler',
    this.variant = CallButtonVariant.outlined,
    this.size = ButtonSize.md,
  });

  bool get _hasPhone => (phone ?? '').trim().isNotEmpty;
  bool get _active => enabled && _hasPhone;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case CallButtonVariant.outlined:
        return OutlinedCustomButton(
          text: label,
          onPressed: _active ? () => _onTap(context) : null,
          size: size,
          leadingIcon: Icons.phone_outlined,
        );
      case CallButtonVariant.iconOnly:
        return IconBoutton(
          icon: Icons.phone,
          onPressed: _active ? () => _onTap(context) : null,
          iconColor: _active ? AppColors.accent : AppColors.textDisabled,
          tooltip: label,
        );
    }
  }

  void _onTap(BuildContext context) {
    ContactActionService.instance.call(context, phone!);
  }
}
