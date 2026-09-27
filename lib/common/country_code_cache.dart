import 'dart:async';

import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/models.dart';

// Bounded, dedupe-on-flight cache for connection-flag country lookups: a
// rebuild must never re-hit the core for an IP it already resolved (or is
// already resolving). FIFO eviction once [maxEntries] is reached.
class CountryCodeCache {
  CountryCodeCache({required this.fetch, this.maxEntries = 500});

  final Future<IpInfo?> Function(String ip) fetch;
  final int maxEntries;

  final _entries = <String, IpInfo?>{};
  final _inFlight = <String, Future<IpInfo?>>{};

  bool containsKey(String ip) => _entries.containsKey(ip);

  IpInfo? peek(String ip) => _entries[ip];

  Future<IpInfo?> resolve(String ip) {
    if (_entries.containsKey(ip)) {
      return Future.value(_entries[ip]);
    }
    return _inFlight.putIfAbsent(ip, () async {
      IpInfo? info;
      try {
        info = await fetch(ip);
      } catch (_) {
        info = null;
      }
      _store(ip, info);
      // The map's value type is itself a Future; this discards that stored
      // reference (the one this closure is completing), not an unawaited op.
      unawaited(_inFlight.remove(ip));
      return info;
    });
  }

  void _store(String ip, IpInfo? info) {
    if (!_entries.containsKey(ip) && _entries.length >= maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    _entries[ip] = info;
  }
}

final countryCodeCache = CountryCodeCache(fetch: coreController.getCountryCode);
