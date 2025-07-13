import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_flutter/screen/client/locataire/home/appart_detail_screen.dart';
import 'package:web_flutter/screen/client/locataire/home/disponibilite.dart';
import 'package:web_flutter/screen/client/locataire/home/explore.dart';
import 'package:web_flutter/screen/client/locataire/home/reservation.dart';
import 'package:web_flutter/screen/client/locataire/home/success_payement.dart';
import 'package:web_flutter/screen/login/login_screen.dart';
import 'package:web_flutter/screen/signup/signup.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/util/payement_add_page.dart';

class RouterManage {
  static void goToLogin(BuildContext context) =>
      context.go(LoginScreen.routeName);

  static void goToSignup(BuildContext context) =>
      push(context, Signup.routeName);

  static void goToExplore(BuildContext context) =>
      context.go(Explore.routeName);

  static void goToAppartDetail(BuildContext context, int id) =>
      push(context, "${Explore.routeName}/${AppartDetailScreen.routeName}/$id");

  static void goToReservation(BuildContext context) => push(
    context,
    "${Explore.routeName}/${AppartDetailScreen.routeName}/${Reservation.routeName}",
  );

  static void goToSuccessfulPayement(BuildContext context) =>
      push(context, "${Explore.routeName}/${SuccessPayement.routeName}");

  static void goToPayment(BuildContext context) => push(
    context,
    "${Explore.routeName}/${AppartDetailScreen.routeName}/${Reservation.routeName}/${PayementAddPage.routeName}",
  );

  static void goToDisponibilite(BuildContext context) => push(
    context,
    "${Explore.routeName}/${AppartDetailScreen.routeName}/${Reservation.routeName}/${Disponibilite.routeName}",
  );
}

Page<dynamic> buildCustomPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Exemple : slide from right (entrer) et slide to right (sortie)
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

Page<void> noTransition(Widget child, GoRouterState state) =>
    NoTransitionPage(key: state.pageKey, child: child);
