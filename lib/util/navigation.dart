import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/home/home.dart';

/// Navigue vers un nouveau widget en supprimant toutes les routes précédentes
Future<void> pushAndRemoveAll(BuildContext context, Widget screen) async {
  await Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => screen),
    (route) => false,
  );
}

/// Navigue vers un onglet spécifique du menu principal
/// Utilise pushAndRemoveUntil pour éviter les problèmes de navigation
Future<void> navigateToMenuTab(BuildContext context, int tabIndex) async {
  await Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => Home(initialTab: tabIndex)),
    (route) => false,
  );
}

/// Navigue vers l'onglet Explore (index 0)
Future<void> navigateToExplore(BuildContext context) async {
  await navigateToMenuTab(context, 0);
}

/// Navigue vers l'onglet Favorites (index 1)
Future<void> navigateToFavorites(BuildContext context) async {
  await navigateToMenuTab(context, 1);
}

/// Navigue vers l'onglet Bookings (index 2)
Future<void> navigateToBookings(BuildContext context) async {
  await navigateToMenuTab(context, 2);
}

/// Navigue vers l'onglet Inbox (index 3)
Future<void> navigateToInbox(BuildContext context) async {
  await navigateToMenuTab(context, 3);
}

/// Navigue vers l'onglet Profile (index 4)
Future<void> navigateToProfile(BuildContext context) async {
  await navigateToMenuTab(context, 4);
}

/// Navigue vers un nouveau widget (push simple)
Future<T?> pushScreen<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return await Navigator.of(context).push<T?>(
    MaterialPageRoute(builder: (context) => screen),
  );
}

/// Alias pour pushScreen (compatibilité)
Future<T?> pushWidget<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return pushScreen<T>(context, screen);
}

/// Remplace la route actuelle par un nouveau widget
Future<T?> pushScreenAndReplace<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return await Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => screen),
  );
}

/// Alias pour pushScreenAndReplace (compatibilité)
Future<T?> pushWidgetAndReplace<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return pushScreenAndReplace<T>(context, screen);
}

/// Retourne à la route précédente
void back<T>(BuildContext context, [T? result]) {
  Navigator.of(context).pop(result);
}
