import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_item.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/util/dummy.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Favorite extends StatelessWidget {
  static final String routeName = "/favoris";

  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);
    final favs = appData.favorites;

    return Scaffold(
      appBar: AppBar(title: TextSeed("Favories")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            favs.isEmpty
                ? Center(child: TextSeed("Aucun Element"))
                : SingleChildScrollView(
                  child: Column(
                    children:
                        favs
                            .map(
                              (e) => AppartItem(
                                apparts.firstWhere(
                                  (element) => element.id == e,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
      ),
    );
  }
}
