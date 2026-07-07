// Android returns the `<unknown ssid>` stub when location is off and
// double-quote-wraps the value; drop the stub, strip a quote pair, trim, empty
// -> null. Kotlin NetworkSnapshotReader.sanitizeSsid mirrors this order.
String? sanitizeSsid(String? raw) {
  if (raw == null) return null;
  if (raw == '<unknown ssid>') return null;
  var value = raw;
  if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
    value = value.substring(1, value.length - 1);
  }
  value = value.trim();
  if (value.isEmpty) return null;
  return value;
}
