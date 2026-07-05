/// Normalizes a raw Wi-Fi SSID for matching. Android returns the `<unknown
/// ssid>` stub when location is missing and double-quote-wraps the value; drop
/// the stub, strip a surrounding quote pair, trim, and map empty to null.
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
