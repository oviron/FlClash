// Network Rules v1: edit/create dialog.
//
// Multi-select ChoiceChips for conditions (AND-combined), segmented action
// picker, optional rule name. WifiNamed picker pulls recent SSIDs from
// the recent-ssids provider and offers a free-form text field. The chip
// is gated by `ensureLocationPermissionForSsid` from W4 — the dialog
// will not let the user save a name-rule without permission.

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/network_rules/permission_gate.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/providers/recent_ssids.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditRuleDialog extends ConsumerStatefulWidget {
  final NetworkRule? initial;

  const EditRuleDialog({super.key, this.initial});

  /// Returns the saved rule, or null if the user cancelled. The caller is
  /// responsible for persisting via the repo provider — keeping that out of
  /// the widget makes the dialog reusable for both create and edit.
  static Future<NetworkRule?> show({
    required BuildContext context,
    NetworkRule? initial,
  }) {
    return showDialog<NetworkRule>(
      context: context,
      builder: (_) => EditRuleDialog(initial: initial),
    );
  }

  @override
  ConsumerState<EditRuleDialog> createState() => _EditRuleDialogState();
}

class _EditRuleDialogState extends ConsumerState<EditRuleDialog> {
  late final TextEditingController _nameController;

  bool _hasAnyWifi = false;
  bool _hasAnyCellular = false;
  String? _wifiNamedSsid;
  late NetworkAction _action;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    if (initial == null) {
      // New rule: sensible default — single AnyCellular, action ON.
      _hasAnyCellular = true;
      _action = NetworkAction.turnOn;
    } else {
      _action = initial.action;
      for (final c in initial.conditions) {
        if (c is AnyWifi) _hasAnyWifi = true;
        if (c is AnyCellular) _hasAnyCellular = true;
        if (c is WifiNamed) _wifiNamedSsid = c.ssid;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _hasAnyCondition =>
      _hasAnyWifi || _hasAnyCellular || (_wifiNamedSsid != null);

  Future<void> _pickWifiNamed() async {
    final granted =
        await ensureLocationPermissionForSsid(context, ref);
    if (!granted) return;
    if (!mounted) return;
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => _WifiPickerDialog(
        recent: ref.read(recentSsidsProvider),
        initial: _wifiNamedSsid,
      ),
    );
    if (picked == null) return;
    final trimmed = picked.trim();
    if (trimmed.isEmpty) {
      setState(() => _wifiNamedSsid = null);
      return;
    }
    setState(() => _wifiNamedSsid = trimmed);
  }

  void _save() {
    if (!_hasAnyCondition) return;
    final conditions = <NetworkCondition>[
      if (_wifiNamedSsid != null) WifiNamed(_wifiNamedSsid!),
      if (_hasAnyWifi) const AnyWifi(),
      if (_hasAnyCellular) const AnyCellular(),
    ];
    final rawName = _nameController.text.trim();
    final initial = widget.initial;
    final result = NetworkRule(
      id: initial?.id ?? 0,
      name: rawName.isEmpty ? null : rawName,
      conditions: conditions,
      action: _action,
      priority: initial?.priority ?? 0,
      enabled: initial?.enabled ?? true,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(locationPermissionProvider);
    final hasPermission =
        permissionState == LocationPermissionState.granted;

    return AlertDialog(
      title: Text(
        widget.initial == null
            ? appLocalizations.networkRulesAdd
            : appLocalizations.networkRulesEdit,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: appLocalizations.ruleNameOptional,
              ),
            ),
            const SizedBox(height: 16),
            Text(appLocalizations.networkRulesConditionAtLeastOne),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _WifiNamedChip(
                  ssid: _wifiNamedSsid,
                  hasPermission: hasPermission,
                  onTap: _pickWifiNamed,
                  onClear: () => setState(() => _wifiNamedSsid = null),
                ),
                FilterChip(
                  selected: _hasAnyWifi,
                  avatar: const Icon(Icons.wifi, size: 18),
                  label: Text(
                    appLocalizations.networkRulesConditionAnyWifi,
                  ),
                  onSelected: (v) => setState(() => _hasAnyWifi = v),
                ),
                FilterChip(
                  selected: _hasAnyCellular,
                  avatar:
                      const Icon(Icons.signal_cellular_alt, size: 18),
                  label: Text(
                    appLocalizations.networkRulesConditionAnyCellular,
                  ),
                  onSelected: (v) => setState(() => _hasAnyCellular = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(appLocalizations.networkRulesFallback),
            const SizedBox(height: 8),
            SegmentedButton<NetworkAction>(
              segments: [
                ButtonSegment(
                  value: NetworkAction.turnOn,
                  label: Text(
                    appLocalizations.networkRulesActionTurnOn,
                  ),
                ),
                ButtonSegment(
                  value: NetworkAction.turnOff,
                  label: Text(
                    appLocalizations.networkRulesActionTurnOff,
                  ),
                ),
                ButtonSegment(
                  value: NetworkAction.keep,
                  label: Text(
                    appLocalizations.networkRulesActionKeep,
                  ),
                ),
              ],
              selected: {_action},
              onSelectionChanged: (set) {
                setState(() => _action = set.first);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: _hasAnyCondition ? _save : null,
          child: Text(appLocalizations.save),
        ),
      ],
    );
  }
}

class _WifiNamedChip extends StatelessWidget {
  final String? ssid;
  final bool hasPermission;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _WifiNamedChip({
    required this.ssid,
    required this.hasPermission,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasValue = ssid != null;
    final showWarning = !hasPermission;
    final label = hasValue
        ? '${appLocalizations.networkRulesConditionWifiNamed}: $ssid'
        : appLocalizations.networkRulesConditionWifiNamed;
    final subLabel = showWarning
        ? '$label (${appLocalizations.permissionRequiredHint})'
        : label;
    return InputChip(
      avatar: Icon(
        showWarning ? Icons.warning_amber : Icons.wifi,
        size: 18,
        color: showWarning ? scheme.error : null,
      ),
      label: Text(subLabel),
      selected: hasValue,
      onPressed: onTap,
      onDeleted: hasValue ? onClear : null,
    );
  }
}

class _WifiPickerDialog extends StatefulWidget {
  final List<String> recent;
  final String? initial;

  const _WifiPickerDialog({required this.recent, this.initial});

  @override
  State<_WifiPickerDialog> createState() => _WifiPickerDialogState();
}

class _WifiPickerDialogState extends State<_WifiPickerDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(appLocalizations.networkRulesConditionWifiNamed),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'SSID',
              ),
              onSubmitted: (value) {
                Navigator.of(context).pop(value.trim());
              },
            ),
            if (widget.recent.isNotEmpty) ...[
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.recent.length,
                  itemBuilder: (_, index) {
                    final item = widget.recent[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 18),
                      title: Text(item),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim()),
          child: Text(appLocalizations.save),
        ),
      ],
    );
  }
}
