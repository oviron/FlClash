import 'dart:convert';

/// Our own UID's resource use, as the framework reports it
/// (`SystemHealthManager.takeMyUidSnapshot`). Counters are cumulative since the
/// last battery reset, so a window is expressed as the difference of two reads.
class HealthStats {
  final int realtimeBatteryMs;
  final int cpuUserMs;
  final int cpuSystemMs;
  final int wakeLockMs;
  final int wifiRxBytes;
  final int wifiTxBytes;
  final int mobileRxBytes;
  final int mobileTxBytes;

  const HealthStats({
    this.realtimeBatteryMs = 0,
    this.cpuUserMs = 0,
    this.cpuSystemMs = 0,
    this.wakeLockMs = 0,
    this.wifiRxBytes = 0,
    this.wifiTxBytes = 0,
    this.mobileRxBytes = 0,
    this.mobileTxBytes = 0,
  });

  static int _int(Map<String, dynamic> json, String key) {
    final value = json[key];
    return value is num ? value.toInt() : 0;
  }

  factory HealthStats.fromJson(Map<String, dynamic> json) => HealthStats(
    realtimeBatteryMs: _int(json, 'realtimeBatteryMs'),
    cpuUserMs: _int(json, 'cpuUserMs'),
    cpuSystemMs: _int(json, 'cpuSystemMs'),
    wakeLockMs: _int(json, 'wakeLockMs'),
    wifiRxBytes: _int(json, 'wifiRxBytes'),
    wifiTxBytes: _int(json, 'wifiTxBytes'),
    mobileRxBytes: _int(json, 'mobileRxBytes'),
    mobileTxBytes: _int(json, 'mobileTxBytes'),
  );

  static HealthStats? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return HealthStats.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  int get cpuTotalMs => cpuUserMs + cpuSystemMs;

  int get rxBytes => wifiRxBytes + mobileRxBytes;

  int get txBytes => wifiTxBytes + mobileTxBytes;

  /// Counters only ever grow; a smaller value than the baseline means the
  /// framework reset them (reboot, battery-stats reset), so the window is
  /// reported from zero instead of going negative.
  static int _delta(int now, int before) => now >= before ? now - before : now;

  HealthStats since(HealthStats baseline) => HealthStats(
    realtimeBatteryMs: _delta(realtimeBatteryMs, baseline.realtimeBatteryMs),
    cpuUserMs: _delta(cpuUserMs, baseline.cpuUserMs),
    cpuSystemMs: _delta(cpuSystemMs, baseline.cpuSystemMs),
    wakeLockMs: _delta(wakeLockMs, baseline.wakeLockMs),
    wifiRxBytes: _delta(wifiRxBytes, baseline.wifiRxBytes),
    wifiTxBytes: _delta(wifiTxBytes, baseline.wifiTxBytes),
    mobileRxBytes: _delta(mobileRxBytes, baseline.mobileRxBytes),
    mobileTxBytes: _delta(mobileTxBytes, baseline.mobileTxBytes),
  );
}
