import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

/// Usage progress bar with a semantic color (primary → warn → over-limit) and
/// an optional caption. Drives profile, provider and subscription quota UIs.
class QuotaBar extends StatelessWidget {
  final double value;
  final String? label;
  final double warnAt;
  final double minHeight;

  const QuotaBar({
    super.key,
    required this.value,
    this.label,
    this.warnAt = 0.6,
    this.minHeight = 6,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(minHeight / 2),
          child: LinearProgressIndicator(
            minHeight: minHeight,
            value: value.clamp(0.0, 1.0),
            color: quotaColor(scheme, value, warnAt: warnAt),
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
