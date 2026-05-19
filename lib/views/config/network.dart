import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VPNItem extends ConsumerWidget {
  const VPNItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final enable = ref.watch(
      vpnSettingProvider.select((state) => state.enable),
    );
    return ListItem.switchItem(
      title: Text(Intl.message('VPN', name: 'vpn')),
      subtitle: Text(appLocalizations.vpnEnableDesc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .update((state) => state.copyWith(enable: value));
        },
      ),
    );
  }
}

class AllowBypassItem extends ConsumerWidget {
  const AllowBypassItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final allowBypass = ref.watch(
      vpnSettingProvider.select((state) => state.allowBypass),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.allowBypass),
      subtitle: Text(appLocalizations.allowBypassDesc),
      delegate: SwitchDelegate(
        value: allowBypass,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .update((state) => state.copyWith(allowBypass: value));
        },
      ),
    );
  }
}

class VpnSystemProxyItem extends ConsumerWidget {
  const VpnSystemProxyItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final systemProxy = ref.watch(
      vpnSettingProvider.select((state) => state.systemProxy),
    );
    return ListItem.switchItem(
      title: Text(appLocalizations.systemProxy),
      subtitle: Text(appLocalizations.systemProxyDesc),
      delegate: SwitchDelegate(
        value: systemProxy,
        onChanged: (bool value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .update((state) => state.copyWith(systemProxy: value));
        },
      ),
    );
  }
}

class UnifiedIpv6Item extends ConsumerWidget {
  const UnifiedIpv6Item({super.key});

  Ipv6Mode _resolveMode(bool inbound, bool engine, bool dns) {
    if (!inbound && !engine && !dns) return Ipv6Mode.off;
    if (inbound && engine && dns) return Ipv6Mode.syncOn;
    return Ipv6Mode.custom;
  }

  String _label(Ipv6Mode mode) {
    switch (mode) {
      case Ipv6Mode.off:
        return Intl.message('Off', name: 'ipv6ModeOff');
      case Ipv6Mode.syncOn:
        return Intl.message('Sync ON', name: 'ipv6ModeSyncOn');
      case Ipv6Mode.custom:
        return Intl.message('Custom', name: 'ipv6ModeCustom');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbound = ref.watch(
      vpnSettingProvider.select((state) => state.ipv6),
    );
    final engine = ref.watch(
      patchClashConfigProvider.select((state) => state.ipv6),
    );
    final dns = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.ipv6),
    );
    final mode = _resolveMode(inbound, engine, dns);
    return ListItem.options(
      leading: const Icon(Icons.public),
      title: const Text('IPv6'),
      subtitle: Text(_label(mode)),
      delegate: OptionsDelegate<Ipv6Mode>(
        title: 'IPv6',
        options: Ipv6Mode.values,
        textBuilder: _label,
        value: mode,
        onChanged: (value) {
          if (value == null || value == Ipv6Mode.custom) return;
          final next = value == Ipv6Mode.syncOn;
          ref
              .read(vpnSettingProvider.notifier)
              .update((state) => state.copyWith(ipv6: next));
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith(
                  ipv6: next,
                  dns: state.dns.copyWith(ipv6: next),
                ),
              );
        },
      ),
    );
  }
}


class TunStackItem extends ConsumerWidget {
  const TunStackItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final stack = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.stack),
    );

    return ListItem.options(
      title: Text(appLocalizations.stackMode),
      subtitle: Text(stack.name),
      delegate: OptionsDelegate<TunStack>(
        value: stack,
        options: TunStack.values,
        textBuilder: (value) => value.name,
        onChanged: (value) {
          if (value == null) {
            return;
          }
          ref
              .read(patchClashConfigProvider.notifier)
              .update((state) => state.copyWith.tun(stack: value));
        },
        title: appLocalizations.stackMode,
      ),
    );
  }
}

class BypassDomainItem extends ConsumerWidget {
  const BypassDomainItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bypassDomain = ref.watch(
      networkSettingProvider.select((state) => state.bypassDomain),
    );
    return ListItem.open(
      title: Text(appLocalizations.bypassDomain),
      subtitle: Text(
        '${bypassDomain.length} ${Intl.message('default domains active', name: 'defaultDomainsActive')}',
      ),
      delegate: OpenDelegate(
        widget: ListInputPage(
          title: appLocalizations.bypassDomain,
          items: bypassDomain,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(networkSettingProvider.notifier)
              .update(
                (state) => state.copyWith(bypassDomain: List.from(items)),
              );
        },
      ),
    );
  }
}

class DNSHijackingItem extends ConsumerWidget {
  const DNSHijackingItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final dnsHijacking = ref.watch(
      vpnSettingProvider.select((state) => state.dnsHijacking),
    );
    return ListItem<RouteMode>.switchItem(
      title: Text(appLocalizations.dnsHijacking),
      delegate: SwitchDelegate(
        value: dnsHijacking,
        onChanged: (value) async {
          ref
              .read(vpnSettingProvider.notifier)
              .update((state) => state.copyWith(dnsHijacking: value));
        },
      ),
    );
  }
}

class RouteModeItem extends ConsumerWidget {
  const RouteModeItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final routeMode = ref.watch(
      networkSettingProvider.select((state) => state.routeMode),
    );
    return ListItem<RouteMode>.options(
      title: Text(appLocalizations.routeMode),
      subtitle: Text(Intl.message('routeMode_${routeMode.name}')),
      delegate: OptionsDelegate<RouteMode>(
        title: appLocalizations.routeMode,
        options: RouteMode.values,
        onChanged: (RouteMode? value) {
          if (value == null) {
            return;
          }
          ref
              .read(networkSettingProvider.notifier)
              .update((state) => state.copyWith(routeMode: value));
        },
        textBuilder: (routeMode) => Intl.message('routeMode_${routeMode.name}'),
        value: routeMode,
      ),
    );
  }
}

class RouteAddressItem extends ConsumerWidget {
  const RouteAddressItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bypassPrivate = ref.watch(
      networkSettingProvider.select(
        (state) => state.routeMode == RouteMode.bypassPrivate,
      ),
    );
    final routeAddress = ref.watch(
      patchClashConfigProvider.select((state) => state.tun.routeAddress),
    );
    if (bypassPrivate) {
      return ListItem(
        title: Text(
          appLocalizations.routeAddress,
          style: TextStyle(color: Theme.of(context).disabledColor),
        ),
        subtitle: Text(
          Intl.message(
            'Not used in Bypass private mode',
            name: 'routeAddressBypassPrivateHint',
          ),
        ),
      );
    }
    return ListItem.open(
      title: Text(appLocalizations.routeAddress),
      subtitle: Text(appLocalizations.routeAddressDesc),
      delegate: OpenDelegate(
        widget: ListInputPage(
          title: appLocalizations.routeAddress,
          items: routeAddress,
          titleBuilder: (item) => Text(item),
        ),
        onChanged: (items) {
          ref
              .read(patchClashConfigProvider.notifier)
              .update(
                (state) => state.copyWith.tun(routeAddress: List.from(items)),
              );
        },
      ),
    );
  }
}

final networkItems = [
  const VPNItem(),
  ...generateSection(
    title: Intl.message('VPN', name: 'vpn'),
    items: [
      const UnifiedIpv6Item(),
      const DNSHijackingItem(),
      const AllowBypassItem(),
      const VpnSystemProxyItem(),
    ],
  ),
  ...generateSection(
    title: appLocalizations.options,
    items: [
      const TunStackItem(),
      const RouteModeItem(),
      const RouteAddressItem(),
    ],
  ),
  ExpansionTile(
    title: Text(Intl.message('Advanced', name: 'advanced')),
    childrenPadding: EdgeInsets.zero,
    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
    children: const [BypassDomainItem()],
  ),
];

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return generateListView(networkItems);
  }
}
