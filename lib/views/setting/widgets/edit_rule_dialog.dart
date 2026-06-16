import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/views/setting/location_permission_gate.dart';
import 'package:fl_clash/network_rules/probe.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/providers/recent_ssids.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ConditionKind { wifiNamed, anyWifi, anyCellular, anyEthernet, profile }

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

  late final List<NetworkCondition> _conditions;
  late NetworkMatchMode _matchMode;
  late NetworkVpnMode _vpn;
  int? _profileId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    if (initial == null) {
      _conditions = [const AnyCellular()];
      _matchMode = NetworkMatchMode.all;
      _vpn = NetworkVpnMode.turnOn;
      _profileId = null;
    } else {
      _conditions = initial.conditions.isEmpty
          ? [const AnyCellular()]
          : [...initial.conditions];
      _matchMode = initial.matchMode;
      _vpn = initial.action.vpn;
      _profileId = initial.action.profileId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_conditions.isEmpty) return false;
    if (_conditions.any((c) => c is WifiNamed && c.ssid.isEmpty)) return false;
    // A rule that neither changes the VPN nor switches a profile is a no-op.
    if (_vpn == NetworkVpnMode.leave && _profileId == null) return false;
    return true;
  }

  Future<String?> _pickSsid(String? current) async {
    final granted = await ensureLocationPermissionForSsid(context, ref);
    if (!granted || !mounted) return null;
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => _WifiPickerDialog(
        recent: ref.read(recentSsidsProvider),
        initial: current,
      ),
    );
    if (picked == null) return null;
    // Sanitize through the probe path so a copy-pasted `"home"` matches
    // what the runtime reads.
    return NetworkProbe.sanitizeSsid(picked);
  }

  Future<int?> _pickProfile(int? current) {
    final profiles = ref.read(profilesProvider);
    return showDialog<int?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(appLocalizations.networkRulesActionProfile),
        children: [
          for (final p in profiles)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(p.id),
              child: Text(p.label.isNotEmpty ? p.label : '#${p.id}'),
            ),
        ],
      ),
    );
  }

  Future<void> _addCondition() async {
    final kind = await showDialog<_ConditionKind>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(appLocalizations.networkRulesAddCondition),
        children: [
          _kindOption(
            ctx,
            _ConditionKind.wifiNamed,
            appLocalizations.networkRulesConditionWifiNamed,
          ),
          _kindOption(
            ctx,
            _ConditionKind.anyWifi,
            appLocalizations.networkRulesConditionAnyWifi,
          ),
          _kindOption(
            ctx,
            _ConditionKind.anyCellular,
            appLocalizations.networkRulesConditionAnyCellular,
          ),
          _kindOption(
            ctx,
            _ConditionKind.anyEthernet,
            appLocalizations.networkRulesConditionAnyEthernet,
          ),
          _kindOption(
            ctx,
            _ConditionKind.profile,
            appLocalizations.networkRulesActionProfile,
          ),
        ],
      ),
    );
    if (kind == null || !mounted) return;
    switch (kind) {
      case _ConditionKind.wifiNamed:
        final ssid = await _pickSsid(null);
        if (ssid != null && ssid.isNotEmpty) {
          setState(() => _conditions.add(WifiNamed(ssid)));
        }
      case _ConditionKind.anyWifi:
        setState(() => _conditions.add(const AnyWifi()));
      case _ConditionKind.anyCellular:
        setState(() => _conditions.add(const AnyCellular()));
      case _ConditionKind.anyEthernet:
        setState(() => _conditions.add(const AnyEthernet()));
      case _ConditionKind.profile:
        final id = await _pickProfile(null);
        if (id != null) setState(() => _conditions.add(ProfileIs(id)));
    }
  }

  Future<void> _editCondition(int index) async {
    final c = _conditions[index];
    if (c is WifiNamed) {
      final ssid = await _pickSsid(c.ssid);
      if (ssid != null && ssid.isNotEmpty) {
        setState(() => _conditions[index] = WifiNamed(ssid));
      }
    } else if (c is ProfileIs) {
      final id = await _pickProfile(c.profileId);
      if (id != null) setState(() => _conditions[index] = ProfileIs(id));
    }
  }

  Widget _kindOption(BuildContext ctx, _ConditionKind kind, String label) =>
      SimpleDialogOption(
        onPressed: () => Navigator.of(ctx).pop(kind),
        child: Text(label),
      );

  void _save() {
    if (!_isValid) return;
    final rawName = _nameController.text.trim();
    final initial = widget.initial;
    final result = NetworkRule(
      id: initial?.id ?? 0,
      name: rawName.isEmpty ? null : rawName,
      conditions: List.unmodifiable(_conditions),
      matchMode: _matchMode,
      action: NetworkAction(vpn: _vpn, profileId: _profileId),
      priority: initial?.priority ?? 0,
      enabled: initial?.enabled ?? true,
    );
    Navigator.of(context).pop(result);
  }

  // Drop a stale target (profile deleted since the rule was authored) so the
  // dropdown never asserts on a value absent from its items.
  int? _validProfileId(int? id, List<Profile> profiles) {
    if (id == null) return null;
    return profiles.any((p) => p.id == id) ? id : null;
  }

  String _conditionLabel(NetworkCondition c, List<Profile> profiles) {
    if (c is WifiNamed) return c.ssid;
    if (c is AnyWifi) return appLocalizations.networkRulesConditionAnyWifi;
    if (c is AnyCellular) {
      return appLocalizations.networkRulesConditionAnyCellular;
    }
    if (c is AnyEthernet) {
      return appLocalizations.networkRulesConditionAnyEthernet;
    }
    if (c is ProfileIs) {
      final match = profiles.where((p) => p.id == c.profileId);
      final name = match.isNotEmpty && match.first.label.isNotEmpty
          ? match.first.label
          : '#${c.profileId}';
      return '${appLocalizations.networkRulesConditionProfileIs}$name';
    }
    return '';
  }

  IconData _conditionIcon(NetworkCondition c, bool hasPermission) {
    if (c is WifiNamed || c is AnyWifi) {
      return hasPermission ? Icons.wifi : Icons.warning_amber;
    }
    if (c is AnyCellular) return Icons.signal_cellular_alt;
    if (c is AnyEthernet) return Icons.settings_ethernet;
    return Icons.layers_outlined;
  }

  String _vpnLabel(NetworkVpnMode mode) {
    switch (mode) {
      case NetworkVpnMode.turnOn:
        return appLocalizations.networkRulesActionTurnOn;
      case NetworkVpnMode.turnOff:
        return appLocalizations.networkRulesActionTurnOff;
      case NetworkVpnMode.leave:
        return appLocalizations.networkRulesActionLeave;
    }
  }

  Color _vpnColor(ColorScheme scheme, NetworkVpnMode mode) {
    switch (mode) {
      case NetworkVpnMode.turnOn:
        return scheme.primaryContainer;
      case NetworkVpnMode.turnOff:
        return scheme.errorContainer;
      case NetworkVpnMode.leave:
        return scheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(locationPermissionProvider);
    final hasPermission = permissionState == LocationPermissionState.granted;
    final scheme = Theme.of(context).colorScheme;
    final profiles = ref.watch(profilesProvider);
    final needsWifi = _conditions.any((c) => c is WifiNamed || c is AnyWifi);

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
            if (_conditions.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SegmentedButton<NetworkMatchMode>(
                  segments: [
                    ButtonSegment(
                      value: NetworkMatchMode.all,
                      label: Text(appLocalizations.networkRulesMatchAll),
                    ),
                    ButtonSegment(
                      value: NetworkMatchMode.any,
                      label: Text(appLocalizations.networkRulesMatchAny),
                    ),
                  ],
                  selected: {_matchMode},
                  onSelectionChanged: (s) =>
                      setState(() => _matchMode = s.first),
                ),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (var i = 0; i < _conditions.length; i++)
                  InputChip(
                    avatar: Icon(
                      _conditionIcon(_conditions[i], hasPermission),
                      size: 18,
                      color:
                          _conditions[i] is WifiNamed && !hasPermission ||
                              _conditions[i] is AnyWifi && !hasPermission
                          ? scheme.error
                          : null,
                    ),
                    label: Text(_conditionLabel(_conditions[i], profiles)),
                    onPressed:
                        _conditions[i] is WifiNamed ||
                            _conditions[i] is ProfileIs
                        ? () => _editCondition(i)
                        : null,
                    onDeleted: () => setState(() => _conditions.removeAt(i)),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(appLocalizations.networkRulesAddCondition),
                  onPressed: _addCondition,
                ),
              ],
            ),
            if (needsWifi && !hasPermission)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  appLocalizations.permissionRequiredHint,
                  style: TextStyle(color: scheme.error),
                ),
              ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              children: [
                for (final mode in NetworkVpnMode.values)
                  ChoiceChip(
                    selected: _vpn == mode,
                    selectedColor: _vpnColor(scheme, mode),
                    label: Text(_vpnLabel(mode)),
                    onSelected: (_) => setState(() => _vpn = mode),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileDropdown(
              label: appLocalizations.networkRulesActionProfile,
              noneLabel: appLocalizations.networkRulesActionNoProfile,
              value: _validProfileId(_profileId, profiles),
              profiles: profiles,
              onChanged: (id) => setState(() => _profileId = id),
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
              decoration: const InputDecoration(labelText: 'SSID'),
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
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(appLocalizations.save),
        ),
      ],
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final String label;
  final String noneLabel;
  final int? value;
  final List<Profile> profiles;
  final ValueChanged<int?> onChanged;

  const _ProfileDropdown({
    required this.label,
    required this.noneLabel,
    required this.value,
    required this.profiles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButton<int?>(
            isExpanded: true,
            value: value,
            items: [
              DropdownMenuItem(value: null, child: Text(noneLabel)),
              for (final profile in profiles)
                DropdownMenuItem(
                  value: profile.id,
                  child: Text(
                    profile.label.isNotEmpty ? profile.label : '#${profile.id}',
                  ),
                ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
