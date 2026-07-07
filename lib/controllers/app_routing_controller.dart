part of '../controller.dart';

extension AppRoutingController on AppController {
  // Group/node/provider counts for a profile card stat line, from one read.
  Future<({int groups, int nodes, int providers})> readProfileStats(
    int profileId,
  ) async {
    final file = File(await appPath.getProfilePath(profileId.toString()));
    if (!await file.exists()) return (groups: 0, nodes: 0, providers: 0);
    final doc = ProfileRulesDocument(await file.readAsString());
    return (
      groups: doc.proxyGroups.length,
      nodes: doc.proxyNames.length,
      providers: doc.proxyProviders.length + doc.ruleProviders.length,
    );
  }
}
