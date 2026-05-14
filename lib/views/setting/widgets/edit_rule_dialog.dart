import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/network_rules/permission_gate.dart';
import 'package:fl_clash/network_rules/probe.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/providers/recent_ssids.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ConditionKind { wifiNamed, anyWifi, anyCellular }

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

  late _ConditionKind _conditionKind;
  String? _wifiNamedSsid;
  late NetworkAction _action;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    if (initial == null) {
      // New rule: sensible default — cellular triggers VPN on.
      _conditionKind = _ConditionKind.anyCellular;
      _action = NetworkAction.turnOn;
    } else {
      // Pre-fill from the rule. Conditions are stored as a list for forward
      // compat but the UI treats it as a single condition: take the first
      // recognised kind.
      final firstCondition = initial.condition;
      if (firstCondition is WifiNamed) {
        _conditionKind = _ConditionKind.wifiNamed;
        _wifiNamedSsid = firstCondition.ssid;
      } else if (firstCondition is AnyWifi) {
        _conditionKind = _ConditionKind.anyWifi;
      } else {
        _conditionKind = _ConditionKind.anyCellular;
      }
      // Legacy `keep` actions degrade to turnOn so the user can still edit
      // and re-save the rule under the new two-action model.
      _action = initial.action == NetworkAction.keep
          ? NetworkAction.turnOn
          : initial.action;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_conditionKind == _ConditionKind.wifiNamed &&
        (_wifiNamedSsid == null || _wifiNamedSsid!.isEmpty)) {
      return false;
    }
    return true;
  }

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
    // Sanitize through the probe path so a copy-pasted `"home"` matches
    // what the runtime reads.
    final sanitized = NetworkProbe.sanitizeSsid(picked);
    setState(() => _wifiNamedSsid = sanitized);
  }

  void _save() {
    if (!_isValid) return;
    final NetworkCondition condition;
    switch (_conditionKind) {
      case _ConditionKind.wifiNamed:
        condition = WifiNamed(_wifiNamedSsid!);
      case _ConditionKind.anyWifi:
        condition = const AnyWifi();
      case _ConditionKind.anyCellular:
        condition = const AnyCellular();
    }
    final rawName = _nameController.text.trim();
    final initial = widget.initial;
    final result = NetworkRule(
      id: initial?.id ?? 0,
      name: rawName.isEmpty ? null : rawName,
      conditions: [condition],
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
    final scheme = Theme.of(context).colorScheme;

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
            // Wi-Fi named: radio + inline chip showing the picked SSID,
            // plus a permission-required warning when location is denied.
            RadioGroup<_ConditionKind>(
              groupValue: _conditionKind,
              onChanged: (v) {
                if (v != null) setState(() => _conditionKind = v);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<_ConditionKind>(
                    value: _ConditionKind.wifiNamed,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      appLocalizations.networkRulesConditionWifiNamed,
                    ),
                    subtitle: _conditionKind == _ConditionKind.wifiNamed
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: _WifiNamedChip(
                              ssid: _wifiNamedSsid,
                              hasPermission: hasPermission,
                              onTap: _pickWifiNamed,
                              onClear: () =>
                                  setState(() => _wifiNamedSsid = null),
                            ),
                          )
                        : null,
                  ),
                  RadioListTile<_ConditionKind>(
                    value: _ConditionKind.anyWifi,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      appLocalizations.networkRulesConditionAnyWifi,
                    ),
                  ),
                  RadioListTile<_ConditionKind>(
                    value: _ConditionKind.anyCellular,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      appLocalizations.networkRulesConditionAnyCellular,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    selected: _action == NetworkAction.turnOn,
                    selectedColor: scheme.primaryContainer,
                    label: Center(
                      child: Text(
                        appLocalizations.networkRulesActionTurnOn,
                      ),
                    ),
                    onSelected: (_) =>
                        setState(() => _action = NetworkAction.turnOn),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    selected: _action == NetworkAction.turnOff,
                    selectedColor: scheme.errorContainer,
                    label: Center(
                      child: Text(
                        appLocalizations.networkRulesActionTurnOff,
                      ),
                    ),
                    onSelected: (_) =>
                        setState(() => _action = NetworkAction.turnOff),
                  ),
                ),
              ],
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
          onPressed: _isValid ? _save : null,
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
        ? ssid!
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
