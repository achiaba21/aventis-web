import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/bottom_nav/bottom_nav_item.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });
  final List<BottomNavItem> items;
  final int currentIndex;
  final void Function(int index, BuildContext context) onTap;

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int selectIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    selectIndex = widget.currentIndex;
    final items = widget.items;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Espacement.paddingInput,
        horizontal: Espacement.paddingInput,
      ),
      color: Style.containerColor2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          items.length,
          (index) => InkWell(
            onTap: () {
              selectIndex = index;
              widget.onTap(index, context);
            },
            child: items[index].copyWith(active: selectIndex == index),
          ),
        ),
      ),
    );
  }
}
