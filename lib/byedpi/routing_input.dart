List<String> parseByeDpiRoutingHosts({
  required String hostListText,
  required Set<String> excludedHosts,
}) {
  return hostListText
      .split('\n')
      .map((host) => host.trim())
      .where((host) => host.isNotEmpty)
      .where((host) => !host.startsWith('#'))
      .where((host) => !excludedHosts.contains(host))
      .toList(growable: false);
}
