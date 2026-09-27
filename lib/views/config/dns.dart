import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverrideItem extends ConsumerWidget {
  const OverrideItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final override = ref.watch(overrideDnsProvider);
    final source = ref.watch(dnsSourceProvider).value;
    return ListItem.switchItem(
      title: Text(appLocalizations.overrideDns),
      subtitle: Text(source?.description ?? appLocalizations.overrideDnsDesc),
      delegate: SwitchDelegate(
        value: override,
        onChanged: (bool value) async {
          ref.read(overrideDnsProvider.notifier).value = value;
        },
      ),
    );
  }
}

class OverrideKeysItem extends ConsumerWidget {
  const OverrideKeysItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final keys = ref.watch(
      patchClashConfigProvider.select((state) => state.dnsOverrideKeys),
    );
    return ListItem.open(
      title: Text(appLocalizations.dnsOverrideKeys),
      subtitle: Text(switch (keys) {
        _ when keys.isEmpty => appLocalizations.dnsOverrideKeysNone,
        _ when keys.containsAll(allDnsKeys) =>
          appLocalizations.dnsOverrideKeysAll,
        _ => allDnsKeys.where(keys.contains).join(', '),
      }),
      delegate: const OpenDelegate(widget: _OverrideKeysView()),
    );
  }
}

class _OverrideKeysView extends ConsumerWidget {
  const _OverrideKeysView();

  void _setKeys(WidgetRef ref, Set<String> keys) {
    ref
        .read(patchClashConfigProvider.notifier)
        .update((state) => state.copyWith(dnsOverrideKeys: keys));
  }

  @override
  Widget build(BuildContext context, ref) {
    final keys = ref.watch(
      patchClashConfigProvider.select((state) => state.dnsOverrideKeys),
    );
    return BaseScaffold(
      title: appLocalizations.dnsOverrideKeys,
      actions: [
        if (!keys.containsAll(allDnsKeys))
          IconButton(
            tooltip: appLocalizations.selectAll,
            onPressed: () => _setKeys(ref, {...allDnsKeys}),
            icon: const Icon(Icons.select_all),
          ),
      ],
      body: ListView(
        children: [
          ListTile(title: Text(appLocalizations.dnsOverrideKeysTip)),
          for (final key in allDnsKeys)
            ListItem.checkbox(
              title: Text(key),
              delegate: CheckboxDelegate(
                value: keys.contains(key),
                onChanged: (value) => _setKeys(
                  ref,
                  value == true ? {...keys, key} : ({...keys}..remove(key)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StatusItem extends ConsumerWidget {
  const StatusItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.enable),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.status),
      subtitle: Text(appLocalizations.statusDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(state.dns.copyWith(enable: value)),
              );
        },
      ),
    );
  }
}

class ListenItem extends ConsumerWidget {
  const ListenItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final listen = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.listen),
    );
    return ListItem.input(
      title: Text(appLocalizations.listen),
      subtitle: Text(listen),
      delegate: InputDelegate(
        title: appLocalizations.listen,
        value: listen,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.listen);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(state.dns.copyWith(listen: value)),
              );
        },
      ),
    );
  }
}

class PreferH3Item extends ConsumerWidget {
  const PreferH3Item({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final preferH3 = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.preferH3),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.preferH3),
      subtitle: Text(appLocalizations.preferH3Desc),
      delegate: SwitchDelegate(
        value: preferH3,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(state.dns.copyWith(preferH3: value)),
              );
        },
      ),
    );
  }
}

class RespectRulesItem extends ConsumerWidget {
  const RespectRulesItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final respectRules = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.respectRules),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.respectRules),
      subtitle: Text(appLocalizations.respectRulesDesc),
      delegate: SwitchDelegate(
        value: respectRules,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.withDns(state.dns.copyWith(respectRules: value)),
              );
        },
      ),
    );
  }
}

class DnsModeItem extends ConsumerWidget {
  const DnsModeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enhancedMode = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.enhancedMode),
    );
    return ListItem<DnsMode>.options(
      title: Text(appLocalizations.dnsMode),
      subtitle: Text(enhancedMode.name),
      delegate: OptionsDelegate(
        title: appLocalizations.dnsMode,
        options: DnsMode.values,
        onChanged: (value) {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.withDns(state.dns.copyWith(enhancedMode: value)),
              );
        },
        textBuilder: (dnsMode) => dnsMode.name,
        value: enhancedMode,
      ),
    );
  }
}

class FakeIpRangeItem extends ConsumerWidget {
  const FakeIpRangeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final fakeIpRange = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.fakeIpRange),
    );
    return ListItem.input(
      title: Text(appLocalizations.fakeipRange),
      subtitle: Text(fakeIpRange),
      delegate: InputDelegate(
        title: appLocalizations.fakeipRange,
        value: fakeIpRange,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.fakeipRange);
          }
          return null;
        },
        onChanged: (String? value) {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.withDns(state.dns.copyWith(fakeIpRange: value)),
              );
        },
      ),
    );
  }
}

String? _dnsServerTag(String value) {
  final v = value.toLowerCase();
  if (v.startsWith('https://') || v.startsWith('http3://')) return 'DoH';
  if (v.startsWith('tls://')) return 'DoT';
  if (v.startsWith('quic://')) return 'DoQ';
  if (v.startsWith('system')) return 'SYS';
  return null;
}

class FakeIpFilterItem extends ConsumerWidget {
  const FakeIpFilterItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final fakeIpFilter = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.fakeIpFilter),
    );
    return ListItem.open(
      title: Text(appLocalizations.fakeipFilter),
      delegate: OpenDelegate(
        widget: ListEditorPage(
          title: appLocalizations.fakeipFilter,
          items: fakeIpFilter,
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(
                  state.dns.copyWith(fakeIpFilter: List.from(items)),
                ),
              );
        },
      ),
    );
  }
}

class DefaultNameserverItem extends ConsumerWidget {
  const DefaultNameserverItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final defaultNameserver = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.defaultNameserver),
    );
    return ListItem.open(
      title: Text(appLocalizations.defaultNameserver),
      subtitle: Text(appLocalizations.defaultNameserverDesc),
      delegate: OpenDelegate(
        widget: ListEditorPage(
          title: appLocalizations.defaultNameserver,
          items: defaultNameserver,
          tagBuilder: _dnsServerTag,
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(
                  state.dns.copyWith(defaultNameserver: List.from(items)),
                ),
              );
        },
      ),
    );
  }
}

class NameserverItem extends ConsumerWidget {
  const NameserverItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final nameserver = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.nameserver),
    );
    return ListItem.open(
      title: Text(appLocalizations.nameserver),
      subtitle: Text(appLocalizations.nameserverDesc),
      delegate: OpenDelegate(
        widget: ListEditorPage(
          title: appLocalizations.nameserver,
          items: nameserver,
          tagBuilder: _dnsServerTag,
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(
                  state.dns.copyWith(nameserver: List.from(items)),
                ),
              );
        },
      ),
    );
  }
}

class UseHostsItem extends ConsumerWidget {
  const UseHostsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final useHosts = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.useHosts),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.useHosts),
      delegate: SwitchDelegate(
        value: useHosts,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(state.dns.copyWith(useHosts: value)),
              );
        },
      ),
    );
  }
}

class UseSystemHostsItem extends ConsumerWidget {
  const UseSystemHostsItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final useSystemHosts = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.useSystemHosts),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.useSystemHosts),
      delegate: SwitchDelegate(
        value: useSystemHosts,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.withDns(state.dns.copyWith(useSystemHosts: value)),
              );
        },
      ),
    );
  }
}

class NameserverPolicyItem extends ConsumerWidget {
  const NameserverPolicyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final nameserverPolicy = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.nameserverPolicy),
    );
    return ListItem.open(
      title: Text(appLocalizations.nameserverPolicy),
      subtitle: Text(appLocalizations.nameserverPolicyDesc),
      delegate: OpenDelegate(
        widget: MapEditorPage(
          title: appLocalizations.nameserverPolicy,
          map: nameserverPolicy,
        ),
        onChanged: (value) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.withDns(state.dns.copyWith(nameserverPolicy: value)),
              );
        },
      ),
    );
  }
}

class ProxyServerNameserverItem extends ConsumerWidget {
  const ProxyServerNameserverItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final proxyServerNameserver = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.dns.proxyServerNameserver,
      ),
    );
    return ListItem.open(
      title: Text(appLocalizations.proxyNameserver),
      subtitle: Text(appLocalizations.proxyNameserverDesc),
      delegate: OpenDelegate(
        widget: ListEditorPage(
          title: appLocalizations.proxyNameserver,
          items: proxyServerNameserver,
          tagBuilder: _dnsServerTag,
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(
                  state.dns.copyWith(proxyServerNameserver: List.from(items)),
                ),
              );
        },
      ),
    );
  }
}

class AppendSystemDNSItem extends ConsumerWidget {
  const AppendSystemDNSItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appendSystemDNS = ref.watch(
      networkSettingProvider.select((state) => state.appendSystemDns),
    );
    return ListItem.switchItem(
      leading: const Icon(Icons.dns_outlined),
      title: Text(appLocalizations.appendSystemDns),
      subtitle: Text(appLocalizations.appendSystemDnsTip),
      delegate: SwitchDelegate(
        value: appendSystemDNS,
        onChanged: (bool value) async {
          ref
              .read(networkSettingProvider.notifier)
              .update((state) => state.copyWith(appendSystemDns: value));
        },
      ),
    );
  }
}

class _DnsCoreSection extends StatelessWidget {
  const _DnsCoreSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: generateSection(
        title: appLocalizations.dnsCoreSection,
        items: const [StatusItem(), DnsModeItem()],
      ),
    );
  }
}

class ProxyServerNameserverPolicyItem extends ConsumerWidget {
  const ProxyServerNameserverPolicyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final proxyServerNameserverPolicy = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.dns.proxyServerNameserverPolicy,
      ),
    );
    return ListItem.open(
      title: Text(appLocalizations.proxyNameserverPolicy),
      subtitle: Text(appLocalizations.proxyNameserverPolicyDesc),
      delegate: OpenDelegate(
        widget: MapEditorPage(
          title: appLocalizations.proxyNameserverPolicy,
          map: proxyServerNameserverPolicy,
        ),
        onChanged: (value) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.withDns(
                  state.dns.copyWith(proxyServerNameserverPolicy: value),
                ),
              );
        },
      ),
    );
  }
}

class _DnsServersSection extends StatelessWidget {
  const _DnsServersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: generateSection(
        title: appLocalizations.dnsServersSection,
        items: const [
          DefaultNameserverItem(),
          NameserverItem(),
          ProxyServerNameserverItem(),
          ProxyServerNameserverPolicyItem(),
          NameserverPolicyItem(),
        ],
      ),
    );
  }
}

class _DnsFakeIpSection extends StatelessWidget {
  const _DnsFakeIpSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: generateSection(
        title: appLocalizations.dnsFakeIpSection,
        items: const [FakeIpFilterItem()],
      ),
    );
  }
}

class _DnsBehaviorSection extends StatelessWidget {
  const _DnsBehaviorSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: generateSection(
        title: appLocalizations.dnsBehaviorSection,
        items: const [RespectRulesItem(), AppendSystemDNSItem()],
      ),
    );
  }
}

class _DnsAdvancedSection extends StatelessWidget {
  const _DnsAdvancedSection();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(appLocalizations.advanced),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: EdgeInsets.zero,
      children: const [
        PreferH3Item(),
        Divider(height: 0),
        UseHostsItem(),
        Divider(height: 0),
        UseSystemHostsItem(),
        Divider(height: 0),
        FakeIpRangeItem(),
        Divider(height: 0),
        ListenItem(),
      ],
    );
  }
}

const dnsItems = <Widget>[
  OverrideItem(),
  OverrideKeysItem(),
  _DnsCoreSection(),
  _DnsServersSection(),
  _DnsFakeIpSection(),
  _DnsBehaviorSection(),
  _DnsAdvancedSection(),
];

class DnsListView extends ConsumerWidget {
  const DnsListView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return generateListView(dnsItems);
  }
}
