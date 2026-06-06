import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum StatusBadgeTone { success, danger, warning, neutral, cyan, purple }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeTone tone;
  final bool dot;

  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.neutral,
    this.dot = true,
  });

  Color get _color {
    switch (tone) {
      case StatusBadgeTone.success:
        return AppColors.success;
      case StatusBadgeTone.danger:
        return AppColors.danger;
      case StatusBadgeTone.warning:
        return AppColors.warning;
      case StatusBadgeTone.cyan:
        return AppColors.cyan;
      case StatusBadgeTone.purple:
        return AppColors.purpleAccent;
      case StatusBadgeTone.neutral:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
