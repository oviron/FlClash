// Fetch a subscription as our own client first (honest identity), escalating to
// the Happ client only when [forceHapp] is set or the honest body is unusable
// (some panels gate their full node set behind the Happ client and serve clash
// UAs a stripped body). [fetch] performs the request for the chosen identity;
// [usable] judges whether the honest body is good enough to keep.
Future<T> fetchWithHappFallback<T>(
  Future<T> Function({required bool happ}) fetch,
  bool Function(T) usable, {
  required bool forceHapp,
}) async {
  if (forceHapp) return fetch(happ: true);
  final honest = await fetch(happ: false);
  return usable(honest) ? honest : fetch(happ: true);
}
