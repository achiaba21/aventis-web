import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/container/block2.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartBottom extends StatelessWidget {
  const AppartBottom({super.key, this.onPress});
  final void Function()? onPress;

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final req = appData.req;
    final plage = req?.plage;
    final prix = req?.appartement?.prix ?? 0;
    final color = Style.containerColor3;
    deboger(plage);
    return Block2(
      padding: EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextSeed("$prix FCFA / nuit", color: color),
              if (plage != null)
                TextSeed(formateRangeTimeShort(plage), color: color),
            ],
          ),
          Spacer(),
          PlainButton(value: "Réserver", onPress: onPress),
        ],
      ),
    );
  }
}
