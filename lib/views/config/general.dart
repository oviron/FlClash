import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/port_dialog.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestUrlItem extends ConsumerWidget {
  const TestUrlItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final testUrl = ref.watch(
      appSettingProvider.select((state) => state.testUrl),
    );
    return ListItem.input(
      leading: const Icon(Icons.timeline),
      title: Text(appLocalizations.testUrl),
      subtitle: Text(testUrl),
      delegate: InputDelegate(
        resetValue: defaultTestUrl,
        title: appLocalizations.testUrl,
        value: testUrl,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.testUrl);
          }
          if (!value.isUrl) {
            return appLocalizations.urlTip(appLocalizations.testUrl);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          ref
              .read(appSettingProvider.notifier)
              .update((state) => state.copyWith(testUrl: value));
        },
      ),
    );
  }
}

const _knownUserAgents = ['clash-verge/v2.4.2', 'ClashforWindows/0.19.23'];
const _customUserAgentOption = '\u0000custom';
final _userAgentPattern = RegExp(r'^[\x20-\x7E]+$');

class UserAgentItem extends ConsumerWidget {
  const UserAgentItem({super.key});

  Future<void> _handleTap(WidgetRef ref, String userAgent) async {
    final isCustom =
        userAgent.isNotEmpty && !_knownUserAgents.contains(userAgent);
    final option = await globalState.showCommonDialog<String>(
      child: OptionsDialog<String>(
        title: appLocalizations.userAgent,
        options: const ['', ..._knownUserAgents, _customUserAgentOption],
        value: isCustom ? _customUserAgentOption : userAgent,
        textBuilder: (value) => switch (value) {
          '' => appLocalizations.defaultText,
          _customUserAgentOption => appLocalizations.userAgentCustom,
          _ => value,
        },
      ),
    );
    if (option == null) return;
    var value = option;
    if (option == _customUserAgentOption) {
      final input = await globalState.showCommonDialog<String>(
        child: InputDialog(
          title: appLocalizations.userAgentCustom,
          value: isCustom ? userAgent : '',
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) {
              return appLocalizations.emptyTip(appLocalizations.userAgent);
            }
            if (!_userAgentPattern.hasMatch(text)) {
              return appLocalizations.userAgentInvalid;
            }
            return null;
          },
        ),
      );
      if (input == null) return;
      value = input.trim();
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(userAgent: value));
  }

  @override
  Widget build(BuildContext context, ref) {
    final userAgent = ref.watch(
      appSettingProvider.select((state) => state.userAgent),
    );
    final label = userAgent.isEmpty ? appLocalizations.defaultText : userAgent;
    return ListItem(
      leading: const Icon(Icons.badge_outlined),
      title: Text(appLocalizations.userAgent),
      subtitle: Text('$label\n${appLocalizations.userAgentDesc}'),
      onTap: () => _handleTap(ref, userAgent),
    );
  }
}

class PortItem extends ConsumerWidget {
  const PortItem({super.key});

  Future<void> handleShowPortDialog() async {
    await globalState.showCommonDialog(child: const PortDialog());
  }

  @override
  Widget build(BuildContext context, ref) {
    final mixedPort = ref.watch(
      patchClashConfigProvider.select((state) => state.mixedPort),
    );
    return ListItem(
      leading: const Icon(Icons.adjust_outlined),
      title: Text(appLocalizations.port),
      subtitle: Text('$mixedPort'),
      onTap: () {
        handleShowPortDialog();
      },
    );
  }
}

class HostsItem extends ConsumerWidget {
  const HostsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final hosts = ref.watch(
      patchClashConfigProvider.select((state) => state.hosts),
    );
    final hostsLabel = appLocalizations.hosts;
    return ListItem.open(
      leading: const Icon(Icons.view_list_outlined),
      title: Text(hostsLabel),
      subtitle: Text(appLocalizations.hostsDesc),
      delegate: OpenDelegate(
        widget: MapEditorPage(title: hostsLabel, map: hosts),
        onChanged: (value) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith(hosts: value));
        },
      ),
    );
  }
}

class AllowLanItem extends ConsumerWidget {
  const AllowLanItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allowLan = ref.watch(
      patchClashConfigProvider.select((state) => state.allowLan),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.device_hub),
      title: Text(appLocalizations.allowLan),
      subtitle: Text(appLocalizations.allowLanDesc),
      delegate: SwitchDelegate(
        value: allowLan,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith(allowLan: value));
        },
      ),
    );
  }
}

class FindProcessItem extends ConsumerWidget {
  const FindProcessItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final mode = ref.watch(
      patchClashConfigProvider.select((state) => state.findProcessMode),
    );
    return ListItem.options(
      leading: const Icon(Icons.polymer_outlined),
      title: Text(appLocalizations.findProcessMode),
      subtitle: Text('${mode.label}\n${appLocalizations.findProcessModeDesc}'),
      delegate: OptionsDelegate<FindProcessMode>(
        value: mode,
        options: FindProcessMode.values,
        textBuilder: (value) => value.label,
        onChanged: (value) {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith(findProcessMode: value));
        },
        title: appLocalizations.findProcessMode,
      ),
    );
  }
}

class TcpConcurrentItem extends ConsumerWidget {
  const TcpConcurrentItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final tcpConcurrent = ref.watch(
      patchClashConfigProvider.select((state) => state.tcpConcurrent),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.double_arrow_outlined),
      title: Text(appLocalizations.tcpConcurrent),
      subtitle: Text(appLocalizations.tcpConcurrentDesc),
      delegate: SwitchDelegate(
        value: tcpConcurrent,
        onChanged: (value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith(tcpConcurrent: value));
        },
      ),
    );
  }
}

class GeodataLoaderItem extends ConsumerWidget {
  const GeodataLoaderItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isMemconservative = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.geodataLoader == GeodataLoader.memconservative,
      ),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.memory),
      title: Text(appLocalizations.geodataLoader),
      subtitle: Text(appLocalizations.geodataLoaderDesc),
      delegate: SwitchDelegate(
        value: isMemconservative,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith(
                  geodataLoader: value
                      ? GeodataLoader.memconservative
                      : GeodataLoader.standard,
                ),
              );
        },
      ),
    );
  }
}

final generalItems = <Widget>[
  ...<Widget>[
    const TestUrlItem(),
    const UserAgentItem(),
    const TcpConcurrentItem(),
    const HostsItem(),
  ].separated(const Divider(height: 0)),
  ExpansionTile(
    title: Text(appLocalizations.advanced),
    childrenPadding: EdgeInsets.zero,
    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
    children: <Widget>[
      const FindProcessItem(),
      const Divider(height: 0),
      const AllowLanItem(),
      const Divider(height: 0),
      const GeodataLoaderItem(),
      const Divider(height: 0),
      const PortItem(),
    ],
  ),
];
