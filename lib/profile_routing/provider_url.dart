library;

/// Masks the `user:pass@` userinfo of a subscription URL for display, keeping
/// the rest intact. Non-http(s) strings and URLs without userinfo are returned
/// unchanged. The real value is never altered on save; this is display-only.
String maskProviderUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.userInfo.isEmpty) return url;
  return url.replaceFirst('${uri.userInfo}@', '••••@');
}
