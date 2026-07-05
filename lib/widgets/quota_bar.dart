import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

/// Usage progress bar with a semantic color (primary → warn → over-limit) and
/// an optional caption. Currently drives the subscription quota UI.
class QuotaBar extends StatelessWidget {
  final double value;
  final String? label;
  final double warnAt;
  final double minHeight;

  const QuotaBar({
    super.key,
    required this.value,
    this.label,
    this.warnAt = kQuotaWarnAt,
    this.minHeight = 6,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    // Defend against a hostile panel: NaN/Infinity/negative from used/total.
    final v = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(minHeight / 2),
          child: LinearProgressIndicator(
            minHeight: minHeight,
            value: v,
            color: quotaColor(scheme, v, warnAt: warnAt),
            backgroundColor: scheme.primary.opacity15,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label!, style: context.textTheme.labelMedium?.toLight),
        ],
      ],
    );
  }
}
