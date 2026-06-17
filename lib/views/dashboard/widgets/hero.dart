import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/group_chain.dart';
import 'package:fl_clash/views/proxies/node_selector_sheet.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// The resting-state home: a connect button, status, the active node pill, live
/// speed and the outbound-mode segment. The customizable widget grid lives
/// below it, under "details".
class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 8),
        _ConnectButton(),
        SizedBox(height: 14),
        _StatusLine(),
        SizedBox(height: 12),
        _NodePill(),
        SizedBox(height: 22),
        _SpeedRow(),
        SizedBox(height: 14),
        _ModeSegment(),
      ],
    );
  }
}

class _ConnectButton extends ConsumerWidget {
  const _ConnectButton();

  void _toggle(WidgetRef ref) {
    final next = !ref.read(isStartProvider);
    debouncer.call(FunctionTag.updateStatus, () {
      appController.updateStatus(next, isInit: !ref.read(initProvider));
    }, duration: commonDuration);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(coreStatusProvider);
    final scheme = context.colorScheme;
    final connected = status == CoreStatus.connected;
    const size = 168.0;
    return GestureDetector(
      onTap: () => _toggle(ref),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: connected ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: size - 16,
                height: size - 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: scheme.success.opacity50,
                      blurRadius: 34,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: connected
                      ? scheme.success.opacity50
                      : scheme.outlineVariant,
                  width: 2,
                ),
              ),
            ),
            Container(
              width: size - 24,
              height: size - 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: connected
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHigh,
              ),
              alignment: Alignment.center,
              child: status == CoreStatus.connecting
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: scheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.power_settings_new,
                      size: 56,
                      color: connected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends ConsumerWidget {
  const _StatusLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(coreStatusProvider);
    final label = switch (status) {
      CoreStatus.connected => appLocalizations.connected,
      CoreStatus.connecting => appLocalizations.connecting,
      CoreStatus.disconnected => appLocalizations.disconnected,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (status == CoreStatus.connected)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              utils.getTimeText(ref.watch(runTimeProvider)),
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
      ],
    );
  }
}

class _NodePill extends ConsumerWidget {
  const _NodePill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final group = ref.watch(
      currentGroupsStateProvider.select((s) => primaryGroup(s.value)),
    );
    if (group == null) return const SizedBox.shrink();
    final selected = ref.watch(getProxyNameProvider(group.name));
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      shape: StadiumBorder(side: BorderSide(color: scheme.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showSheet(
          context: context,
          props: const SheetProps(isScrollControlled: true),
          builder: (_, type) =>
              NodeSelectorSheet(type: type, groupName: group.name),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.vpn_key, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                selected == null || selected.isEmpty
                    ? group.name
                    : '${group.name} · $selected',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(Icons.unfold_more, size: 18, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeedRow extends ConsumerWidget {
  const _SpeedRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(trafficsProvider).list;
    final last = list.isEmpty ? const Traffic() : list.last;
    return Row(
      children: [
        Expanded(
          child: _SpeedTile(
            icon: Icons.south,
            value: last.down.traffic.show,
            label: appLocalizations.download,
            color: context.colorScheme.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SpeedTile(
            icon: Icons.north,
            value: last.up.traffic.show,
            label: appLocalizations.upload,
            color: context.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _SpeedTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SpeedTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  label,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends ConsumerWidget {
  const _ModeSegment();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(patchClashConfigProvider.select((s) => s.mode));
    final scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: SizedBox(
        height: 40,
        child: CommonTabBar<Mode>(
          padding: EdgeInsets.zero,
          groupValue: mode,
          thumbColor: scheme.secondaryContainer,
          onValueChanged: (value) {
            if (value != null) appController.changeMode(value);
          },
          children: {
            for (final m in Mode.values)
              m: Container(
                alignment: Alignment.center,
                child: Text(
                  Intl.message(m.name),
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: m == mode ? scheme.onSecondaryContainer : null,
                  ),
                ),
              ),
          },
        ),
      ),
    );
  }
}
