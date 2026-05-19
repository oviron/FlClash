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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbound = ref.watch(vpnSettingProvider.select((state) => state.ipv6));
    final engine = ref.watch(
      patchClashConfigProvider.select((state) => state.ipv6),
    );
    final dns = ref.watch(
      patchClashConfigProvider.select((state) => state.dns.ipv6),
    );
    // Majority vote — keep IPv6 a single switch. If layers were left desynced
    // (e.g. by an older build or manual YAML edit), the displayed value is the
    // dominant state and any toggle flip rewrites all three layers.
    final activeCount = (inbound ? 1 : 0) + (engine ? 1 : 0) + (dns ? 1 : 0);
    final enable = activeCount >= 2;
    return ListItem.switchItem(
      leading: const Icon(Icons.public),
      title: Text(Intl.message('IPv6', name: 'ipv6')),
      subtitle: Text(appLocalizations.ipv6Desc),
      delegate: SwitchDelegate(
        value: enable,
        onChanged: (next) {
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

String _bypassDomainCountLabel(int count) {
  return Intl.plural(
    count,
    one: '$count default domain active',
    other: '$count default domains active',
    name: '_bypassDomainCountLabel',
    args: [count],
  );
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
      subtitle: Text(_bypassDomainCountLabel(bypassDomain.length)),
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
  const _AdvancedNetworkSection(),
];

class _AdvancedNetworkSection extends ConsumerWidget {
  const _AdvancedNetworkSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemProxy = ref.watch(
      vpnSettingProvider.select((state) => state.systemProxy),
    );
    // Bypass domain works only in HTTP/SOCKS system-proxy mode (not TUN).
    if (!systemProxy) return const SizedBox.shrink();
    return ExpansionTile(
      title: Text(Intl.message('Advanced', name: 'advanced')),
      childrenPadding: EdgeInsets.zero,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      children: const [BypassDomainItem()],
    );
  }
}

class NetworkListView extends StatelessWidget {
  const NetworkListView({super.key});

  @override
  Widget build(BuildContext context) {
    return generateListView(networkItems);
  }
}
