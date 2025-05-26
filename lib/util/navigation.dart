import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_flutter/util/function.dart';

Future<void> pushAndRemoveAll(BuildContext context, Widget screen) async {
  await Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => screen),
    (route) => false,
  );
}

Future<T?> pushWidget<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return await Navigator.of(
    context,
  ).push<T?>(MaterialPageRoute(builder: (context) => screen));
}

void push(BuildContext context, String path, {Object? extra}) {
  final currentLocation = GoRouterState.of(context).uri.path;
  deboger([currentLocation, path]);
  if (currentLocation != path) {
    GoRouter.of(context).go(path, extra: extra);
  }
}

void relativePush(BuildContext context, String subPath, {Object? extra}) {
  final currentLocation = GoRouterState.of(context).uri.path;
  deboger([currentLocation, subPath, '$currentLocation/$subPath']);
  if (currentLocation != subPath) {
    GoRouter.of(context).go('$currentLocation/$subPath', extra: extra);
  }
}

Future<T?> pushWidgetAndReplace<T extends Object?>(
  BuildContext context,
  Widget screen,
) async {
  return await Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (context) => screen));
}

void back<T>(BuildContext context, [T? result]) {
  return Navigator.of(context).pop(result);
}
