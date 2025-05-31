import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/screen/client/locataire/booking/add_comment.dart';
import 'package:web_flutter/screen/client/locataire/booking/book_screen.dart';
import 'package:web_flutter/screen/client/locataire/booking/booking.dart';
import 'package:web_flutter/screen/client/locataire/booking/history.dart';
import 'package:web_flutter/screen/client/locataire/favorite/favorite.dart';
import 'package:web_flutter/screen/client/locataire/home/appart_detail_screen.dart';
import 'package:web_flutter/screen/client/locataire/home/disponibilite.dart';
import 'package:web_flutter/screen/client/locataire/home/explore.dart';
import 'package:web_flutter/screen/client/locataire/home/home.dart';
import 'package:web_flutter/screen/client/locataire/home/reservation.dart';
import 'package:web_flutter/screen/client/locataire/home/success_payement.dart';
import 'package:web_flutter/screen/client/locataire/inbox/inbox.dart';
import 'package:web_flutter/screen/client/locataire/profile/profile.dart';
import 'package:web_flutter/screen/login/login_screen.dart';
import 'package:web_flutter/screen/signup/signup.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/payement_add_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "root");
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: "Home");

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: LoginScreen.routeName,
  routes: [
    GoRoute(
      path: LoginScreen.routeName,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(path: Signup.routeName, builder: (context, state) => Signup()),
    ShellRoute(
      navigatorKey: _homeNavigatorKey,
      builder: (context, state, child) => Home(child: child),
      routes: [
        GoRoute(
          path: Explore.routeName,
          builder: (context, state) => Explore(),
          routes: [
            GoRoute(
              path: "${AppartDetailScreen.routeName}/:appartId",
              parentNavigatorKey: _rootNavigatorKey,
              builder:
                  (context, state) => AppartDetailScreen(
                    int.tryParse(state.pathParameters["appartId"] ?? "0") ?? 0,
                  ),
              routes: [
                GoRoute(
                  path: Reservation.routeName,
                  redirect: (context, state) {
                    AppData app = Provider.of<AppData>(context, listen: false);
                    final reservation = app.req;
                    deboger([state.path, state.fullPath, state.uri]);
                    if (reservation == null ||
                        reservation.appartement == null) {
                      return Explore.routeName;
                    }
                    return null;
                  },
                  builder: (context, state) => Reservation(),
                  parentNavigatorKey: _rootNavigatorKey,
                  routes: [
                    GoRoute(
                      path: PayementAddPage.routeName,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        deboger(state.pathParameters);
                        return PayementAddPage();
                      },
                      routes: [],
                    ),
                    GoRoute(
                      path: Disponibilite.routeName,
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) {
                        deboger(state.pathParameters);
                        return Disponibilite();
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: SuccessPayement.routeName,
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => SuccessPayement(),
            ),
          ],
        ),
        GoRoute(
          path: Favorite.routeName,
          builder: (context, state) => Favorite(),
        ),
        GoRoute(
          path: Booking.routeName,
          builder: (context, state) => Booking(),

          routes: [
            GoRoute(
              path: History.routeName,
              builder: (context, state) => History(),
            ),
            GoRoute(
              path: BookScreen.routeName,
              parentNavigatorKey: _rootNavigatorKey,
              redirect: redirectBookNote,
              builder: (context, state) {
                final app = Provider.of<AppData>(context, listen: false);
                return BookScreen(app.selectedReservation!);
              },
              routes: [
                GoRoute(
                  path: AddComment.routeName,
                  redirect: redirectBookNote,
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) => AddComment(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: Inbox.routeName, builder: (context, state) => Inbox()),
        GoRoute(
          path: Profile.routeName,
          builder: (context, state) => Profile(),
        ),
      ],
    ),
  ],
);

FutureOr<String?> redirectBookNote(BuildContext context, GoRouterState state) {
  final app = Provider.of<AppData>(context, listen: false);
  if (app.selectedReservation == null) {
    deboger(["book redirect", state.fullPath]);
    return Booking.routeName;
  }
  return null;
}
