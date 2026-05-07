import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/screen/client/locataire/booking/booking.dart';
import 'package:asfar/screen/client/locataire/favorite/favorite.dart';
import 'package:asfar/screen/client/locataire/home/explore.dart';
import 'package:asfar/screen/client/locataire/inbox/inbox.dart';
import 'package:asfar/screen/client/locataire/profile/profile.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/notification_utils.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav.dart';
import 'package:asfar/widget/bottom_nav/bottom_nav_item.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  List<BottomNavItem> _buildMenu(int unreadCount) {
    return [
      BottomNavItem(text: "Explore", image: Icons.search),
      BottomNavItem(text: "Favorite", image: Icons.favorite_outline),
      BottomNavItem(text: "Bookings", svgPath: "assets/icon/booking.svg"),
      BottomNavItem(text: "Inbox", svgPath: "assets/icon/inbox.svg", badgeCount: unreadCount),
      BottomNavItem(text: "Profile", image: Icons.person),
    ];
  }

  final List<Widget> _pages = [
    Explore(),
    Favorite(),
    Booking(),
    Inbox(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: _pages[_currentIndex]),
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final unreadCount = NotificationUtils.getUnreadCount(state);
                return BottomNav(
                  items: _buildMenu(unreadCount),
                  currentIndex: _currentIndex,
                  onTap: onTap,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void onTap(int index, BuildContext context) {
    setState(() {
      _currentIndex = index;
    });
  }
}
