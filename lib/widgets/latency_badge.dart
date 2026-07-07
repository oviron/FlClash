import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

// null renders nothing; value 0 is the in-progress sentinel (spinner); value < 0
// is a timeout. Latency shows as tabular-figure ms in a semantic color
// ([delayColor]).
class LatencyBadge extends StatelessWidget {
  final int? delay;
  final bool showUnit;

  const LatencyBadge(this.delay, {super.key, this.showUnit = true});

  @override
  Widget build(BuildContext context) {
    if (delay == null) return const SizedBox.shrink();
    if (delay == 0) {
      final size = context.textTheme.labelMedium?.fontSize ?? 12;
      return SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final style = context.textTheme.labelMedium?.copyWith(
      color: delayColor(context.colorScheme, delay),
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final text = delay! < 0
        ? appLocalizations.detectionTimeout
        : (showUnit ? '$delay ms' : '$delay');
    return Text(text, style: style);
  }
}
