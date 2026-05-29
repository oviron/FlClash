import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/providers/strategy_test.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ByeDpiTestView extends ConsumerStatefulWidget {
  const ByeDpiTestView({super.key});

  @override
  ConsumerState<ByeDpiTestView> createState() => _ByeDpiTestViewState();
}

class _ByeDpiTestViewState extends ConsumerState<ByeDpiTestView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(strategyTestControllerProvider.notifier).loadCached();
    });
  }

  Future<void> _apply(String id) async {
    final ctrl = ref.read(strategyTestControllerProvider.notifier);
    final split = await ctrl.apply(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${appLocalizations.byedpiTestApplied} · '
          'ByeDPI ${split.byedpi} · VPN ${split.vpn}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(strategyTestControllerProvider);
    final ctrl = ref.read(strategyTestControllerProvider.notifier);
    final activeId = ref.watch(byeDpiSettingsProvider).preset;
    final running = st.phase == TestPhase.running;

    return BaseScaffold(
      title: appLocalizations.byedpiTestTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (running) ...[
            LinearProgressIndicator(
              value: st.total > 0 ? st.completed / st.total : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                '${appLocalizations.byedpiTestProgress} ${st.completed}/${st.total}'
                '${st.currentLabel.isNotEmpty ? ' · ${st.currentLabel}' : ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: Text(
                appLocalizations.byedpiTestVpnPaused,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
          if (st.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                st.error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          Expanded(
            child: st.results.isEmpty
                ? _IdleHint(running: running)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: st.results.length,
                    itemBuilder: (_, i) => _ResultTile(
                      result: st.results[i],
                      isWinner: !running && i == 0,
                      isActive: st.results[i].id == activeId,
                      onApply: () => _apply(st.results[i].id),
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: Icon(running ? Icons.stop : Icons.play_arrow),
                  label: Text(
                    running
                        ? appLocalizations.byedpiTestStop
                        : appLocalizations.byedpiTestRun,
                  ),
                  onPressed: () => running ? ctrl.stop() : ctrl.run(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdleHint extends StatelessWidget {
  final bool running;
  const _IdleHint({required this.running});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          running ? '' : appLocalizations.byedpiTestHint,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final StrategyTestResult result;
  final bool isWinner;
  final bool isActive;
  final VoidCallback onApply;

  const _ResultTile({
    required this.result,
    required this.isWinner,
    required this.isActive,
    required this.onApply,
  });

  Color _color(BuildContext context) {
    if (result.percent >= 80) return Colors.green;
    if (result.percent >= 40) return Colors.amber;
    return Theme.of(context).colorScheme.error;
  }

  String? _testedAt() {
    final ms = result.testedAt;
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
      ms,
    ).toLocal().toString().split('.').first;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final tested = _testedAt();
    return ExpansionTile(
      leading: isWinner
          ? Icon(Icons.emoji_events, color: color)
          : const Icon(Icons.dns_outlined),
      title: Row(
        children: [
          Flexible(child: Text(result.label)),
          if (isActive) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: result.percent / 100,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
          if (tested != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                tested,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
      trailing: Text(
        '${result.percent}%',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: [
        for (final s in result.sites)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    s.site,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${s.ok}/${s.total}',
                  style: TextStyle(
                    fontSize: 12,
                    color: s.ok == s.total
                        ? Colors.green
                        : (s.ok == 0
                              ? Theme.of(context).colorScheme.error
                              : Colors.amber),
                  ),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            icon: const Icon(Icons.check),
            label: Text(appLocalizations.byedpiTestApply),
            onPressed: onApply,
          ),
        ),
      ],
    );
  }
}
