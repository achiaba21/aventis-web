import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';

class EarnMoneyCard extends StatelessWidget {
  const EarnMoneyCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.pink[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.home_work_outlined,
              color: Colors.pink[700],
              size: 24,
            ),
          ),
          SizedBox(width: Espacement.gapSection),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextSeed(
                  "Earn money from you extra space",
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4),
                InkWell(
                  onTap: onTap,
                  child: TextSeed(
                    "How it works",
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.pink[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
