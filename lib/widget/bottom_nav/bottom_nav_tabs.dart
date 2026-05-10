import 'package:flutter/material.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_item.dart';

/// Configurations des [BottomNav] par rôle, alignées sur `app.jsx::tabsByRole`.
class BottomNavTabs {
  BottomNavTabs._();

  static const List<BottomNavItem> locataire = [
    BottomNavItem(id: 'home', label: 'Explorer', icon: Icons.search),
    BottomNavItem(
        id: 'trips', label: 'Voyages', icon: Icons.calendar_today_outlined),
    BottomNavItem(
        id: 'saved', label: 'Favoris', icon: Icons.favorite_border),
    BottomNavItem(
        id: 'messages', label: 'Messages', icon: Icons.chat_bubble_outline),
    BottomNavItem(id: 'profile', label: 'Profil', icon: Icons.person_outline),
  ];

  static const List<BottomNavItem> proprio = [
    BottomNavItem(id: 'home', label: 'Accueil', icon: Icons.grid_view_outlined),
    BottomNavItem(
        id: 'listings', label: 'Annonces', icon: Icons.list_alt_outlined),
    BottomNavItem(
        id: 'finances', label: 'Finances', icon: Icons.bar_chart_outlined),
    BottomNavItem(
        id: 'messages', label: 'Messages', icon: Icons.chat_bubble_outline),
    BottomNavItem(id: 'profile', label: 'Profil', icon: Icons.person_outline),
  ];

  static const List<BottomNavItem> demarcheur = [
    BottomNavItem(id: 'home', label: 'Accueil', icon: Icons.grid_view_outlined),
    BottomNavItem(
        id: 'referrals', label: 'Demandes', icon: Icons.send_outlined),
    BottomNavItem(
        id: 'wallet',
        label: 'Gains',
        icon: Icons.account_balance_wallet_outlined),
    BottomNavItem(
        id: 'messages', label: 'Messages', icon: Icons.chat_bubble_outline),
    BottomNavItem(id: 'profile', label: 'Profil', icon: Icons.person_outline),
  ];
}
