import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_settings_card.dart';

/// Mapping rôle → données d'affichage pour `ClientProfileScreen`.
///
/// Aligne les libellés sur `extras.jsx::Profile.profiles[role]` du prototype
/// (lignes 292-296). Les variantes peuvent évoluer indépendamment du modèle
/// `User` métier.
class ProfileDisplayInfo {
  final String subtitle;
  final String? badge;
  final List<ProfileSettingsItem> Function(VoidCallback onTap) settingsBuilder;

  const ProfileDisplayInfo._({
    required this.subtitle,
    required this.badge,
    required this.settingsBuilder,
  });

  /// Factory selon le rôle actif (`user.type`). Les rôles inconnus tombent
  /// sur le mapping locataire pour éviter un écran cassé.
  factory ProfileDisplayInfo.forRole(String? role) {
    switch ((role ?? '').toLowerCase()) {
      case 'demarcheur':
        return ProfileDisplayInfo._(
          subtitle: 'Démarcheur · 27 clients',
          badge: 'Top démarcheur',
          settingsBuilder: _demarcheurSettings,
        );
      case 'proprietaire':
        return ProfileDisplayInfo._(
          subtitle: 'Propriétaire · 4 biens',
          badge: '★ Hôte certifié',
          settingsBuilder: _proprietaireSettings,
        );
      case 'locataire':
      default:
        return ProfileDisplayInfo._(
          subtitle: 'Locataire · Membre depuis 2024',
          badge: null,
          settingsBuilder: _locataireSettings,
        );
    }
  }

  static List<ProfileSettingsItem> _locataireSettings(VoidCallback onTap) => [
        ProfileSettingsItem(
            icon: Icons.person_outline,
            label: 'Informations personnelles',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.verified_outlined,
            label: "Vérification d'identité",
            value: 'Vérifié',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Méthodes de paiement',
            value: '3 actives',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.tune, label: 'Préférences', onTap: onTap),
      ];

  static List<ProfileSettingsItem> _demarcheurSettings(VoidCallback onTap) => [
        ProfileSettingsItem(
            icon: Icons.person_outline,
            label: 'Informations personnelles',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.verified_outlined,
            label: "Vérification d'identité",
            value: 'Vérifié',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.account_balance_outlined,
            label: 'Méthode de retrait',
            value: 'Orange Money',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.tune, label: 'Préférences', onTap: onTap),
      ];

  static List<ProfileSettingsItem> _proprietaireSettings(VoidCallback onTap) =>
      [
        ProfileSettingsItem(
            icon: Icons.person_outline,
            label: 'Informations personnelles',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.verified_outlined,
            label: "Vérification d'identité",
            value: 'Vérifié',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Méthodes de paiement',
            value: '3 actives',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: onTap),
        ProfileSettingsItem(
            icon: Icons.tune, label: 'Préférences', onTap: onTap),
      ];
}
