import 'package:flutter/material.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/dialog/close_header.dart';

void dialogBottomSheet(
  BuildContext context,
  Widget child, {
  bool hide = false,
}) {
  showBottomSheet(
    backgroundColor: Style.containerColor3,
    context: context,
    builder:
        (context) => Column(
          children: [if (!hide) CloseHeader(), Expanded(child: child)],
        ),
  );
}
