import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OverrideItem extends ConsumerWidget {
  const OverrideItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final override = ref.watch(overrideDnsProvider);
    return ListItem.switchItem(
      title: Text(appLocalizations.overrideDns),
      subtitle: Text(appLocalizations.overrideDnsDesc),
      delegate: SwitchDelegate(
        value: override,
        onChanged: (bool value) async {
          ref.read(overrideDnsProvider.notifier).value = value;
        },
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
              .update((state) => state.copyWith.dns(enable: value));
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
              .update((state) => state.copyWith.dns(listen: value));
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
      title: Text(Intl.message('Prefer H3', name: 'preferH3')),
      subtitle: Text(appLocalizations.preferH3Desc),
      delegate: SwitchDelegate(
        value: preferH3,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith.dns(preferH3: value));
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
              .update((state) => state.copyWith.dns(respectRules: value));
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
              .update((state) => state.copyWith.dns(enhancedMode: value));
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
              .update((state) => state.copyWith.dns(fakeIpRange: value));
        },
      ),
    );
  }
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
        widget: ListInputPage(
          title: appLocalizations.fakeipFilter,
          items: fakeIpFilter,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith.dns(fakeIpFilter: List.from(items)),
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
        widget: ListInputPage(
          title: appLocalizations.defaultNameserver,
          items: defaultNameserver,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.copyWith.dns(defaultNameserver: List.from(items)),
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
        widget: ListInputPage(
          title: appLocalizations.nameserver,
          items: nameserver,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith.dns(nameserver: List.from(items)),
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
              .update((state) => state.copyWith.dns(useHosts: value));
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
              .update((state) => state.copyWith.dns(useSystemHosts: value));
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
        widget: MapInputPage(
          title: appLocalizations.nameserverPolicy,
          map: nameserverPolicy,
          titleBuilder: (item) => Text(item.key),
          subtitleBuilder: (item) => Text(item.value),
        ),
        onChanged: (value) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith.dns(nameserverPolicy: value));
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
        widget: ListInputPage(
          title: appLocalizations.proxyNameserver,
          items: proxyServerNameserver,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.copyWith.dns(proxyServerNameserver: List.from(items)),
              );
        },
      ),
    );
  }
}

class FallbackItem extends ConsumerWidget {
  const FallbackItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final fallback = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.fallback),
    );
    return ListItem.open(
      title: Text(appLocalizations.fallback),
      subtitle: Text(appLocalizations.fallbackDesc),
      delegate: OpenDelegate(
        widget: ListInputPage(
          title: appLocalizations.fallback,
          items: fallback,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith.dns(fallback: List.from(items)),
              );
        },
      ),
    );
  }
}

class GeoipItem extends ConsumerWidget {
  const GeoipItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final geoip = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.dns.fallbackFilter.geoip,
      ),
    );
    return ListItem.switchItem(
      title: Text(Intl.message('Geo IP', name: 'geoip')),
      delegate: SwitchDelegate(
        value: geoip,
        onChanged: (bool value) async {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith.dns.fallbackFilter(geoip: value),
              );
        },
      ),
    );
  }
}

class GeoipCodeItem extends ConsumerWidget {
  const GeoipCodeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final geoipCode = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.dns.fallbackFilter.geoipCode,
      ),
    );
    return ListItem.input(
      title: Text(appLocalizations.geoipCode),
      subtitle: Text(geoipCode),
      delegate: InputDelegate(
        title: appLocalizations.geoipCode,
        value: geoipCode,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.geoipCode);
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
                (state) => state.copyWith.dns.fallbackFilter(geoipCode: value),
              );
        },
      ),
    );
  }
}

class GeositeItem extends ConsumerWidget {
  const GeositeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final geosite = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.dns.fallbackFilter.geosite,
      ),
    );
    final geositeLabel = Intl.message('Geo Site', name: 'geosite');
    return ListItem.open(
      title: Text(geositeLabel),
      delegate: OpenDelegate(
        widget: ListInputPage(
          title: geositeLabel,
          items: geosite,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith.dns.fallbackFilter(
                  geosite: List.from(items),
                ),
              );
        },
      ),
    );
  }
}

class IpcidrItem extends ConsumerWidget {
  const IpcidrItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final ipcidr = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.dns.fallbackFilter.ipcidr,
      ),
    );
    return ListItem.open(
      title: Text(appLocalizations.ipcidr),
      delegate: OpenDelegate(
        widget: ListInputPage(
          title: appLocalizations.ipcidr,
          items: ipcidr,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.copyWith.dns.fallbackFilter(ipcidr: List.from(items)),
              );
        },
      ),
    );
  }
}

class DomainItem extends ConsumerWidget {
  const DomainItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final domain = ref.watch(
      patchClashConfigProvider.select(
        (state) => state.dns.fallbackFilter.domain,
      ),
    );
    return ListItem.open(
      title: Text(appLocalizations.domain),
      delegate: OpenDelegate(
        widget: ListInputPage(
          title: appLocalizations.domain,
          items: domain,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) =>
                    state.copyWith.dns.fallbackFilter(domain: List.from(items)),
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
        title: Intl.message('Core', name: 'dnsCoreSection'),
        items: const [StatusItem(), DnsModeItem()],
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
        title: Intl.message('Servers', name: 'dnsServersSection'),
        items: const [
          DefaultNameserverItem(),
          NameserverItem(),
          ProxyServerNameserverItem(),
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
        title: Intl.message('Fake-IP', name: 'dnsFakeIpSection'),
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
        title: Intl.message('Behavior', name: 'dnsBehaviorSection'),
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
      title: Text(Intl.message('Advanced', name: 'advanced')),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: EdgeInsets.zero,
      children: [
        const PreferH3Item(),
        const Divider(height: 0),
        const UseHostsItem(),
        const Divider(height: 0),
        const UseSystemHostsItem(),
        const Divider(height: 0),
        const FakeIpRangeItem(),
        const Divider(height: 0),
        const ListenItem(),
        const Divider(height: 0),
        ExpansionTile(
          title: Text(
            Intl.message('China / Fallback (legacy)', name: 'dnsFallbackLegacy'),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: EdgeInsets.zero,
          children: const [
            FallbackItem(),
            Divider(height: 0),
            GeoipItem(),
            Divider(height: 0),
            GeoipCodeItem(),
            Divider(height: 0),
            GeositeItem(),
            Divider(height: 0),
            IpcidrItem(),
            Divider(height: 0),
            DomainItem(),
          ],
        ),
      ],
    );
  }
}

const dnsItems = <Widget>[
  OverrideItem(),
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
