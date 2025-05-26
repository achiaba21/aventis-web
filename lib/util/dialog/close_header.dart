import 'package:flutter/material.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';

class CloseHeader extends StatelessWidget {
  const CloseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Style.containerColor3,
        boxShadow: [
          BoxShadow(
            color: Style.shadowColor,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconBoutton(icon: Icons.close, onPressed: () => back(context)),
        ],
      ),
    );
  }
}
