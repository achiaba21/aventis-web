import 'package:flutter/material.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Séparateur de date centré entre 2 groupes de messages du
/// `MessagingThreadScreen`.
class ThreadDateSeparator extends StatelessWidget {
  final String label;

  const ThreadDateSeparator({super.key, this.label = "Aujourd'hui"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
      ),
    );
  }
}
