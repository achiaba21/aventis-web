import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';

class StartRank extends StatefulWidget {
  const StartRank({super.key, this.notesMax = 5, this.onNote});
  final int notesMax;
  final void Function(int note)? onNote;

  @override
  State<StartRank> createState() => _StartRankState();
}

class _StartRankState extends State<StartRank> {
  int indexHover = -1;
  int selected = -1;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit:
          (event) => setState(() {
            indexHover = selected;
          }),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Espacement.gapSection,
        children: [
          ...List.generate(widget.notesMax, (index) {
            return MouseRegion(
              onEnter: (event) {
                setState(() {
                  indexHover = index;
                });
              },
              child: IconBoutton(
                icon: Icons.star,
                size: 48,
                color: index <= indexHover ? Colors.amber : null,
                onPressed: () {
                  if (widget.onNote != null) {
                    selected = index;
                    indexHover = selected;
                    widget.onNote!(index);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
