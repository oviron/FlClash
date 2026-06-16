import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/profile_routing/rule_codec.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kDefault = '';
const _kDirect = 'DIRECT';
const _kReject = 'REJECT';
const _kGlobal = 'GLOBAL';

/// App-centric per-app routing: each app maps to a `PROCESS-NAME,<pkg>,<target>`
/// rule live-mirrored into the profile YAML. Advanced matchers and non-process
/// rules live in the power table (separate). The matcher here is always
/// PROCESS-NAME keyed on the package name.
class AppRoutingView extends ConsumerStatefulWidget {
  final int profileId;

  const AppRoutingView({super.key, required this.profileId});

  @override
  ConsumerState<AppRoutingView> createState() => _AppRoutingViewState();
}

class _AppRoutingViewState extends ConsumerState<AppRoutingView> {
  List<RoutingRule> _rules = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(appController.getPackages());
    _load();
  }

  Future<void> _load() async {
    final rules = await appController.readRoutingRules(widget.profileId);
    if (!mounted) return;
    setState(() {
      _rules = rules;
      _loading = false;
    });
  }

  // PROCESS-NAME rules keyed by package; the app-centric surface owns these.
  Map<String, TypedRule> get _byPackage {
    final map = <String, TypedRule>{};
    for (final r in _rules) {
      if (r is TypedRule && r.action == RuleAction.PROCESS_NAME) {
        map[r.value] = r;
      }
    }
    return map;
  }

  Future<void> _setTarget(String packageName, String target) async {
    final next = List<RoutingRule>.of(_rules);
    next.removeWhere(
      (r) =>
          r is TypedRule &&
          r.action == RuleAction.PROCESS_NAME &&
          r.value == packageName,
    );
    if (target != _kDefault) {
      next.insert(
        0,
        TypedRule(
          action: RuleAction.PROCESS_NAME,
          value: packageName,
          target: target,
        ),
      );
    }
    setState(() => _rules = next);
    final error = await appController.writeRoutingRules(widget.profileId, next);
    if (error != null && mounted) {
      context.showNotifier(error);
      await _load();
    }
  }

  Future<void> _pickTarget(Package package) async {
    final current = _byPackage[package.packageName]?.target ?? _kDefault;
    final groups = ref.read(currentGroupsStateProvider).value;
    final options = <({String value, String label})>[
      (value: _kDefault, label: appLocalizations.appRoutingDefault),
      (value: _kDirect, label: _kDirect),
      (value: _kReject, label: _kReject),
      (value: _kGlobal, label: _kGlobal),
      for (final g in groups) (value: g.name, label: g.name),
    ];
    final picked = await showSheet<String>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => AdaptiveSheetScaffold(
        type: type,
        title: package.label,
        body: ListView(
          shrinkWrap: true,
          children: [
            for (final o in options)
              ListTile(
                title: Text(o.label),
                trailing: o.value == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(o.value),
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) {
      await _setTarget(package.packageName, picked);
    }
  }

  Widget _targetChip(String? target) {
    final label = target ?? appLocalizations.appRoutingDefault;
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }

  @override
  Widget build(BuildContext context) {
    final findProcessOff =
        ref.watch(patchClashConfigProvider.select((s) => s.findProcessMode)) ==
        FindProcessMode.off;
    final packages = ref
        .watch(packagesProvider)
        .where((p) => !p.system)
        .sortedByLabel();
    final byPackage = _byPackage;
    return CommonScaffold(
      title: appLocalizations.appRouting,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (findProcessOff)
                  MaterialBanner(
                    leading: const Icon(Icons.warning_amber),
                    content: Text(appLocalizations.appRoutingProcessOff),
                    actions: const [SizedBox.shrink()],
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: packages.length,
                    itemExtent: 72,
                    itemBuilder: (_, index) {
                      final package = packages[index];
                      final rule = byPackage[package.packageName];
                      return ListTile(
                        leading: SizedBox(
                          width: 44,
                          height: 44,
                          child: FutureBuilder<ImageProvider?>(
                            future: app?.getPackageIcon(package.packageName),
                            builder: (_, snapshot) => snapshot.data == null
                                ? const SizedBox()
                                : Image(
                                    image: snapshot.data!,
                                    gaplessPlayback: true,
                                  ),
                          ),
                        ),
                        title: Text(
                          package.label,
                          maxLines: 1,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: Text(
                          package.packageName,
                          maxLines: 1,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: _targetChip(rule?.target),
                        onTap: () => _pickTarget(package),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

extension on Iterable<Package> {
  List<Package> sortedByLabel() {
    final list = toList();
    list.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return list;
  }
}
