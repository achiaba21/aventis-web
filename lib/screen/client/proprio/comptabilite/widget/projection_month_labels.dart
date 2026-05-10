import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/projection_point.dart';
import 'package:asfar/theme/app_colors.dart';

/// Row de labels mois sous le `ProjectionChart`.
///
/// Met en évidence le mois courant (`isCurrent: true`) avec accent or
/// bold-700, les autres en text3 weight-400.
class ProjectionMonthLabels extends StatelessWidget {
  final List<ProjectionPoint> points;

  const ProjectionMonthLabels({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < points.length; i++)
          Expanded(
            child: Text(
              points[i].monthShort,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: points[i].isCurrent
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: points[i].isCurrent
                    ? AppColors.accent
                    : AppColors.text3,
              ),
            ),
          ),
      ],
    );
  }
}
