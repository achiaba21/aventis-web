import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation_timeline_event.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/reservation_timeline_builder.dart';

/// Ligne d'événement dans la timeline de la page détail réservation.
///
/// Dot 10×10 cercle plein coloré selon sémantique (vert/rouge/gris) + trait
/// vertical 1px line vers l'événement suivant + label + date (mono) + motif
/// éventuel sur ligne 2.
class ReservationDetailTimelineRow extends StatelessWidget {
  final ReservationTimelineEvent event;
  final bool isLast;

  const ReservationDetailTimelineRow({
    super.key,
    required this.event,
    this.isLast = false,
  });

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  Color _dotColor() {
    if (event.isNegative) return AppColors.danger;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final label = ReservationTimelineBuilder.labelOf(event.type);
    final date = _formatDate(event.date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dotColor(),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.line,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (date != null)
                        Text(
                          date,
                          style: AppTextStyles.mono(AppTextStyles.small.copyWith(
                            fontSize: 12,
                            color: AppColors.text3,
                          )),
                        ),
                    ],
                  ),
                  if (event.motif != null && event.motif!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Motif : ${event.motif}',
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
