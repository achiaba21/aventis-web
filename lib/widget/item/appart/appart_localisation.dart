import 'package:flutter/material.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AppartLocalisation extends StatelessWidget {
  const AppartLocalisation({super.key, this.address});
  final Address? address;

  @override
  Widget build(BuildContext context) {
    return TextSeed(address?.description);
  }
}
