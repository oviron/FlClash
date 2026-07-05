import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/network_rules/model.dart';
import 'package:fl_clash/views/setting/location_permission_gate.dart';
import 'package:fl_clash/views/setting/widgets/rule_labels.dart';
import 'package:fl_clash/network_rules/probe.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/location_permission.dart';
import 'package:fl_clash/providers/recent_ssids.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ConditionKind { wifiNamed, anyWifi, anyCellular, anyEthernet, profile }

const _sectionLabelPadding = EdgeInsets.only(bottom: 8, left: 2);

extension on _ConditionKind {
  String get label => switch (this) {
    _ConditionKind.wifiNamed => appLocalizations.networkRulesConditionWifiNamed,
    _ConditionKind.anyWifi => appLocalizations.networkRulesConditionAnyWifi,
    _ConditionKind.anyCellular =>
      appLocalizations.networkRulesConditionAnyCellular,
    _ConditionKind.anyEthernet =>
      appLocalizations.networkRulesConditionAnyEthernet,
    _ConditionKind.profile => appLocalizations.networkRulesActionProfile,
  };

  IconData get icon => switch (this) {
    _ConditionKind.wifiNamed => Icons.wifi,
    _ConditionKind.anyWifi => Icons.wifi_find,
    _ConditionKind.anyCellular => Icons.signal_cellular_alt,
    _ConditionKind.anyEthernet => Icons.settings_ethernet,
    _ConditionKind.profile => Icons.folder_outlined,
  };

  // wifiNamed/profile open a further picker; the rest add immediately.
  bool get needsParams => switch (this) {
    _ConditionKind.wifiNamed || _ConditionKind.profile => true,
    _ => false,
  };
}

/// Picker for a new condition kind: each kind is a tappable card. A trailing
/// chevron marks kinds that open a further config screen (Wi-Fi name, profile);
/// the rest show a plus, since tapping adds them immediately.
class _ConditionKindDialog extends StatelessWidget {
  const _ConditionKindDialog();

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.networkRulesAddCondition,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final kind in _ConditionKind.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CommonCard(
                onPressed: () => Navigator.of(context).pop(kind),
                child: ListItem(
                  leading: Icon(kind.icon),
                  title: Text(kind.label),
                  trailing: Icon(
                    kind.needsParams ? Icons.chevron_right : Icons.add,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-width bottom-sheet editor for one network rule. A sheet (not a dialog)
/// so the segmented selectors get the whole screen width and never have to wrap
/// their labels.
class EditRuleDialog extends ConsumerStatefulWidget {
  final NetworkRule? initial;
  final SheetType type;

  const EditRuleDialog({super.key, this.initial, required this.type});

  /// Returns the saved rule, or null if the user cancelled. The caller persists
  /// via the repo provider; keeping that out of the widget makes the editor
  /// reusable for both create and edit.
  static Future<NetworkRule?> show({
    required BuildContext context,
    NetworkRule? initial,
  }) {
    return showSheet<NetworkRule>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => EditRuleDialog(initial: initial, type: type),
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
    for (final c in _conditions) {
      final inner = c is Not ? c.inner : c;
      if (inner is WifiNamed && inner.ssid.isEmpty) return false;
    }
    // A rule that neither changes the VPN nor switches a profile is a no-op.
    if (_vpn == NetworkVpnMode.leave && _profileId == null) return false;
    return true;
  }

  bool _isWifiCondition(NetworkCondition c) {
    final inner = c is Not ? c.inner : c;
    return inner is WifiNamed || inner is AnyWifi;
  }

  bool _isNamedWifi(NetworkCondition c) {
    final inner = c is Not ? c.inner : c;
    return inner is WifiNamed;
  }

  /// One sheet for the whole Wi-Fi condition: SSID + match pattern + negate,
  /// all picked at once; no second hop to reach the pattern.
  Future<NetworkCondition?> _pickWifi(NetworkCondition? current) async {
    final granted = await ensureLocationPermissionForSsid(context, ref);
    if (!granted || !mounted) return null;
    return showSheet<NetworkCondition>(
      context: context,
      props: const SheetProps(isScrollControlled: true),
      builder: (_, type) => _WifiConditionSheet(
        type: type,
        recent: ref.read(recentSsidsProvider),
        initial: current,
      ),
    );
  }

  Future<int?> _pickProfile(int? current) {
    final profiles = ref.read(profilesProvider);
    if (profiles.isEmpty) return Future.value(null);
    return globalState.showCommonDialog<int?>(
      child: OptionsDialog<int?>(
        title: appLocalizations.networkRulesActionProfile,
        options: profiles.map((p) => p.id).toList(),
        value: profiles.any((p) => p.id == current)
            ? current
            : profiles.first.id,
        textBuilder: (id) => _profileName(id),
      ),
    );
  }

  Future<void> _addCondition() async {
    final kind = await globalState.showCommonDialog<_ConditionKind>(
      child: const _ConditionKindDialog(),
    );
    if (kind == null || !mounted) return;
    switch (kind) {
      case _ConditionKind.wifiNamed:
        final c = await _pickWifi(null);
        if (c != null) setState(() => _conditions.add(c));
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

  Future<void> _editWifi(int index) async {
    final c = await _pickWifi(_conditions[index]);
    if (c != null) setState(() => _conditions[index] = c);
  }

  // Negate + profile target for the non-Wi-Fi conditions; Wi-Fi is edited in
  // its own sheet via _pickWifi (which carries the match pattern inline).
  Future<void> _editCondition(int index) async {
    final original = _conditions[index];
    final inner = original is Not ? original.inner : original;
    var negated = original is Not;
    int? profileId = inner is ProfileIs ? inner.profileId : null;

    final result = await globalState.showCommonDialog<NetworkCondition>(
      child: StatefulBuilder(
        builder: (dialogContext, setLocal) {
          NetworkCondition compose() {
            final NetworkCondition base = inner is ProfileIs
                ? ProfileIs(profileId ?? 0)
                : inner;
            return negated ? Not(base) : base;
          }

          return CommonDialog(
            title: appLocalizations.networkRulesConditionEdit,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(appLocalizations.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(compose()),
                child: Text(appLocalizations.save),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListItem.switchItem(
                  padding: EdgeInsets.zero,
                  title: Text(appLocalizations.networkRulesConditionNegate),
                  delegate: SwitchDelegate(
                    value: negated,
                    onChanged: (v) => setLocal(() => negated = v),
                  ),
                ),
                if (inner is ProfileIs)
                  ListItem(
                    padding: EdgeInsets.zero,
                    leading: const Icon(Icons.layers_outlined),
                    title: Text(_profileName(profileId)),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final id = await _pickProfile(profileId);
                      if (id != null) setLocal(() => profileId = id);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
    if (result != null) setState(() => _conditions[index] = result);
  }

  String _profileName(int? id) => profileLabel(
    ref.read(profilesProvider),
    id,
    nullLabel: appLocalizations.networkRulesActionProfile,
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
  // picker never surfaces a value absent from its options.
  int? _validProfileId(int? id, List<Profile> profiles) {
    if (id == null) return null;
    return profiles.any((p) => p.id == id) ? id : null;
  }

  String _conditionLabel(NetworkCondition c, List<Profile> profiles) {
    if (c is Not) return '¬ ${_conditionLabel(c.inner, profiles)}';
    if (c is WifiNamed) return wifiPatternLabel(c);
    if (c is AnyWifi) return appLocalizations.networkRulesConditionAnyWifi;
    if (c is AnyCellular) {
      return appLocalizations.networkRulesConditionAnyCellular;
    }
    if (c is AnyEthernet) {
      return appLocalizations.networkRulesConditionAnyEthernet;
    }
    if (c is ProfileIs) {
      final name = profileLabel(profiles, c.profileId, nullLabel: '');
      return '${appLocalizations.networkRulesConditionProfileIs}$name';
    }
    return '';
  }

  IconData _conditionIcon(NetworkCondition c, bool hasPermission) {
    final inner = c is Not ? c.inner : c;
    if (inner is WifiNamed || inner is AnyWifi) {
      return hasPermission ? Icons.wifi : Icons.warning_amber;
    }
    if (inner is AnyCellular) return Icons.signal_cellular_alt;
    if (inner is AnyEthernet) return Icons.settings_ethernet;
    return Icons.layers_outlined;
  }

  Widget _matchModeLabel(NetworkMatchMode mode) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Center(
      child: Text(
        mode == NetworkMatchMode.all
            ? appLocalizations.networkRulesMatchAll
            : appLocalizations.networkRulesMatchAny,
      ),
    ),
  );

  String _vpnLabel(NetworkVpnMode mode) => switch (mode) {
    NetworkVpnMode.turnOn => appLocalizations.networkRulesVpnOn,
    NetworkVpnMode.turnOff => appLocalizations.networkRulesVpnOff,
    NetworkVpnMode.leave => appLocalizations.networkRulesVpnKeep,
  };

  IconData _vpnIcon(NetworkVpnMode mode) => switch (mode) {
    NetworkVpnMode.turnOn => Icons.vpn_key,
    NetworkVpnMode.turnOff => Icons.vpn_key_off,
    NetworkVpnMode.leave => Icons.do_not_disturb_on,
  };

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(locationPermissionProvider);
    final hasPermission = permissionState == LocationPermissionState.granted;
    final scheme = context.colorScheme;
    final profiles = ref.watch(profilesProvider);
    final needsWifi = _conditions.any(_isWifiCondition);

    return AdaptiveSheetScaffold(
      type: widget.type,
      title: widget.initial == null
          ? appLocalizations.networkRulesAdd
          : appLocalizations.networkRulesEdit,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          CommonTextField(
            controller: _nameController,
            labelText: appLocalizations.ruleNameOptional,
          ),
          const SizedBox(height: 16),
          ListHeader(
            title: appLocalizations.networkRulesConditionsLabel,
            padding: _sectionLabelPadding,
          ),
          if (_conditions.length > 1) ...[
            CommonTabBar<NetworkMatchMode>(
              groupValue: _matchMode,
              thumbColor: scheme.secondaryContainer,
              proportionalWidth: false,
              onValueChanged: (m) {
                if (m != null) setState(() => _matchMode = m);
              },
              children: {
                NetworkMatchMode.all: _matchModeLabel(NetworkMatchMode.all),
                NetworkMatchMode.any: _matchModeLabel(NetworkMatchMode.any),
              },
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _conditions.length; i++)
                GestureDetector(
                  onTap: () => _isNamedWifi(_conditions[i])
                      ? _editWifi(i)
                      : _editCondition(i),
                  child: CommonChip(
                    type: ChipType.delete,
                    avatar: Icon(
                      _conditionIcon(_conditions[i], hasPermission),
                      size: 18,
                      color: _isWifiCondition(_conditions[i]) && !hasPermission
                          ? scheme.error
                          : null,
                    ),
                    label: _conditionLabel(_conditions[i], profiles),
                    onPressed: () => setState(() => _conditions.removeAt(i)),
                  ),
                ),
              CommonChip(
                avatar: const Icon(Icons.add, size: 18),
                label: appLocalizations.networkRulesAddCondition,
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
          const SizedBox(height: 20),
          ListHeader(
            title: appLocalizations.vpn,
            padding: _sectionLabelPadding,
          ),
          CommonTabBar<NetworkVpnMode>(
            groupValue: _vpn,
            thumbColor: scheme.secondaryContainer,
            proportionalWidth: false,
            onValueChanged: (m) {
              if (m != null) setState(() => _vpn = m);
            },
            children: {
              for (final mode in NetworkVpnMode.values)
                mode: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_vpnIcon(mode), size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _vpnLabel(mode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            },
          ),
          const SizedBox(height: 16),
          ListHeader(
            title: appLocalizations.networkRulesActionProfile,
            padding: _sectionLabelPadding,
          ),
          ListItem.options(
            leading: Icon(Icons.swap_horiz, color: scheme.primary),
            title: Text(
              _profileLabel(_validProfileId(_profileId, profiles), profiles),
            ),
            delegate: OptionsDelegate<int?>(
              title: appLocalizations.networkRulesActionProfile,
              value: _validProfileId(_profileId, profiles),
              options: [null, for (final p in profiles) p.id],
              textBuilder: (id) => _profileLabel(id, profiles),
              onChanged: (id) => setState(() => _profileId = id),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(appLocalizations.cancel),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _isValid ? _save : null,
                  child: Text(appLocalizations.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _profileLabel(int? id, List<Profile> profiles) => profileLabel(
    profiles,
    id,
    nullLabel: appLocalizations.networkRulesActionNoProfile,
  );
}

class _WifiConditionSheet extends StatefulWidget {
  final SheetType type;
  final List<String> recent;
  final NetworkCondition? initial;

  const _WifiConditionSheet({
    required this.type,
    required this.recent,
    this.initial,
  });

  @override
  State<_WifiConditionSheet> createState() => _WifiConditionSheetState();
}

class _WifiConditionSheetState extends State<_WifiConditionSheet> {
  late final TextEditingController _controller;
  late WifiMatch _match;
  late bool _negated;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    final negated = initial is Not;
    final inner = negated ? initial.inner : initial;
    final wifi = inner is WifiNamed ? inner : null;
    _controller = TextEditingController(text: wifi?.ssid ?? '');
    _match = wifi?.match ?? WifiMatch.exact;
    _negated = negated;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    // Sanitize the same way the runtime reads the SSID so a copy-pasted
    // `"home"` matches.
    final ssid = sanitizeSsid(_controller.text.trim());
    if (ssid == null || ssid.isEmpty) return;
    final NetworkCondition base = WifiNamed(ssid, match: _match);
    Navigator.of(context).pop(_negated ? Not(base) : base);
  }

  String _matchLabel(WifiMatch match) => switch (match) {
    WifiMatch.exact => appLocalizations.networkRulesWifiMatchExact,
    WifiMatch.prefix => appLocalizations.networkRulesWifiMatchPrefix,
    WifiMatch.contains => appLocalizations.networkRulesWifiMatchContains,
  };

  @override
  Widget build(BuildContext context) {
    final canSave = _controller.text.trim().isNotEmpty;
    return AdaptiveSheetScaffold(
      type: widget.type,
      title: appLocalizations.networkRulesConditionWifiNamed,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        children: [
          CommonTextField(
            controller: _controller,
            autofocus: widget.initial == null,
            labelText: 'SSID',
            prefixIcon: const Icon(Icons.wifi_find),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          CommonTabBar<WifiMatch>(
            groupValue: _match,
            thumbColor: context.colorScheme.secondaryContainer,
            proportionalWidth: false,
            onValueChanged: (m) {
              if (m != null) setState(() => _match = m);
            },
            children: {
              for (final match in WifiMatch.values)
                match: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Center(child: Text(_matchLabel(match))),
                ),
            },
          ),
          if (widget.recent.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final item in widget.recent)
              ListItem(
                dense: true,
                padding: EdgeInsets.zero,
                leading: const Icon(Icons.history, size: 18),
                title: Text(item),
                onTap: () => setState(() => _controller.text = item),
              ),
          ],
          ListItem.switchItem(
            padding: EdgeInsets.zero,
            title: Text(appLocalizations.networkRulesConditionNegate),
            delegate: SwitchDelegate(
              value: _negated,
              onChanged: (v) => setState(() => _negated = v),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(appLocalizations.cancel),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: canSave ? _save : null,
                  child: Text(appLocalizations.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
