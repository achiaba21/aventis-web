import 'package:flutter/material.dart';

/// Helpers de navigation Asfar — primitives Navigator 1.0 réutilisables.
///
/// Les helpers `navigateToMenuTab` & navigateTo[Tab] ont été retirés en
/// attendant la reconstruction de la navigation locataire selon le proto.
/// Ils seront réintroduits quand la nouvelle [Home] sera en place.

/// Navigue vers un nouveau widget en supprimant toutes les routes précédentes.
Future<void> pushAndRemoveAll(BuildContext context, Widget screen) async {
  await Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => screen),
    (route) => false,
  );
}

/// Navigue vers un nouveau widget (push simple).
Future<T?> pushScreen<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return await Navigator.of(context).push<T?>(
    MaterialPageRoute(builder: (context) => screen),
  );
}

/// Alias pour [pushScreen] (compatibilité).
Future<T?> pushWidget<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return pushScreen<T>(context, screen);
}

/// Remplace la route actuelle par un nouveau widget.
Future<T?> pushScreenAndReplace<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return await Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => screen),
  );
}

/// Alias pour [pushScreenAndReplace] (compatibilité).
Future<T?> pushWidgetAndReplace<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return pushScreenAndReplace<T>(context, screen);
}

/// Retourne à la route précédente.
void back<T>(BuildContext context, [T? result]) {
  Navigator.of(context).pop(result);
}
