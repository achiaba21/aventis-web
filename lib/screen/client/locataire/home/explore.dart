import 'package:flutter/material.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_item.dart';
import 'package:web_flutter/util/dialog/open_dialog.dart';
import 'package:web_flutter/util/dummy.dart';
import 'package:web_flutter/widget/bottom_dialogue/filter_option.dart';
import 'package:web_flutter/widget/input/input_search.dart';

class Explore extends StatelessWidget {
  static final routeName = "/explore";
  const Explore({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InputSearch(onPressed: () => opPenFilter(context)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: apparts.map((e) => AppartItem(e)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void opPenFilter(BuildContext context) {
    dialogBottomSheet(context, FilterOption(), hide: true);
  }
}
