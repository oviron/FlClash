import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/views/profiles/app_routing.dart';
import 'package:fl_clash/views/profiles/proxy_groups.dart';
import 'package:fl_clash/views/profiles/sub_rules.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// One entry point for a profile's routing surfaces: per-app routing, proxy
/// groups, sub-rules, and a read-only proxies reference.
class RoutingHubView extends StatelessWidget {
  final int profileId;

  const RoutingHubView({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.routing,
      body: ListView(
        children: [
          ListItem(
            title: Text(appLocalizations.appRouting),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => BaseNavigator.push(
              context,
              AppRoutingView(profileId: profileId),
            ),
          ),
          ListItem(
            title: Text(appLocalizations.proxyGroups),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => BaseNavigator.push(
              context,
              ProxyGroupsView(profileId: profileId),
            ),
          ),
          ListItem(
            title: Text(appLocalizations.subRules),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                BaseNavigator.push(context, SubRulesView(profileId: profileId)),
          ),
          ListItem(
            title: Text(appLocalizations.proxies),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                BaseNavigator.push(context, _ProxiesView(profileId: profileId)),
          ),
        ],
      ),
    );
  }
}

/// Read-only listing of the profile's `proxies:` (name, type, server) for
/// reference when assigning group members; editing proxies stays in YAML.
class _ProxiesView extends StatelessWidget {
  final int profileId;

  const _ProxiesView({required this.profileId});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.proxies,
      body: FutureBuilder<List<({String name, String type, String? server})>>(
        future: appController.readProxyInfos(profileId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final proxies = snapshot.data!;
          if (proxies.isEmpty) {
            return NullStatus(label: appLocalizations.noData);
          }
          return ListView.builder(
            itemCount: proxies.length,
            itemBuilder: (_, index) {
              final p = proxies[index];
              return ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: Text(p.name),
                subtitle: Text(
                  p.server == null ? p.type : '${p.type} · ${p.server}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
