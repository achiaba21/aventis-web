import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Header custom du `MessagingThreadScreen` : back + avatar + nom (avec
/// shield certifié optionnel) + sub-text + bouton téléphone.
class ThreadCustomHeader extends StatelessWidget {
  final String who;
  final String sub;
  final bool certified;
  final VoidCallback? onCall;

  const ThreadCustomHeader({
    super.key,
    required this.who,
    required this.sub,
    this.certified = false,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: Row(
        children: [
          IconBoutton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => back(context),
          ),
          const SizedBox(width: 8),
          UserAvatar(name: who, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        who,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (certified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_user_outlined,
                          size: 12, color: AppColors.accent),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: AppTextStyles.small.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconBoutton(
            icon: Icons.phone_outlined,
            onPressed: onCall,
          ),
        ],
      ),
    );
  }
}
