import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_settings_card.dart';

/// Callbacks utilisés pour wirer les items du `ProfileSettingsCard`.
class ProfileSettingsCallbacks {
  final VoidCallback? onPersonalInfo;
  final VoidCallback? onNotifications;
  final VoidCallback? onPartenariats;
  final VoidCallback? onComingSoon;

  const ProfileSettingsCallbacks({
    this.onPersonalInfo,
    this.onNotifications,
    this.onPartenariats,
    this.onComingSoon,
  });
}

/// Mapping rôle → données d'affichage pour `ClientProfileScreen`.
class ProfileDisplayInfo {
  final String subtitle;
  final String? badge;
  final List<ProfileSettingsItem> Function(ProfileSettingsCallbacks)
      settingsBuilder;

  const ProfileDisplayInfo._({
    required this.subtitle,
    required this.badge,
    required this.settingsBuilder,
  });

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

  static List<ProfileSettingsItem> _locataireSettings(
          ProfileSettingsCallbacks cb) =>
      [
        ProfileSettingsItem(
            icon: Icons.person_outline,
            label: 'Informations personnelles',
            onTap: cb.onPersonalInfo),
        ProfileSettingsItem(
            icon: Icons.verified_outlined,
            label: "Vérification d'identité",
            value: 'Vérifié',
            onTap: cb.onComingSoon),
        if (false)
          ProfileSettingsItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Méthodes de paiement',
              value: '3 actives',
              onTap: cb.onComingSoon),
        ProfileSettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: cb.onNotifications),
        if (false)
          ProfileSettingsItem(
              icon: Icons.tune, label: 'Préférences', onTap: cb.onComingSoon),
      ];

  static List<ProfileSettingsItem> _demarcheurSettings(
          ProfileSettingsCallbacks cb) =>
      [
        ProfileSettingsItem(
            icon: Icons.person_outline,
            label: 'Informations personnelles',
            onTap: cb.onPersonalInfo),
        ProfileSettingsItem(
            icon: Icons.handshake_outlined,
            label: 'Mes partenariats',
            onTap: cb.onPartenariats),
        ProfileSettingsItem(
            icon: Icons.verified_outlined,
            label: "Vérification d'identité",
            value: 'Vérifié',
            onTap: cb.onComingSoon),
        if (false)
          ProfileSettingsItem(
              icon: Icons.account_balance_outlined,
              label: 'Méthode de retrait',
              value: 'Orange Money',
              onTap: cb.onComingSoon),
        ProfileSettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: cb.onNotifications),
        if (false)
          ProfileSettingsItem(
              icon: Icons.tune, label: 'Préférences', onTap: cb.onComingSoon),
      ];

  static List<ProfileSettingsItem> _proprietaireSettings(
          ProfileSettingsCallbacks cb) =>
      [
        ProfileSettingsItem(
            icon: Icons.person_outline,
            label: 'Informations personnelles',
            onTap: cb.onPersonalInfo),
        ProfileSettingsItem(
            icon: Icons.handshake_outlined,
            label: 'Demandes de démarcheurs',
            onTap: cb.onPartenariats),
        ProfileSettingsItem(
            icon: Icons.verified_outlined,
            label: "Vérification d'identité",
            value: 'Vérifié',
            onTap: cb.onComingSoon),
        if (false)
          ProfileSettingsItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Méthodes de paiement',
              value: '3 actives',
              onTap: cb.onComingSoon),
        ProfileSettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: cb.onNotifications),
        if (false)
          ProfileSettingsItem(
              icon: Icons.tune, label: 'Préférences', onTap: cb.onComingSoon),
      ];
}
