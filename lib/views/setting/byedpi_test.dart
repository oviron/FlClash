import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/byedpi.dart';
import 'package:fl_clash/providers/strategy_test.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _Sort { percent, name, date }

enum _Filter { all, tested, working }

const _kPruneBelow = 40;

class ByeDpiTestView extends ConsumerStatefulWidget {
  const ByeDpiTestView({super.key});

  @override
  ConsumerState<ByeDpiTestView> createState() => _ByeDpiTestViewState();
}

class _ByeDpiTestViewState extends ConsumerState<ByeDpiTestView> {
  _Sort _sort = _Sort.percent;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(strategyTestControllerProvider.notifier).loadCached();
    });
  }

  StrategyTestController get _ctrl =>
      ref.read(strategyTestControllerProvider.notifier);

  List<StrategyTestResult> _view(List<StrategyTestResult> all) {
    final list = all.where((x) {
      return switch (_filter) {
        _Filter.all => true,
        _Filter.tested => x.testedAt != null,
        _Filter.working => x.percent >= _kPruneBelow,
      };
    }).toList();
    list.sort((a, b) {
      return switch (_sort) {
        _Sort.percent => b.percent.compareTo(a.percent),
        _Sort.name => a.label.compareTo(b.label),
        _Sort.date => (b.testedAt ?? 0).compareTo(a.testedAt ?? 0),
      };
    });
    return list;
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _apply(String id) async {
    final split = await _ctrl.apply(id);
    _snack(
      '${appLocalizations.byedpiTestApplied} · '
      'ByeDPI ${split.byedpi} · VPN ${split.vpn}',
    );
  }

  Future<bool> _confirm(String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(appLocalizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(appLocalizations.confirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _remove(StrategyTestResult r) async {
    if (await _confirm('${appLocalizations.byedpiTestRemove}: ${r.label}?')) {
      await _ctrl.removeStrategy(r.id);
    }
  }

  Future<void> _prune() async {
    if (await _confirm(appLocalizations.byedpiTestPrune)) {
      final n = await _ctrl.pruneBelow(_kPruneBelow);
      _snack('−$n');
    }
  }

  Future<void> _reset() async {
    if (await _confirm(appLocalizations.byedpiTestReset)) {
      await _ctrl.resetStrategies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(strategyTestControllerProvider);
    final activeId = ref.watch(byeDpiSettingsProvider).preset;
    final running = st.phase == TestPhase.running;
    final view = _view(st.results);
    final topPercent = st.results.isEmpty
        ? -1
        : st.results.map((e) => e.percent).reduce((a, b) => a > b ? a : b);

    return BaseScaffold(
      title: appLocalizations.byedpiTestTitle,
      actions: [
        PopupMenuButton<_Sort>(
          icon: const Icon(Icons.sort),
          onSelected: (v) => setState(() => _sort = v),
          itemBuilder: (_) => [
            CheckedPopupMenuItem(
              value: _Sort.percent,
              checked: _sort == _Sort.percent,
              child: const Text('%'),
            ),
            CheckedPopupMenuItem(
              value: _Sort.name,
              checked: _sort == _Sort.name,
              child: Text(appLocalizations.byedpiTestSortName),
            ),
            CheckedPopupMenuItem(
              value: _Sort.date,
              checked: _sort == _Sort.date,
              child: Text(appLocalizations.byedpiTestSortDate),
            ),
          ],
        ),
        PopupMenuButton<_Filter>(
          icon: const Icon(Icons.filter_list),
          onSelected: (v) => setState(() => _filter = v),
          itemBuilder: (_) => [
            CheckedPopupMenuItem(
              value: _Filter.all,
              checked: _filter == _Filter.all,
              child: Text(appLocalizations.byedpiTestFilterAll),
            ),
            CheckedPopupMenuItem(
              value: _Filter.tested,
              checked: _filter == _Filter.tested,
              child: Text(appLocalizations.byedpiTestFilterTested),
            ),
            CheckedPopupMenuItem(
              value: _Filter.working,
              checked: _filter == _Filter.working,
              child: const Text('≥$_kPruneBelow%'),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (v) => v == 'prune' ? _prune() : _reset(),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'prune',
              child: Text(appLocalizations.byedpiTestPrune),
            ),
            PopupMenuItem(
              value: 'reset',
              child: Text(appLocalizations.byedpiTestReset),
            ),
          ],
        ),
      ],
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
            child: view.isEmpty
                ? _IdleHint(running: running)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: view.length,
                    itemBuilder: (_, i) => _ResultTile(
                      result: view[i],
                      isWinner: view[i].percent == topPercent,
                      isActive: view[i].id == activeId,
                      onApply: () => _apply(view[i].id),
                      onRetest: running
                          ? null
                          : () => _ctrl.testOne(view[i].id),
                      onRemove: running ? null : () => _remove(view[i]),
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
                  onPressed: () => running ? _ctrl.stop() : _ctrl.run(),
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
  final VoidCallback? onRetest;
  final VoidCallback? onRemove;

  const _ResultTile({
    required this.result,
    required this.isWinner,
    required this.isActive,
    required this.onApply,
    required this.onRetest,
    required this.onRemove,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(appLocalizations.byedpiTestRetest),
              onPressed: onRetest,
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(appLocalizations.byedpiTestRemove),
              onPressed: onRemove,
            ),
            TextButton.icon(
              icon: const Icon(Icons.check, size: 18),
              label: Text(appLocalizations.byedpiTestApply),
              onPressed: onApply,
            ),
          ],
        ),
      ],
    );
  }
}
