import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_flutter/screen/client/locataire/booking/booking.dart';
import 'package:web_flutter/screen/client/locataire/favorite/favorite.dart';
import 'package:web_flutter/screen/client/locataire/home/explore.dart';
import 'package:web_flutter/screen/client/locataire/inbox/inbox.dart';
import 'package:web_flutter/screen/client/locataire/profile/profile.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/bottom_nav/bottom_nav.dart';
import 'package:web_flutter/widget/bottom_nav/bottom_nav_item.dart';

class Home extends StatefulWidget {
  static final routeName = "/";
  const Home({super.key, required this.child});
  final Widget child;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  final menu = [
    BottomNavItem(text: "Explore", image: Icons.search),
    BottomNavItem(text: "Favorite", image: Icons.favorite_outline),
    BottomNavItem(text: "Bookings", svgPath: "assets/icon/booking.svg"),
    BottomNavItem(text: "Inbox", svgPath: "assets/icon/inbox.svg"),
    BottomNavItem(text: "Profile", image: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Style.containerColor3,
        body: Column(
          children: [
            Expanded(child: widget.child),
            BottomNav(items: menu, currentIndex: _currentIndex(), onTap: onTap),
          ],
        ),
      ),
    );
  }

  void onTap(int index, BuildContext contex) {
    switch (index) {
      case 0:
        push(contex, Explore.routeName);
        break;
      case 1:
        push(contex, Favorite.routeName);
        break;
      case 2:
        push(contex, Booking.routeName);
        break;
      case 3:
        push(contex, Inbox.routeName);
        break;
      case 4:
        push(contex, Profile.routeName);
        break;
    }
  }

  int _currentIndex() {
    final String locaton = GoRouterState.of(context).uri.path;
    if (locaton.startsWith(Explore.routeName)) {
      return 0;
    }
    if (locaton.startsWith(Favorite.routeName)) {
      return 1;
    }
    if (locaton.startsWith(Booking.routeName)) {
      return 2;
    }
    if (locaton.startsWith(Inbox.routeName)) {
      return 3;
    }
    if (locaton.startsWith(Profile.routeName)) {
      return 4;
    }
    return 0;
  }
}
