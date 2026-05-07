import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class CounterField extends StatelessWidget {
  const CounterField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.minValue = 0,
    this.maxValue = 20,
  });

  final String label;
  final IconData icon;
  final int value;
  final Function(int) onChanged;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Espacement.gapSection),
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingBloc,
        vertical: Espacement.paddingBloc / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.accent,
            size: 24,
          ),
          SizedBox(width: Espacement.gapSection),
          Expanded(
            child: TextSeed(
              label,
              fontSize: 16,
              color: AppColors.background,
            ),
          ),
          Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onPressed: value > minValue ? () => onChanged(value - 1) : null,
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: TextSeed(
                  value.toString(),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.background,
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onPressed: value < maxValue ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: onPressed != null ? AppColors.accent : AppColors.textMuted,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: onPressed != null ? AppColors.accent : AppColors.textMuted,
          size: 20,
        ),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}