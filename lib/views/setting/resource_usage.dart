import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ResourceUsageView extends StatefulWidget {
  const ResourceUsageView({super.key});

  @override
  State<ResourceUsageView> createState() => _ResourceUsageViewState();
}

class _ResourceUsageViewState extends State<ResourceUsageView> {
  HealthStats? _stats;
  bool _sinceConnect = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final now = await app?.getHealthStats();
    if (!mounted) return;
    final baseline = globalState.healthBaseline;
    setState(() {
      _loading = false;
      _sinceConnect = now != null && baseline != null;
      _stats = now == null || baseline == null ? now : now.since(baseline);
    });
  }

  String _duration(int ms) {
    final d = Duration(milliseconds: ms);
    if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
    if (d.inMinutes > 0) return '${d.inMinutes} min ${d.inSeconds % 60} s';
    return '${d.inSeconds} s';
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    return BaseScaffold(
      title: appLocalizations.resourceUsageTitle,
      actions: [
        IconButton(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          tooltip: appLocalizations.refresh,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(appLocalizations.resourceUsageUnavailable),
            )
          : ListView(
              children: [
                ListHeader(
                  title: _sinceConnect
                      ? appLocalizations.resourceUsageSinceConnect
                      : appLocalizations.resourceUsageSinceBoot,
                ),
                _row(
                  Icons.memory,
                  appLocalizations.resourceUsageCpu,
                  _duration(stats.cpuTotalMs),
                  '${_duration(stats.cpuUserMs)} + ${_duration(stats.cpuSystemMs)}',
                ),
                _row(
                  Icons.lock_clock,
                  appLocalizations.resourceUsageWakeLock,
                  _duration(stats.wakeLockMs),
                  appLocalizations.resourceUsageWakeLockDesc,
                ),
                _row(
                  Icons.swap_vert,
                  appLocalizations.resourceUsageTraffic,
                  '${stats.rxBytes.traffic.show} ↓  ${stats.txBytes.traffic.show} ↑',
                  appLocalizations.resourceUsageTrafficDesc,
                ),
                _row(
                  Icons.battery_full,
                  appLocalizations.resourceUsageWindow,
                  _duration(stats.realtimeBatteryMs),
                  appLocalizations.resourceUsageWindowDesc,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Text(
                    appLocalizations.resourceUsageExplainer,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _row(IconData icon, String title, String value, String description) {
    return ListItem(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: Text(value, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
