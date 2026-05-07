import 'package:flutter/material.dart';
import 'package:asfar/widget/header/greeting_header.dart';

class AppartementHeader extends StatelessWidget {
  const AppartementHeader({
    super.key,
    required this.userName,
    required this.onAddListing,
  });

  final String userName;
  final VoidCallback onAddListing;

  @override
  Widget build(BuildContext context) {
    return GreetingHeader(
      userName: userName,
      buttonText: "Add new listing",
      onButtonPressed: onAddListing,
    );
  }
}