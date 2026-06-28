import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';

class CommonChip extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ChipType type;
  final Widget? avatar;
  final TextStyle? labelStyle;
  final Color? tonalColor;

  const CommonChip({
    super.key,
    required this.label,
    this.labelStyle,
    this.onPressed,
    this.avatar,
    this.tonalColor,
    this.type = ChipType.action,
  });

  @override
  Widget build(BuildContext context) {
    if (type == ChipType.tonal) {
      final colorScheme = Theme.of(context).colorScheme;
      final foreground = tonalColor ?? colorScheme.onSecondaryContainer;
      final background =
          tonalColor?.withValues(alpha: 0.16) ?? colorScheme.secondaryContainer;
      final chip = Chip(
        avatar: avatar,
        backgroundColor: background,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        iconTheme: IconThemeData(color: foreground),
        label: Text(label),
        labelStyle: (labelStyle ?? const TextStyle()).copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      );
      if (onPressed == null) return chip;
      return InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onPressed,
        child: chip,
      );
    }
    if (type == ChipType.delete) {
      return Chip(
        avatar: avatar,
        labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
        clipBehavior: Clip.antiAlias,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onDeleted: onPressed ?? () {},
        labelStyle: labelStyle,
        label: Text(label),
      );
    }
    return ActionChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: avatar,
      clipBehavior: Clip.antiAlias,
      labelPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
      onPressed: onPressed ?? () {},
      labelStyle: labelStyle,
      label: Text(label),
    );
  }
}
